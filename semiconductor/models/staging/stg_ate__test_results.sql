-- One row per parametric measurement. Short test name = text after '<>' in TEST_TXT.
select
    regexp_extract(filename, '([^/\\]+)[/\\]test_results\.parquet$', 1) as lot,
    part_index,
    test_num,
    trim(test_name) as test_name,
    trim(split_part(test_name, '<>', -1)) as test_short_name,
    units,
    result,
    lo,
    hi,
    passed
from {{ source('ate', 'test_results') }}
