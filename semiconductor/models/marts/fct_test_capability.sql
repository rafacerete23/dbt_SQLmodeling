-- Classic Cpk (mean, stddev) next to robust Cpk (median, 1.4826 * MAD) per
-- test, across lots. Gross failures far outside the limits wreck the classic
-- version; the robust one describes the main population. `steps_in_tolerance`
-- below 10 breaks the AIAG MSA 10:1 resolution rule of thumb.
with r as (
    select * from {{ ref('stg_ate__test_results') }} where result is not null
),
stats as (
    select
        test_num,
        any_value(test_short_name) as test,
        any_value(units) as units,
        any_value(lo) as lo,
        any_value(hi) as hi,
        count(*) as n,
        avg(result) as mean,
        stddev_samp(result) as sigma,
        median(result) as median,
        avg((not passed)::int) as fail_rate
    from r
    group by test_num
),
mad as (
    -- MAD is 0 for quantised results; fall back to IQR / 1.349, then to null.
    select
        r.test_num,
        coalesce(
            nullif(1.4826 * median(abs(r.result - s.median)), 0),
            nullif((quantile_cont(r.result, 0.75) - quantile_cont(r.result, 0.25)) / 1.349, 0)
        ) as sigma_robust
    from r join stats s using (test_num)
    group by r.test_num
),
resolution as (
    select test_num, min(step) as resolution
    from (
        select test_num, result - lag(result) over (partition by test_num order by result) as step
        from (select distinct test_num, result from r)
    )
    where step > 0
    group by test_num
)
select
    s.test_num,
    s.test,
    s.units,
    s.n,
    s.lo,
    s.hi,
    round(least((s.hi - s.mean) / (3 * s.sigma), (s.mean - s.lo) / (3 * s.sigma)), 3) as cpk_classic,
    round(least((s.hi - s.median) / (3 * m.sigma_robust), (s.median - s.lo) / (3 * m.sigma_robust)), 3) as cpk_robust,
    round(100 * s.fail_rate, 2) as fail_pct,
    round((s.hi - s.lo) / res.resolution, 1) as steps_in_tolerance,
    (s.hi - s.lo) / res.resolution >= 10 as resolution_ok
from stats s
join mad m using (test_num)
left join resolution res using (test_num)
where s.n >= 30 and s.sigma > 0
