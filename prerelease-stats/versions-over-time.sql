#standardSQL
-- BigQuery – downloads of the Django project by version ove rtime
WITH filtered_downloads AS (
  SELECT
    timestamp,
    dl.file.version AS version
  FROM `bigquery-public-data.pypi.file_downloads` as dl
  WHERE project = 'django'
  AND timestamp BETWEEN TIMESTAMP('2016-01-01T00:00:01.000Z') AND CURRENT_TIMESTAMP()
)
SELECT
  TIMESTAMP_TRUNC(timestamp, MONTH) AS month,
  version,
  COUNT(*) AS num_downloads
FROM filtered_downloads
GROUP BY month, version
ORDER BY month, num_downloads DESC;
