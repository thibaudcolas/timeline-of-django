# StackOverflow Developer Survey analysis

## Dataset

Downloaded with:

```bash
wget -r -l1 -H -t1 -nd -N -np -A.zip -erobots=off https://survey.stackoverflow.co/
# Remove because little to no relevant data:
rm -rf 20{11,12,13,14,15,16,17}.zip
for z in *.zip; do unzip "$z" -d "${z%.zip}"; done
for d in stack-overflow-developer-survey-*; do mv "$d" "${d#stack-overflow-developer-survey-}"; done
rm -rf 20{18,19}/__MACOSX
```

## Data analysis

Load data:

```sql
create table survey_2018 as select * from './2018/survey_results_public.csv';
create table survey_2019 as select * from './2019/survey_results_public.csv';
create table survey_2020 as select * from read_csv_auto('./2020/survey_results_public.csv', nullstr='NA');
create table survey_2021 as select * from './2021/survey_results_public.csv';
create table survey_2022 as select * from './2022/survey_results_public.csv';
create table survey_2023 as select * from './2023/survey_results_public.csv';
create table survey_2024 as select * from './2024/survey_results_public.csv';
create table survey_2025 as select * from './2025/survey_results_public.csv';
```

Query data – see separate files.

Summarize, per framework:

```sql
create table so_results as (
  select * from results_2018
  union
  select * from results_2019
  union
  select * from results_2020
  union
  select * from results_2021
  union
  select * from results_2022
  union
  select * from results_2023
  union
  select * from results_2024
  union
  select * from results_2025
  order by Year desc, Framework
);
```

Totals:

```sql
select 2018 as Year, count(*) as Total from survey_2018 where FrameworkWorkedWith <> 'NA'
union
select 2019 as Year, count(*) as Total from survey_2019 where WebFrameWorkedWith <> 'NA'
union
select 2020 as Year, count(*) as Total from survey_2020 where WebFrameWorkedWith <> 'NA'
union
select 2021 as Year, count(*) as Total from survey_2021 where WebframeHaveWorkedWith <> 'NA'
union
select 2022 as Year, count(*) as Total from survey_2022 where WebframeHaveWorkedWith <> 'NA'
union
select 2023 as Year, count(*) as Total from survey_2023 where WebframeHaveWorkedWith <> 'NA'
union
select 2024 as Year, count(*) as Total from survey_2024 where WebframeHaveWorkedWith <> 'NA'
union
select 2025 as Year, count(*) as Total from survey_2025 where WebframeHaveWorkedWith <> 'NA'
order by Year desc;
```

| Year | Total |
| ---: | ----: |
| 2025 | 22970 |
| 2024 | 45161 |
| 2023 | 66938 |
| 2022 | 53544 |
| 2021 | 61707 |
| 2020 | 42279 |
| 2019 | 65022 |
| 2018 | 51620 |
