-- Finding 2 in ate-test-data-pipeline/docs/FINDINGS.md: bin 20 (OSC_VL24) is
-- a measurement problem, so almost every bin-20 die passes when retested.
select lot, sum(recovered) * 1.0 / sum(retested) as recovery
from {{ ref('fct_bin_pareto') }}
where hard_bin = 20
group by lot
having sum(recovered) * 1.0 / sum(retested) < 0.9
