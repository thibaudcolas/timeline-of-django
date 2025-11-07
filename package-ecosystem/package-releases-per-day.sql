copy(WITH first_release AS (
  -- First release date per package
  SELECT
    name,
    CAST(MIN(release_time) AS DATE) AS first_day
  FROM releases
  GROUP BY name
),
days AS (
  SELECT *
  FROM generate_series(
    (SELECT MIN(CAST(release_time AS DATE)) FROM releases),
    (SELECT MAX(CAST(release_time AS DATE)) FROM releases),
    INTERVAL 1 DAY
  ) AS d(day)
),
by_day AS (
  -- All releases per day (one row per package+version in `releases`)
  SELECT
    CAST(release_time AS DATE) AS day,
    COUNT(*) AS releases
  FROM releases
  GROUP BY 1
),
new_by_day AS (
  -- New packages per day (first-ever release for each package)
  SELECT
    first_day AS day,
    COUNT(*) AS new_packages
  FROM first_release
  GROUP BY first_day
)
SELECT
  d.day,
  COALESCE(b.releases, 0)    AS releases,
  COALESCE(n.new_packages, 0) AS new_packages
FROM days d
LEFT JOIN by_day b USING (day)
LEFT JOIN new_by_day n USING (day)
ORDER BY d.day) to './package-releases-per-day.csv';
