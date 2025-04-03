-- DuckDB query to quantify % of downloads of the latest FastAPI version over time.
create table supported_downloads as (
  WITH supported as (
    SELECT
        d.day AS day,
        SUM(d.total_downloads) AS supported_downloads
    FROM feature_versions as d
    JOIN releases r
      ON d.minor_version = r.version
    -- This accounts for overlapping supported versions, though technically FastAPI only supports its latest.
    -- Note - versions will only be counted on the day after their release date, as release_date times are exact,
    -- While "day" is 00:01:00 on that date.
    WHERE d.day >= r.release_date
      AND (r.eol_date IS NULL OR d.day < r.eol_date)
    GROUP BY d.day
  ),
  total as (
    SELECT
        d.day AS day,
        SUM(d.total_downloads) AS total_downloads
    FROM feature_versions as d
    GROUP BY d.day
  )
  SELECT
      s.day,
      s.supported_downloads,
      t.total_downloads,
      ROUND(s.supported_downloads * 100.0 / NULLIF(t.total_downloads, 0), 2) AS supported_percentage
  FROM supported s
  JOIN total t
    ON s.day = t.day
  ORDER BY s.day
);
