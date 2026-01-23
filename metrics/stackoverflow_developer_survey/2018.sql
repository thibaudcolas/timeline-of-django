-- DuckDB: Calculates web framework popularity, loved/wanted/dreaded metrics from Stack Overflow 2018 survey data.
create table results_2018 as WITH frameworks AS (
    SELECT UNNEST([
        'Angular',
        'React',
        'Next',
        'Express',
        'Vue',
        'ASP.NET',
        'Flask',
        'Django',
        'WordPress',
        'FastAPI',
        'Laravel',
        'Svelte',
        'Blazor',
        'Nuxt',
        'Htmx',
        'Symfony',
        'Rails',
        'Astro',
        'Fastify',
        'Phoenix',
        'Drupal',
        'Strapi'
      ]) AS framework
),
current_popularity AS (
    SELECT
        framework AS Framework,
        count(*) AS Popularity
    FROM
        survey_2018,
        frameworks
    WHERE
        lower(FrameworkWorkedWith) LIKE '%' || lower(framework) || '%'
    GROUP BY
        framework
),
desired_popularity AS (
    SELECT
        framework AS Framework,
        count(*) AS Popularity
    FROM
        survey_2018,
        frameworks
    WHERE
        lower(FrameworkDesireNextYear) LIKE '%' || lower(framework) || '%'
    GROUP BY
        framework
),
loved_count AS (
    SELECT
        framework AS Framework,
        count(*) AS Popularity
    FROM
        survey_2018,
        frameworks
    WHERE
        lower(FrameworkWorkedWith) LIKE '%' || lower(framework) || '%'
        and
        lower(FrameworkDesireNextYear) LIKE '%' || lower(framework) || '%'
    GROUP BY
        framework
),
wanted_count AS (
    SELECT
        framework AS Framework,
        count(*) AS Popularity
    FROM
        survey_2018,
        frameworks
    WHERE
        not(lower(FrameworkWorkedWith) LIKE '%' || lower(framework) || '%')
        and
        lower(FrameworkDesireNextYear) LIKE '%' || lower(framework) || '%'
    GROUP BY
        framework
),
dreaded_count AS (
    SELECT
        framework AS Framework,
        count(*) AS Popularity
    FROM
        survey_2018,
        frameworks
    WHERE
        lower(FrameworkWorkedWith) LIKE '%' || lower(framework) || '%'
        and
        not(lower(FrameworkDesireNextYear) LIKE '%' || lower(framework) || '%')
    GROUP BY
        framework
)
SELECT
    2018 as Year,
    f.framework AS Framework,
    coalesce(c.Popularity, 0) AS Current_Popularity,
    Current_Popularity / 51620 as Current_Popularity_Percent,
    coalesce(d.Popularity, 0) AS Desired_Popularity,
    Desired_Popularity / 51620 as Desired_Popularity_Percent,
    coalesce(loved_count.Popularity, 0) AS Loved,
    Loved / Current_Popularity as Loved_Percent,
    coalesce(wanted_count.Popularity, 0) AS Wanted,
    Wanted / 51620 as Wanted_Percent,
    coalesce(dreaded_count.Popularity, 0) AS Dreaded,
    Dreaded / Current_Popularity as Dreaded_Percent,
FROM
    frameworks f
LEFT JOIN current_popularity c ON f.framework = c.Framework
LEFT JOIN desired_popularity d ON f.framework = d.Framework
LEFT JOIN loved_count ON f.framework = loved_count.Framework
LEFT JOIN wanted_count ON f.framework = wanted_count.Framework
LEFT JOIN dreaded_count ON f.framework = dreaded_count.Framework
ORDER BY
    f.framework;
