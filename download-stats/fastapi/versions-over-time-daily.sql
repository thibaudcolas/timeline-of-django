#standardSQL
-- BigQuery – downloads of the FastAPI project by version by day
WITH filtered_downloads AS (
  SELECT
    dl.timestamp,
    dl.file.version AS version
  FROM `bigquery-public-data.pypi.file_downloads` as dl
  WHERE project = 'fastapi'
  -- The first data point is 2018-12-08 technically.
  AND dl.timestamp BETWEEN TIMESTAMP('2016-01-01T00:00:01.000Z') AND CURRENT_TIMESTAMP()
)
SELECT
  TIMESTAMP_TRUNC(timestamp, DAY) AS day,
  version,
  COUNT(*) AS num_downloads
FROM filtered_downloads
GROUP BY day, version
ORDER BY day, num_downloads DESC
