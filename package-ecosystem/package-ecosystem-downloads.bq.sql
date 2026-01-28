-- BigQuery: Counts 30-day downloads for Django-related packages on PyPI.
SELECT
  dl.project,
  COUNT(*) AS downloads_count
FROM
  `bigquery-public-data.pypi.file_downloads` AS dl
WHERE
  dl.timestamp > TIMESTAMP_SUB (CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND (
    dl.project IN (
      'django',
      'posthog',
      'ralph',
      'pretix',
      'iommi',
      'wagtail',
      'coderedcms',
      'longclaw',
      'wagalytics',
      'puput',
      'ls.joyous',
      'feincms'
      'mezzanine'
    )
    OR dl.project LIKE 'dj%'
    OR dl.project LIKE 'drf-%'
    OR dl.project LIKE 'wagtail%'
    OR dl.project LIKE 'feincms%'
    OR dl.project LIKE 'mezzanine%'
  )
GROUP BY
  dl.project
ORDER BY
  downloads_count desc
