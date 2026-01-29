-- BigQuery: Retrieves Django-related packages with their latest release metadata.
SELECT
  dm.name,
  dm.version as latest_release,
  dm.author,
  dm.license,
  dm.home_page,
  dm.requires_python,
  ARRAY_TO_STRING (dm.project_urls, ', ') as project_urls,
  ARRAY_TO_STRING (dm.classifiers, ', ') as classifiers,
  ARRAY_TO_STRING (dm.requires_dist, ', ') as requires_dist,
  dm.upload_time,
FROM
  `bigquery-public-data.pypi.distribution_metadata` as dm,
  (
    SELECT
      dm.name,
      MAX(dm.upload_time) as latest_upload
    FROM
      `bigquery-public-data.pypi.distribution_metadata` as dm
    WHERE
      dm.packagetype = 'bdist_wheel'
      AND
      (
        REGEXP_CONTAINS(name, r'^(django|posthog|ralph|pretix|iommi|wagtail|coderedcms|longclaw|wagalytics|puput|ls\.joyous|feincms|mezzanine)$|^dj|^drf-|^wagtail|^feincms|^mezzanine|wagtail$|django$')
        OR EXISTS (SELECT 1 FROM UNNEST(classifiers) AS c WHERE c = 'Framework :: Django' or c = 'Framework :: Wagtail')
      )
    GROUP BY
      dm.name
  ) as latest
WHERE
  dm.packagetype = 'bdist_wheel'
  AND latest.latest_upload = dm.upload_time
  AND latest.name = dm.name
