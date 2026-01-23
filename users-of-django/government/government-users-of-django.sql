-- DuckDB: Filters Django sites to identify government domains based on TLD patterns.
select
  origin,
  rank,
  dj_version,
  last_modified
from
  w_dj
where
  regexp_matches (
    origin,
    '\.((gov|government|gob|gouv|gv)\.?[a-z]{0,2}$|gc\.ca|gouv\.fr|govt\.nz|go\.kr|overheid\.nl|admin\.ch|europa\.eu|bund\.de|(gop|gos|gkp|gob|gog|gok)\.pk|canada\.ca|bund\.de)'
  );