# wafer_sort: dbt on semiconductor test data

A second, self-contained dbt project in this fork: the Jaffle Shop patterns
(sources → staging → marts, generic and singular tests) applied to real
wafer-sort data from an ATE tester instead of a sandwich shop.

Input: the Parquet tables written by
[ate-test-data-pipeline](https://github.com/rafacerete23/ate-test-data-pipeline),
which parses STDF v4 tester files (two Galaxy demo wafers, 1,456 dies each, plus retests).

```bash
# from the root of this repo (branch local-duckdb), with the venv from the main README active
git clone https://github.com/rafacerete23/ate-test-data-pipeline ../ate-test-data-pipeline
pip install -r requirements-local.txt ../ate-test-data-pipeline
cd ../ate-test-data-pipeline
python scripts/get_sample_data.py
for lot in lot2 lot3; do python -m ate_pipeline.ingest data/raw/$lot.stdf --out data/parquet/$lot; done

cd -              # back to this repo
cd semiconductor
dbt deps --profiles-dir .
dbt build --profiles-dir .      # var ate_parquet_dir defaults to ../../ate-test-data-pipeline/data/parquet
```

On Windows PowerShell, replace the `for` loop with
`foreach ($lot in "lot2","lot3") { python -m ate_pipeline.ingest data/raw/$lot.stdf --out data/parquet/$lot }`.

| Model | Grain | What it answers |
|-------|-------|-----------------|
| `stg_ate__parts`, `stg_ate__test_results` | insertion / measurement | Parquet read straight from disk via a dbt-duckdb external source; lot from the folder name |
| `int_die_insertions` | insertion | numbers each die's insertions (`row_number` over lot, x, y) |
| `dim_die` | die | first-pass and final bin per physical die |
| `fct_lot_yield` | lot | insertion vs first-pass vs final yield: the tester's own summary double-counts retests |
| `fct_bin_pareto` | lot × bin | first-pass Pareto with cumulative % (window function) and retest recovery |
| `fct_test_capability` | test | classic vs robust (median/MAD) Cpk and the AIAG 10:1 resolution check |

Two singular tests pin the SQL to the Python answer key (`report.die_yield`) and
to finding 2 in that repo's `docs/FINDINGS.md` (bin 20 recovers on retest).
CI (`.github/workflows/local_duckdb.yml`, job `wafer-sort`) checks out the
pipeline repo, ingests the data and runs `dbt build`.
