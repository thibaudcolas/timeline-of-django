-- Attach SWE-bench datasets
CREATE VIEW swe_dev AS SELECT *, 'SWE-bench' AS source, 'dev' AS split FROM 'SWE-bench/data/dev-00000-of-00001.parquet';
CREATE VIEW swe_test AS SELECT *, 'SWE-bench' AS source, 'test' AS split FROM 'SWE-bench/data/test-00000-of-00001.parquet';
CREATE VIEW swe_train AS SELECT *, 'SWE-bench' AS source, 'train' AS split FROM 'SWE-bench/data/train-00000-of-00001.parquet';

-- Attach SWE-bench_Multimodal
CREATE VIEW swe_mm_dev AS SELECT *, 'SWE-bench_Multimodal' AS source, 'dev' AS split FROM 'SWE-bench_Multimodal/data/dev-00000-of-00001.parquet';
CREATE VIEW swe_mm_test AS SELECT *, 'SWE-bench_Multimodal' AS source, 'test' AS split FROM 'SWE-bench_Multimodal/data/test-00000-of-00001.parquet';

-- Attach SWE-bench_Verified
CREATE VIEW swe_verified_test AS SELECT *, 'SWE-bench_Verified' AS source, 'test' AS split FROM 'SWE-bench_Verified/data/test-00000-of-00001.parquet';

CREATE OR REPLACE VIEW all_swe AS
SELECT repo, source, split
FROM swe_dev
UNION ALL
SELECT repo, source, split FROM swe_test
UNION ALL
SELECT repo, source, split FROM swe_train
UNION ALL
SELECT repo, source, split FROM swe_mm_dev
UNION ALL
SELECT repo, source, split FROM swe_mm_test
UNION ALL
SELECT repo, source, split FROM swe_verified_test;

CREATE OR REPLACE VIEW all_swe AS
SELECT repo, source, split
FROM swe_dev
UNION ALL
SELECT repo, source, split FROM swe_test
UNION ALL
SELECT repo, source, split FROM swe_train
UNION ALL
SELECT repo, source, split FROM swe_mm_dev
UNION ALL
SELECT repo, source, split FROM swe_mm_test
UNION ALL
SELECT repo, source, split FROM swe_verified_test;

SELECT
  source,
  split,
  COUNT(*) AS total_entries,
  COUNT(DISTINCT repo) AS unique_repos
FROM all_swe
GROUP BY source, split
ORDER BY source, split;

SELECT
  repo,
  source,
  split,
  COUNT(*) AS entry_count
FROM all_swe
GROUP BY repo, source, split
ORDER BY repo, source, split;

SELECT
  repo,
  SUM(CASE WHEN source = 'SWE-bench' AND split = 'train' THEN 1 ELSE 0 END) AS swe_train,
  SUM(CASE WHEN source = 'SWE-bench' AND split = 'dev' THEN 1 ELSE 0 END) AS swe_dev,
  SUM(CASE WHEN source = 'SWE-bench' AND split = 'test' THEN 1 ELSE 0 END) AS swe_test,
  SUM(CASE WHEN source = 'SWE-bench_Multimodal' AND split = 'dev' THEN 1 ELSE 0 END) AS swe_mm_dev,
  SUM(CASE WHEN source = 'SWE-bench_Multimodal' AND split = 'test' THEN 1 ELSE 0 END) AS swe_mm_test,
  SUM(CASE WHEN source = 'SWE-bench_Verified' AND split = 'test' THEN 1 ELSE 0 END) AS swe_verified_test
FROM all_swe
GROUP BY repo
ORDER BY repo;

COPY(
  SELECT
    repo,
    SUM(CASE WHEN source = 'SWE-bench' AND split = 'train' THEN 1 ELSE 0 END) AS swe_train,
    SUM(CASE WHEN source = 'SWE-bench' AND split = 'dev' THEN 1 ELSE 0 END) AS swe_dev,
    SUM(CASE WHEN source = 'SWE-bench' AND split = 'test' THEN 1 ELSE 0 END) AS swe_test,
    SUM(CASE WHEN source = 'SWE-bench_Multimodal' AND split = 'dev' THEN 1 ELSE 0 END) AS swe_mm_dev,
    SUM(CASE WHEN source = 'SWE-bench_Multimodal' AND split = 'test' THEN 1 ELSE 0 END) AS swe_mm_test,
    SUM(CASE WHEN source = 'SWE-bench_Verified' AND split = 'test' THEN 1 ELSE 0 END) AS swe_verified_test
  FROM all_swe
  GROUP BY repo
  ORDER BY repo
) TO './swe-bench-repos.csv';
