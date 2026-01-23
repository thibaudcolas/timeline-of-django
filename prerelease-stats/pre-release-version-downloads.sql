#standardSQL
-- BigQuery: Counts Django downloads by version during pre-release periods for adoption analysis.
WITH downloads AS (
  SELECT *
  FROM `bigquery-public-data.pypi.file_downloads` as dl
  WHERE dl.project = 'django'
    -- Un-comment the relevant version, and run each separately.
    -- DO NOT ever fetch data from multiple versions at the same time. The cost of the query is kept low thanks to the date partitioning, which only supports a single range.
    -- -- 5.2
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(5\.2|5\.1($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2025-01-16T09:15:08.000Z') AND TIMESTAMP('2025-04-02T23:59:59.000Z')
    -- -- 5.1
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(5\.1|5\.0($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2024-05-22T16:41:39.000Z') AND TIMESTAMP('2024-08-07T13:33:52.000Z')
    -- -- 5.0
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(5\.0|4\.2($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2023-09-18T22:48:31.000Z') AND TIMESTAMP('2023-12-04T13:12:41.000Z')
    -- -- 4.2
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(4\.2|4\.1($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2023-01-17T09:39:20.000Z') AND TIMESTAMP('2023-04-03T08:36:11.000Z')
    -- -- 4.1
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(4\.1|4\.0($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2022-05-18T05:54:32.000Z') AND TIMESTAMP('2022-08-03T08:40:20.000Z')
    -- -- 4.0
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(4\.0|3\.2($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2021-09-21T19:08:46.000Z') AND TIMESTAMP('2021-12-07T09:19:58.000Z')
    -- -- 3.2
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(3\.2|3\.1($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2021-01-19T13:04:20.000Z') AND TIMESTAMP('2021-04-06T09:33:15.000Z')
    -- -- 3.1
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(3\.1|3\.0($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2020-05-14T09:41:05.000Z') AND TIMESTAMP('2020-08-04T08:07:00.000Z')
    -- -- 3.0
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(3\.0|2\.2($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2019-09-10T09:19:32.000Z') AND TIMESTAMP('2019-12-02T11:13:11.000Z')
    -- -- 2.2
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(2\.2|2\.1($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2019-01-17T15:35:52.000Z') AND TIMESTAMP('2019-04-01T12:47:35.000Z')
    -- -- 2.1
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(2\.1|2\.0($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2018-05-18T01:01:19.000Z') AND TIMESTAMP('2018-08-01T14:11:27.000Z')
    -- -- 2.0
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(2\.0|1\.11($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2017-09-22T18:09:22.000Z') AND TIMESTAMP('2017-12-02T15:11:49.000Z')
    -- -- 1.11
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(1\.11|1\.10($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2017-01-18T01:01:35.000Z') AND TIMESTAMP('2017-04-04T15:59:30.000Z')
    -- -- 1.10
    -- AND REGEXP_CONTAINS(dl.file.version, r'^(1\.10|1\.9($|\.))') AND dl.timestamp BETWEEN TIMESTAMP('2016-05-20T12:16:44.000Z') AND TIMESTAMP('2016-08-01T18:32:07.000Z')
)
SELECT
  dl.file.version AS version,
  COUNT(*) AS downloads_count
FROM downloads AS dl
GROUP BY version
ORDER BY version DESC;
