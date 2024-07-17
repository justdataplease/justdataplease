# Documentation for BigQuery Open Source library of UDFs Functions and Procedures | by JustDataPlease

## Contents
1. [channel_attribution(source, medium, campaign_name)](#channel_attribution)
2. [find_cyber_week(date)](#find_cyber_week)
3. [find_moon_illumination(date)](#find_moon_illumination)
4. [find_moon_illumination__(date_string)](#find_moon_illumination__)
5. [find_season(date)](#find_season)
6. [generate_date_calendar(table_name, start_date, end_date)](#generate_date_calendar)
7. [generate_date_calendar_with_holidays(table_name, start_date, end_date, country)](#generate_date_calendar_with_holidays)
8. [generate_hour_calendar(table_name)](#generate_hour_calendar)
9. [seconds_to_date(seconds)](#seconds_to_date)
10. [seconds_to_timestamp(seconds)](#seconds_to_timestamp)
11. [shift_date(date, years, months, days)](#shift_date)
12. [timestamp_to_string(timestamp)](#timestamp_to_string)
13. [convert_json_to_struct(string)](#convert_json_to_struct)
14. [dedup_table(table_name, timestamp_column, unique_column, output_table_suffix)](#dedup_table)
15. [generate_dbt_yml_schema(project_id, dataset_id)](#generate_dbt_yml_schema)
16. [generate_justsql_schema(project_id, dataset_id, tables)](#generate_justsql_schema)
17. [greatest_not_null(arr)](#greatest_not_null)
18. [least_not_null(arr)](#least_not_null)
19. [parse_yaml(string)](#parse_yaml)
20. [safe_least(x, y)](#safe_least)
21. [detect_outlier_iqr(value, value_percentile_25, value_percentile_75)](#detect_outlier_iqr)
22. [percentile(arr, percentile)](#percentile)
23. [clean_email(email)](#clean_email)
24. [clean_special_symbols(string)](#clean_special_symbols)
25. [clean_special_symbols_custom(string)](#clean_special_symbols_custom)
26. [clean_url(url)](#clean_url)
27. [decode_url(url)](#decode_url)
28. [dedup_chars(string)](#dedup_chars)
29. [detect_department_email(email)](#detect_department_email)
30. [detect_free_email(email)](#detect_free_email)
31. [detect_free_email_domain(email_domain)](#detect_free_email_domain)
32. [detect_useragent_device_type(useragent)](#detect_useragent_device_type)
33. [extract_all_url_parameters(url)](#extract_all_url_parameters)
34. [extract_email_domain(url)](#extract_email_domain)
35. [extract_email_domain_base(url)](#extract_email_domain_base)
36. [extract_url_domain(url)](#extract_url_domain)
37. [extract_url_domain_base(url)](#extract_url_domain_base)
38. [extract_url_language(url)](#extract_url_language)
39. [extract_url_parameter(url, parameter)](#extract_url_parameter)
40. [extract_url_path(url, clean_url_tail)](#extract_url_path)
41. [extract_url_prefix(url)](#extract_url_prefix)
42. [extract_url_suffix(url)](#extract_url_suffix)
43. [extract_url_tail(url)](#extract_url_tail)
44. [fuzzy_distance_dam(string_1, string_2)](#fuzzy_distance_dam)
45. [fuzzy_distance_leven(string_1, string_2)](#fuzzy_distance_leven)
46. [fuzzy_nysiis(string)](#fuzzy_nysiis)
47. [normalize_text(string)](#normalize_text)
48. [parse_useragent(useragent)](#parse_useragent)
49. [remove_accents(string)](#remove_accents)
50. [remove_email_plus_address(email)](#remove_email_plus_address)
51. [remove_en_stopwords(string)](#remove_en_stopwords)
52. [remove_extra_spaces(string)](#remove_extra_spaces)
53. [remove_extra_whitespaces(string)](#remove_extra_whitespaces)
54. [replace_en_contractions(string, replacement)](#replace_en_contractions)
55. [replace_html_tags(string, replacement)](#replace_html_tags)
56. [replace_urls(string, replacement)](#replace_urls)
57. [split_url(url, part)](#split_url)
58. [stemmer_greek(string)](#stemmer_greek)
59. [stemmer_lancaster(string)](#stemmer_lancaster)
60. [stemmer_porter(string)](#stemmer_porter)
61. [surrogate_key(string)](#surrogate_key)
62. [surrogate_key_str(string)](#surrogate_key_str)
63. [transliterate_anyascii(string)](#transliterate_anyascii)
64. [validate_email(email)](#validate_email)
65. [word_distance(string_1, string_2)](#word_distance)
66. [word_tokens(string, symbol)](#word_tokens)

---
## <a id='channel_attribution'></a>1. channel_attribution(source, medium, campaign_name)

- **Type**: SQL
- **Tags**: analytics, text
- **Region**: us,eu
- **Description**: Performs channel attribution using the <source>, <medium>, and <campaign_name>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.channel_attribution`(`source` string, `medium` string, `campaign_name` string) 
  RETURNS string AS (CASE
  -------direct
  WHEN  source IS NULL AND medium IS NULL THEN 'direct'
  WHEN  source='' AND medium='' THEN 'direct'
  WHEN  source IN ('(direct)','direct') AND medium IN ('(none)','none','(not set)','not set','') THEN 'direct'
  
  -------cross-network
  WHEN REGEXP_CONTAINS(campaign_name, 'cross-network') THEN 'cross-network'
  
  -------paid-shopping
  WHEN (
    REGEXP_CONTAINS(
      source,
      'alibaba|amazon|google shopping|shopify|etsy|ebay|stripe|walmart'
    )
    OR REGEXP_CONTAINS(
      campaign_name,
      '^(.*(([^a-df-z]|^)shop|shopping).*)$'
    )
  )
  AND REGEXP_CONTAINS(medium, '^(.*cp.*|ppc|retargeting|paid.*)$') THEN 'paid shopping'
 
  -------paid search
  WHEN REGEXP_CONTAINS(
    source,
    'baidu|bing|duckduckgo|ecosia|google|yahoo|yandex'
  )
  AND REGEXP_CONTAINS(medium, '^(.*cp.*|ppc|retargeting|paid.*)$') THEN 'paid search'
  
  -------paid social
  WHEN REGEXP_CONTAINS(
    source,
    'badoo|facebook|fb|instagram|linkedin|pinterest|tiktok|twitter|whatsapp'
  )
  AND REGEXP_CONTAINS(medium, '^(.*cp.*|ppc|retargeting|paid.*)$') THEN 'paid social'

  -------paid video
  WHEN REGEXP_CONTAINS(
    source,
    'dailymotion|disneyplus|netflix|youtube|vimeo|twitch|vimeo|youtube'
  )
  AND REGEXP_CONTAINS(medium, '^(.*cp.*|ppc|retargeting|paid.*)$') THEN 'paid video'

  -------display
  WHEN medium IN (
    'display',
    'banner',
    'expandable',
    'interstitial',
    'cpm'
  ) THEN 'display'

  -------paid other
  WHEN REGEXP_CONTAINS(medium, r"^(.*cp.*|ppc|retargeting|paid.*)$")
   THEN 'Paid Other'

  -------organic shopping
  WHEN REGEXP_CONTAINS(
    source,
    'alibaba|amazon|google shopping|shopify|etsy|ebay|stripe|walmart'
  )
  OR REGEXP_CONTAINS(
    campaign_name,
    '^(.*(([^a-df-z]|^)shop|shopping).*)$'
  ) THEN 'organic shopping'
  -------organic social
  WHEN REGEXP_CONTAINS(
    source,
    'badoo|facebook|fb|instagram|linkedin|pinterest|tiktok|twitter|whatsapp'
  )
  OR medium IN (
    'social',
    'social-network',
    'social-media',
    'sm',
    'social network',
    'social media'
  ) THEN 'organic social'
  -------organic video
  WHEN REGEXP_CONTAINS(
    source,
    'dailymotion|disneyplus|netflix|youtube|vimeo|twitch|vimeo|youtube'
  )
  OR REGEXP_CONTAINS(medium, '^(.*video.*)$') THEN 'organic video'
  -------organic search
  WHEN REGEXP_CONTAINS(
    source,
    'baidu|bing|duckduckgo|ecosia|google|yahoo|yandex'
  )
  OR medium = 'organic' THEN 'organic search'
  -- Other
  WHEN medium IN ("referral", "app", "link") THEN 'referral'
  WHEN REGEXP_CONTAINS(source, 'email|e-mail|e_mail|e mail')
  OR REGEXP_CONTAINS(medium, 'email|e-mail|e_mail|e mail') THEN 'email'
  WHEN medium = 'affiliate' THEN 'affiliates'
  WHEN medium = 'audio' THEN 'audio'
  WHEN medium = 'sms' THEN 'sms'
  WHEN REGEXP_CONTAINS(medium, r'push$|mobile|notification') THEN 'mobile push notifications'
  ELSE 'unassigned'
END
)
  OPTIONS ( description = '''Performs channel attribution using the <source>, <medium>, and <campaign_name>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.channel_attribution`("shopify","paid","test")
```

**Example Output**:

```
paid shopping
```
---
## <a id='find_cyber_week'></a>2. find_cyber_week(date)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Determines if a <date> falls within Cyber Week and identifies the specific day (e.g., Thanksgiving, Black Friday).

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.find_cyber_week`(`date` DATE) 
  RETURNS STRUCT<is_cyber_week INT64, day_name STRING> AS ((
  WITH calculated_dates AS (
    SELECT 
      DATE_ADD(DATE_TRUNC(DATE(EXTRACT(YEAR FROM date), 11, 1), MONTH), 
        INTERVAL (26 - EXTRACT(DAYOFWEEK FROM DATE(EXTRACT(YEAR FROM date), 11, 1))) DAY) AS thanksgiving
  )
  SELECT 
    STRUCT(
    IF(date BETWEEN thanksgiving AND DATE_ADD(thanksgiving, INTERVAL 4 DAY), 1, 0),
    CASE 
      WHEN date = thanksgiving THEN 'Thanksgiving'
      WHEN date = DATE_ADD(thanksgiving, INTERVAL 1 DAY) THEN 'Black Friday'
      WHEN date = DATE_ADD(thanksgiving, INTERVAL 2 DAY) OR date = DATE_ADD(thanksgiving, INTERVAL 3 DAY) THEN 'Thanksgiving Weekend'
      WHEN date = DATE_ADD(thanksgiving, INTERVAL 4 DAY) THEN 'Cyber Monday'
      ELSE NULL
    END)
  FROM calculated_dates
))
  OPTIONS ( description = '''Determines if a <date> falls within Cyber Week and identifies the specific day (e.g., Thanksgiving, Black Friday).''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.find_cyber_week`("2023-11-24")
```

**Example Output**:

```
1 | Black Friday
```
---
## <a id='find_moon_illumination'></a>3. find_moon_illumination(date)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Calculates the Moon's illumination on a specific <date>, expressed as a fraction or percentage. For example, during a full moon, the illumination is near 100, while during a new moon, it is close to 0

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.find_moon_illumination`(`date` DATE) 
  RETURNS FLOAT64 AS (justfunctions.eu.find_moon_illumination__(
      CAST(date AS STRING)
))
  OPTIONS ( description = '''Calculates the Moon's illumination on a specific <date>, expressed as a fraction or percentage. For example, during a full moon, the illumination is near 100, while during a new moon, it is close to 0''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.find_moon_illumination`("2090-01-16")
```

**Example Output**:

```
1
```
---
## <a id='find_moon_illumination__'></a>4. find_moon_illumination__(date_string)

- **Type**: JS
- **Tags**: date
- **Region**: us,eu
- **Description**: Helper function for find_moon_illumination, using a <date_string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.find_moon_illumination__`(`date_string` STRING) RETURNS FLOAT64
	LANGUAGE js AS r'''var phase = Astronomy.MoonPhase(date_string);
let illum = Astronomy.Illumination(Astronomy.Body.Moon, date_string);
return (illum.phase_fraction * 100).toFixed(2)
''' OPTIONS ( description = '''Helper function for find_moon_illumination, using a <date_string>.'''  , library = [  "gs://justfunctions/bigquery-functions/astronomy.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.find_moon_illumination__`("2090-01-16")
```

**Example Output**:

```
99.17
```
---
## <a id='find_season'></a>5. find_season(date)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Identifies the season name and the start date of the season for a given <date>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.find_season`(`date` DATE) 
  RETURNS STRUCT<season STRING, start_of_season DATE> AS (CASE 
  WHEN EXTRACT(MONTH FROM date) IN (3, 4, 5) 
  THEN STRUCT("Spring" AS season, DATE(EXTRACT(YEAR FROM date), 3, 1) AS start_of_season)

  WHEN EXTRACT(MONTH FROM date) IN (6, 7, 8) 
  THEN STRUCT("Summer", DATE(EXTRACT(YEAR FROM date), 6, 1))

  WHEN EXTRACT(MONTH FROM date) IN (9, 10, 11) 
  THEN STRUCT("Autumn", DATE(EXTRACT(YEAR FROM date), 9, 1))

  WHEN EXTRACT(MONTH FROM date) = 12 
  THEN STRUCT("Winter", DATE(EXTRACT(YEAR FROM date), 12, 1))

  WHEN EXTRACT(MONTH FROM date) IN (1, 2) 
  THEN STRUCT("Winter", DATE(EXTRACT(YEAR FROM date) - 1, 12, 1))

  ELSE STRUCT("Unknown", NULL)
END
)
  OPTIONS ( description = '''Identifies the season name and the start date of the season for a given <date>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.find_season`("2020-01-04")
```

**Example Output**:

```
Winter | 2019-12-01
```
---
## <a id='generate_date_calendar'></a>6. generate_date_calendar(table_name, start_date, end_date)

- **Type**: PROCEDURE
- **Tags**: operations, date
- **Region**: us,eu
- **Description**: Generates a complete date calendar table named <table_name> from <start_date> to <end_date>.

```sql
CREATE OR REPLACE PROCEDURE `justfunctions.eu.generate_date_calendar`(`table_name` string, `start_date` string, `end_date` string)
options(
    description = '''Generates a complete date calendar table named <table_name> from <start_date> to <end_date>.'''
)
BEGIN

-- Drop the table if it exists
EXECUTE IMMEDIATE 'DROP TABLE IF EXISTS ' || table_name;

-- Create the date_calendar table
EXECUTE IMMEDIATE 'CREATE TABLE ' || table_name || ' (date_id INT64 NOT NULL, date DATE NOT NULL, epoch INT64 NOT NULL, day_suffix STRING NOT NULL, day_name STRING NOT NULL, day_name_abbr STRING NOT NULL, day_of_week INT64 NOT NULL, day_of_month INT64 NOT NULL, day_of_quarter INT64 NOT NULL, day_of_year INT64 NOT NULL, week_of_month INT64 NOT NULL, week_of_year INT64 NOT NULL, week_of_year_iso STRING NOT NULL, month_ INT64 NOT NULL, month_name STRING NOT NULL, month_name_abbr STRING NOT NULL, quarter INT64 NOT NULL, quarter_name STRING NOT NULL, year INT64 NOT NULL, start_of_week DATE NOT NULL,start_of_week_saturday DATE NOT NULL, start_of_month DATE NOT NULL, start_of_midmonth DATE NOT NULL, start_of_quarter DATE NOT NULL, start_of_year DATE NOT NULL, end_of_week DATE NOT NULL, end_of_month DATE NOT NULL, end_of_quarter DATE NOT NULL, end_of_year DATE NOT NULL,start_of_fiscal_year DATE NOT NULL,end_of_fiscal_year DATE NOT NULL, yyyymm STRING NOT NULL, yyyymmdd STRING NOT NULL, month_desc STRING, quarter_desc STRING, week_desc STRING, is_weekend BOOL NOT NULL, season STRING, start_of_season DATE, moon_illumination FLOAT64);';

-- Populate the table
EXECUTE IMMEDIATE 'INSERT INTO ' || table_name || ' WITH date_range AS (SELECT date FROM UNNEST(GENERATE_DATE_ARRAY("' || start_date || '","' || end_date  || '")) AS date) SELECT CAST(FORMAT_DATE("%Y%m%d", date) AS INT64) AS date_id, date AS date, UNIX_SECONDS(TIMESTAMP(date)) AS epoch, CONCAT(CAST(EXTRACT(DAY FROM date) AS STRING), "th") AS day_suffix, FORMAT_DATE("%A", date) AS day_name, FORMAT_DATE("%a", date) AS day_name_abbr, EXTRACT(DAYOFWEEK FROM date) AS day_of_week, EXTRACT(DAY FROM date) AS day_of_month, EXTRACT(DAY FROM date) - EXTRACT(DAY FROM DATE_TRUNC(date, QUARTER)) + 1 AS day_of_quarter, EXTRACT(DAYOFYEAR FROM date) AS day_of_year, EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM DATE_TRUNC(date, MONTH)) + 1 AS week_of_month, CAST(FORMAT_DATE("%V", date) AS INT64) AS week_of_year, FORMAT_DATE("%G-W%V-%u", date) AS week_of_year_iso, EXTRACT(MONTH FROM date) AS month, FORMAT_DATE("%B", date) AS month_name, FORMAT_DATE("%b", date) AS month_name_abbr, EXTRACT(QUARTER FROM date) AS quarter, CONCAT("Q", CAST(EXTRACT(QUARTER FROM date) AS STRING)) AS quarter_name, EXTRACT(YEAR FROM date) AS year, DATE_TRUNC(date, WEEK(MONDAY)) AS start_of_week,DATE_TRUNC(date, WEEK(SATURDAY)) AS start_of_week_saturday, DATE_TRUNC(date, MONTH) AS start_of_month, DATE_ADD(DATE_TRUNC(date, MONTH), INTERVAL 14 DAY) AS start_of_midmonth, DATE_TRUNC(date, QUARTER) AS start_of_quarter, DATE_TRUNC(date, YEAR) AS start_of_year, DATE_ADD(DATE_TRUNC(date, WEEK(SATURDAY)), INTERVAL 6 DAY) AS end_of_week, LAST_DAY(date, MONTH) AS end_of_month, LAST_DAY(date, QUARTER) AS end_of_quarter, LAST_DAY(date, YEAR) AS end_of_year,     CAST(IF(EXTRACT(MONTH FROM date) >= 10,     DATE(EXTRACT(YEAR FROM date), 10, 1),    DATE(EXTRACT(YEAR FROM date) - 1, 10, 1)) AS DATE) AS start_of_fiscal_year,CAST(IF(EXTRACT(MONTH FROM date) >= 10,     DATE(EXTRACT(YEAR FROM date) + 1, 9, 30),     DATE(EXTRACT(YEAR FROM date), 9, 30) ) AS DATE) AS end_of_fiscal_year,FORMAT_DATE("%Y%m", date) AS yyyymm, FORMAT_DATE("%Y%m%d", date) AS yyyymmdd, CONCAT(CAST(EXTRACT(YEAR FROM date) AS STRING), "-", FORMAT_DATE("%b", date)) AS month_desc, CONCAT(CAST(EXTRACT(YEAR FROM date) AS STRING), "-Q", CAST(EXTRACT(QUARTER FROM date) AS STRING)) AS quarter_desc, CONCAT(CAST(EXTRACT(YEAR FROM date) AS STRING), "-","W",CAST(FORMAT_DATE("%V", date) AS INT64)) AS week_desc, CASE WHEN EXTRACT(DAYOFWEEK FROM date) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend,justfunctions.eu.find_season(date).season season, justfunctions.eu.find_season(date).start_of_season start_of_season,justfunctions.eu.find_moon_illumination(date) moon_illumination FROM date_range;';

END;
```
**Example Query**:

```sql
CALL `justfunctions.eu.generate_date_calendar`("justfunctions.test.date_calendar","2020-01-01","2030-01-01")
```

**Example Output**:

```
- date_id: 20200101
- date: 2020-01-01
- epoch: 1577836800
- day_suffix: 1th
- day_name: Wednesday
- day_name_abbr: Wed
- day_of_week: 4
- day_of_month: 1
- day_of_quarter: 1
- day_of_year: 1
- week_of_month: 1
- week_of_year: 1
- week_of_year_iso: 2020-W01-3
- month: 1
- month_name: January
- month_name_abbr: Jan
- quarter: 1
- quarter_name: Q1
- year: 2020
- start_of_week: 2019-12-30
- start_of_week_saturday: 2019-12-28
- start_of_month: 2020-01-01
- start_of_midmonth: 2020-01-15
- start_of_quarter: 2020-01-01
- start_of_year: 2020-01-01
- end_of_week: 2020-01-03
- end_of_month: 2020-01-31
- end_of_quarter: 2020-03-31
- end_of_year: 2020-12-31
- start_of_fiscal_year: 2019-10-01
- end_of_fiscal_year: 2020-09-30
- yyyymm: 202001
- yyyymmdd: 20200101
- month_desc: 2020-Jan
- quarter_desc: 2020-Q1
- week_desc: 2020-W1
- is_weekend: FALSE
- start_of_season: 2019-12-01
- season: Winter
- moon_illumination: 29.95

```
---
## <a id='generate_date_calendar_with_holidays'></a>7. generate_date_calendar_with_holidays(table_name, start_date, end_date, country)

- **Type**: PROCEDURE
- **Tags**: operations, date
- **Region**: us,eu
- **Description**: Generates a complete date calendar table named <table_name> with holidays for the specified <country>, from <start_date> to <end_date>. Holidays are available between 2000-2100.

```sql
CREATE OR REPLACE PROCEDURE `justfunctions.eu.generate_date_calendar_with_holidays`(`table_name` string, `start_date` string, `end_date` string, `country` string)
options(
    description = '''Generates a complete date calendar table named <table_name> with holidays for the specified <country>, from <start_date> to <end_date>. Holidays are available between 2000-2100.'''
)
BEGIN

-- Drop the table if it exists
EXECUTE IMMEDIATE 'DROP TABLE IF EXISTS ' || table_name;

-- Create the date_calendar table
EXECUTE IMMEDIATE 'CREATE TABLE ' || table_name || ' (date_id INT64 NOT NULL, date DATE NOT NULL, epoch INT64 NOT NULL, day_suffix STRING NOT NULL, day_name STRING NOT NULL, day_name_abbr STRING NOT NULL, day_of_week INT64 NOT NULL, day_of_month INT64 NOT NULL, day_of_quarter INT64 NOT NULL, day_of_year INT64 NOT NULL, week_of_month INT64 NOT NULL, week_of_year INT64 NOT NULL, week_of_year_iso STRING NOT NULL, month_ INT64 NOT NULL, month_name STRING NOT NULL, month_name_abbr STRING NOT NULL, quarter INT64 NOT NULL, quarter_name STRING NOT NULL, year INT64 NOT NULL, start_of_week DATE NOT NULL,start_of_week_saturday DATE NOT NULL, start_of_month DATE NOT NULL, start_of_midmonth DATE NOT NULL, start_of_quarter DATE NOT NULL, start_of_year DATE NOT NULL, end_of_week DATE NOT NULL, end_of_month DATE NOT NULL, end_of_quarter DATE NOT NULL, end_of_year DATE NOT NULL,start_of_fiscal_year DATE NOT NULL,end_of_fiscal_year DATE NOT NULL, yyyymm STRING NOT NULL, yyyymmdd STRING NOT NULL, month_desc STRING, quarter_desc STRING, week_desc STRING, is_weekend BOOL NOT NULL, season STRING, start_of_season DATE, holiday_name STRING, holiday_country STRING, special_day_name STRING, moon_illumination FLOAT64);';

-- Populate the table
EXECUTE IMMEDIATE 'INSERT INTO ' || table_name || ' WITH date_range AS (SELECT date FROM UNNEST(GENERATE_DATE_ARRAY("' || start_date || '","' || end_date  || '")) AS date) SELECT CAST(FORMAT_DATE("%Y%m%d", date) AS INT64) AS date_id, date AS date, UNIX_SECONDS(TIMESTAMP(date)) AS epoch, CONCAT(CAST(EXTRACT(DAY FROM date) AS STRING), "th") AS day_suffix, FORMAT_DATE("%A", date) AS day_name, FORMAT_DATE("%a", date) AS day_name_abbr, EXTRACT(DAYOFWEEK FROM date) AS day_of_week, EXTRACT(DAY FROM date) AS day_of_month, EXTRACT(DAY FROM date) - EXTRACT(DAY FROM DATE_TRUNC(date, QUARTER)) + 1 AS day_of_quarter, EXTRACT(DAYOFYEAR FROM date) AS day_of_year, EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM DATE_TRUNC(date, MONTH)) + 1 AS week_of_month, CAST(FORMAT_DATE("%V", date) AS INT64) AS week_of_year, FORMAT_DATE("%G-W%V-%u", date) AS week_of_year_iso, EXTRACT(MONTH FROM date) AS month, FORMAT_DATE("%B", date) AS month_name, FORMAT_DATE("%b", date) AS month_name_abbr, EXTRACT(QUARTER FROM date) AS quarter, CONCAT("Q", CAST(EXTRACT(QUARTER FROM date) AS STRING)) AS quarter_name, EXTRACT(YEAR FROM date) AS year, DATE_TRUNC(date, WEEK(MONDAY)) AS start_of_week,DATE_TRUNC(date, WEEK(SATURDAY)) AS start_of_week_saturday, DATE_TRUNC(date, MONTH) AS start_of_month, DATE_ADD(DATE_TRUNC(date, MONTH), INTERVAL 14 DAY) AS start_of_midmonth, DATE_TRUNC(date, QUARTER) AS start_of_quarter, DATE_TRUNC(date, YEAR) AS start_of_year, DATE_ADD(DATE_TRUNC(date, WEEK(SATURDAY)), INTERVAL 6 DAY) AS end_of_week, LAST_DAY(date, MONTH) AS end_of_month, LAST_DAY(date, QUARTER) AS end_of_quarter, LAST_DAY(date, YEAR) AS end_of_year,     CAST(IF(EXTRACT(MONTH FROM date) >= 10,     DATE(EXTRACT(YEAR FROM date), 10, 1),    DATE(EXTRACT(YEAR FROM date) - 1, 10, 1)) AS DATE) AS start_of_fiscal_year,CAST(IF(EXTRACT(MONTH FROM date) >= 10,     DATE(EXTRACT(YEAR FROM date) + 1, 9, 30),     DATE(EXTRACT(YEAR FROM date), 9, 30) ) AS DATE) AS end_of_fiscal_year,FORMAT_DATE("%Y%m", date) AS yyyymm, FORMAT_DATE("%Y%m%d", date) AS yyyymmdd, CONCAT(CAST(EXTRACT(YEAR FROM date) AS STRING), "-", FORMAT_DATE("%b", date)) AS month_desc, CONCAT(CAST(EXTRACT(YEAR FROM date) AS STRING), "-Q", CAST(EXTRACT(QUARTER FROM date) AS STRING)) AS quarter_desc, CONCAT(CAST(EXTRACT(YEAR FROM date) AS STRING), "-","W",CAST(FORMAT_DATE("%V", date) AS INT64)) AS week_desc, CASE WHEN EXTRACT(DAYOFWEEK FROM date) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend, justfunctions.eu.find_season(date).season season, justfunctions.eu.find_season(date).start_of_season start_of_season , holiday_name, holiday_country, special_day_name,justfunctions.eu.find_moon_illumination(date) moon_illumination FROM date_range d LEFT JOIN (SELECT * FROM justfunctions.eu.date_holidays WHERE holiday_country=UPPER("' || country || '")) dh ON dh.holiday_date=d.date LEFT JOIN justfunctions.eu.date_special_days sd ON sd.special_day_date=d.date;';


END;
```
**Example Query**:

```sql
CALL `justfunctions.eu.generate_date_calendar_with_holidays`("justfunctions.test.date_calendar","2020-01-01","2030-01-01","GR")
```

**Example Output**:

```
- date_id: 20200101
- date: 2020-01-01
- epoch: 1577836800
- day_suffix: 1th
- day_name: Wednesday
- day_name_abbr: Wed
- day_of_week: 4
- day_of_month: 1
- day_of_quarter: 1
- day_of_year: 1
- week_of_month: 1
- week_of_year: 1
- week_of_year_iso: 2020-W01-3
- month: 1
- month_name: January
- month_name_abbr: Jan
- quarter: 1
- quarter_name: Q1
- year: 2020
- start_of_week: 2019-12-30
- start_of_week_saturday: 2019-12-28
- start_of_month: 2020-01-01
- start_of_midmonth: 2020-01-15
- start_of_quarter: 2020-01-01
- start_of_year: 2020-01-01
- end_of_week: 2020-01-03
- end_of_month: 2020-01-31
- end_of_quarter: 2020-03-31
- end_of_year: 2020-12-31
- start_of_fiscal_year: 2019-10-01
- end_of_fiscal_year: 2020-09-30
- yyyymm: 202001
- yyyymmdd: 20200101
- month_desc: 2020-Jan
- quarter_desc: 2020-Q1
- week_desc: 2020-W1
- is_weekend: FALSE
- season: Winter
- start_of_season: 2019-12-01
- holiday_name: Πρωτοχρονιά
- holiday_country: gr
- special_day_name : New Year's Day
- moon_illumination : 29.95

```
---
## <a id='generate_hour_calendar'></a>8. generate_hour_calendar(table_name)

- **Type**: PROCEDURE
- **Tags**: operations, date
- **Region**: us,eu
- **Description**: Generates an hourly calendar table named <table_name> for a 24-hour day.

```sql
CREATE OR REPLACE PROCEDURE `justfunctions.eu.generate_hour_calendar`(`table_name` string)
options(
    description = '''Generates an hourly calendar table named <table_name> for a 24-hour day.'''
)
BEGIN

-- Drop the table if it exists
EXECUTE IMMEDIATE 'DROP TABLE IF EXISTS ' || table_name;

-- Create the hour_calendar table
EXECUTE IMMEDIATE 'CREATE TABLE ' || table_name || ' (hour_id STRING NOT NULL, hour_24 INT64 NOT NULL, hour_12 INT64 NOT NULL, am_pm STRING NOT NULL, is_business_hour BOOL, part_of_day STRING);';

-- Populate the table with static insert statements
-- EXECUTE IMMEDIATE 'INSERT INTO ' || table_name || ' (hour_id, hour_24, hour_12, am_pm, is_business_hour, part_of_day) WITH hours AS (SELECT hour, FORMAT("%02d", hour) as hour_id, CASE WHEN hour = 0 THEN 12 WHEN hour > 12 THEN hour - 12 ELSE hour END as hour_12, CASE WHEN hour < 12 THEN "am" ELSE "pm" END as am_pm FROM UNNEST(GENERATE_ARRAY(0, 23)) as hour) SELECT hour_id, hour, hour_12, am_pm, CASE WHEN hour_id BETWEEN "09" AND "17" THEN TRUE ELSE FALSE END as is_business_hour, CASE WHEN hour_id BETWEEN "00" AND "05" THEN "Night" WHEN hour_id BETWEEN "06" AND "11" THEN "Morning" WHEN hour_id BETWEEN "12" AND "17" THEN "Afternoon" ELSE "Evening" END as part_of_day FROM hours;';

EXECUTE IMMEDIATE 
'INSERT INTO ' || table_name || ' (hour_id, hour_24, hour_12, am_pm, is_business_hour, part_of_day) VALUES ' ||
'("00", 0, 12, "am", FALSE, "Night"), ' ||
'("01", 1, 1, "am", FALSE, "Night"), ' ||
'("02", 2, 2, "am", FALSE, "Night"), ' ||
'("03", 3, 3, "am", FALSE, "Night"), ' ||
'("04", 4, 4, "am", FALSE, "Night"), ' ||
'("05", 5, 5, "am", FALSE, "Night"), ' ||
'("06", 6, 6, "am", FALSE, "Morning"), ' ||
'("07", 7, 7, "am", TRUE, "Morning"), ' ||
'("08", 8, 8, "am", TRUE, "Morning"), ' ||
'("09", 9, 9, "am", TRUE, "Morning"), ' ||
'("10", 10, 10, "am", TRUE, "Morning"), ' ||
'("11", 11, 11, "am", TRUE, "Morning"), ' ||
'("12", 12, 12, "pm", TRUE, "Afternoon"), ' ||
'("13", 13, 1, "pm", TRUE, "Afternoon"), ' ||
'("14", 14, 2, "pm", TRUE, "Afternoon"), ' ||
'("15", 15, 3, "pm", TRUE, "Afternoon"), ' ||
'("16", 16, 4, "pm", TRUE, "Afternoon"), ' ||
'("17", 17, 5, "pm", TRUE, "Afternoon"), ' ||
'("18", 18, 6, "pm", FALSE, "Evening"), ' ||
'("19", 19, 7, "pm", FALSE, "Evening"), ' ||
'("20", 20, 8, "pm", FALSE, "Evening"), ' ||
'("21", 21, 9, "pm", FALSE, "Evening"), ' ||
'("22", 22, 10, "pm", FALSE, "Evening"), ' ||
'("23", 23, 11, "pm", FALSE, "Night");';


END;
```
**Example Query**:

```sql
CALL `justfunctions.eu.generate_hour_calendar`("justfunctions.test.hour_calendar")
```

**Example Output**:

```
- hour_id: "00"
- hour_24: 0
- hour_12: 12
- am_pm: am
- is_business_hour: FALSE
- part_of_day: Night

```
---
## <a id='seconds_to_date'></a>9. seconds_to_date(seconds)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Converts <seconds> to date format '%Y-%m-%d'.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.seconds_to_date`(`seconds` INT64) 
  RETURNS DATE AS (DATE(FORMAT_DATE('%Y-%m-%d',TIMESTAMP_SECONDS(seconds))))
  OPTIONS ( description = '''Converts <seconds> to date format '%Y-%m-%d'.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.seconds_to_date`("1687613655")
```

**Example Output**:

```
2023-06-24
```
---
## <a id='seconds_to_timestamp'></a>10. seconds_to_timestamp(seconds)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Converts <seconds> to timestamp format '%Y-%m-%d %H:%M:%S'.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.seconds_to_timestamp`(`seconds` INT64) 
  RETURNS TIMESTAMP AS (TIMESTAMP(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_SECONDS(seconds))))
  OPTIONS ( description = '''Converts <seconds> to timestamp format '%Y-%m-%d %H:%M:%S'.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.seconds_to_timestamp`("1687613655")
```

**Example Output**:

```
2023-06-24 13:00:01 UTC
```
---
## <a id='shift_date'></a>11. shift_date(date, years, months, days)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Shifts a <date> by adding or subtracting specified <years>, <months>, and <days>. Use a minus (-) to subtract.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.shift_date`(`date` DATE, `years` INT64, `months` INT64, `days` INT64) 
  RETURNS DATE AS (DATE_ADD(
  DATE_ADD(
    DATE_ADD(
      date,
      INTERVAL years YEAR
    ),
    INTERVAL months MONTH
  ),
  INTERVAL days DAY
)
)
  OPTIONS ( description = '''Shifts a <date> by adding or subtracting specified <years>, <months>, and <days>. Use a minus (-) to subtract.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.shift_date`("2023-01-01","-2","1","4")
```

**Example Output**:

```
2021-02-05
```
---
## <a id='timestamp_to_string'></a>12. timestamp_to_string(timestamp)

- **Type**: SQL
- **Tags**: date
- **Region**: us,eu
- **Description**: Converts a <timestamp> to string format '%Y-%m-%d %H:%M:%S'.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.timestamp_to_string`(`timestamp` TIMESTAMP) 
  RETURNS STRING AS (FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', timestamp))
  OPTIONS ( description = '''Converts a <timestamp> to string format '%Y-%m-%d %H:%M:%S'.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.timestamp_to_string`("2023-06-24 13:01:02 UTC")
```

**Example Output**:

```
2023-06-24 13:01:02
```
---
## <a id='convert_json_to_struct'></a>13. convert_json_to_struct(string)

- **Type**: JS
- **Tags**: operations, text
- **Region**: us,eu
- **Description**: Converts a JSON <string> to a STRUCT data type.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.convert_json_to_struct`(`string` string) RETURNS ARRAY<STRUCT<key STRING, value STRING>>
	LANGUAGE js AS r'''try {
  var obj = JSON.parse(string);
  var keys = Object.keys(obj);
  var arr = [];
  for (i = 0; i < keys.length; i++) {
      arr.push({'key': keys[i], 'value': JSON.stringify(obj[keys[i]])});
  }
  return arr;
} catch(e) {
    return '{}';
}
''' OPTIONS ( description = '''Converts a JSON <string> to a STRUCT data type.'''  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.convert_json_to_struct`("{'time': {'new_value': '17:00', 'old_value': '16:30'}, 'price': {'new_value': '1', 'old_value': '2'}}")
```

**Example Output**:

```
- time: {"new_value":"17:00","old_value":"16:30"}
- price: {"new_value":"1","old_value":"2"}

```
---
## <a id='dedup_table'></a>14. dedup_table(table_name, timestamp_column, unique_column, output_table_suffix)

- **Type**: PROCEDURE
- **Tags**: operations
- **Region**: us,eu
- **Description**: Creates a deduplicated version of the table <table_name>, retaining the latest row based on the <timestamp_column>, and outputs it with the suffix <output_table_suffix>. Arguments <timestamp_column>, <unique_column>, <output_table_suffix> are optional.

```sql
CREATE OR REPLACE PROCEDURE `justfunctions.eu.dedup_table`(`table_name` string, `timestamp_column` string, `unique_column` string, `output_table_suffix` string)
options(
    description = '''Creates a deduplicated version of the table <table_name>, retaining the latest row based on the <timestamp_column>, and outputs it with the suffix <output_table_suffix>. Arguments <timestamp_column>, <unique_column>, <output_table_suffix> are optional.'''
)
BEGIN

DECLARE sql STRING;
DECLARE final_table_name STRING;

SET final_table_name = CONCAT(table_name, IF(output_table_suffix != '', output_table_suffix, '_dedup'));

IF unique_column = '' AND timestamp_column = '' THEN
  SET sql = FORMAT("""
    CREATE OR REPLACE TABLE %s AS
    SELECT DISTINCT *
    FROM %s;
  """, final_table_name, table_name);
ELSEIF unique_column != '' AND timestamp_column = '' THEN
  SET sql = FORMAT("""
    CREATE OR REPLACE TABLE %s AS
    SELECT * EXCEPT(row_num)
    FROM (
      SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY %s) AS row_num
      FROM
        %s
    )
    WHERE row_num = 1;
  """, final_table_name, unique_column, table_name);
ELSE
  SET sql = FORMAT("""
    CREATE OR REPLACE TABLE %s AS
    SELECT * EXCEPT(row_num)
    FROM (
      SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY %s ORDER BY %s DESC) AS row_num
      FROM
        %s
    )
    WHERE row_num = 1;
  """, final_table_name, unique_column, timestamp_column, table_name);
END IF;

EXECUTE IMMEDIATE sql;


END;
```
**Example Query**:

```sql
CALL `justfunctions.eu.dedup_table`("your_project.your_dataset.your_table","created_at","user_id","_dedup")
```

**Example Output**:

```
your_project.your_dataset.your_table.your_table_dedup
```
---
## <a id='generate_dbt_yml_schema'></a>15. generate_dbt_yml_schema(project_id, dataset_id)

- **Type**: SQL
- **Tags**: operations
- **Region**: us,eu
- **Description**: Generates a DBT schema.yml using the information_schema of the generated tables for the specified <project_id> and <dataset_id>. For this function to work you need to create your own function in your dataset.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.generate_dbt_yml_schema`(`project_id` string, `dataset_id` string) 
  RETURNS string AS ((with columns as (
    select '- name: ' || column_name || '' as column_statement,
        table_name
    from `justfunctions.eu`.INFORMATION_SCHEMA.COLUMNS

),
tables as (
select table_name,
"  - name: " || table_name || "\n" ||
"    columns:\n" ||
string_agg('      ' || column_statement, "\n") as yml_file
from columns
group by table_name
order by table_name
)
select
"version: 2\n" ||
"\n" ||
"models:\n" ||
string_agg(yml_file, "\n") as yml_file
from tables)
)
  OPTIONS ( description = '''Generates a DBT schema.yml using the information_schema of the generated tables for the specified <project_id> and <dataset_id>. For this function to work you need to create your own function in your dataset.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.generate_dbt_yml_schema`("justfunctions","eu")
```

**Example Output**:

```
version: 2
models: - name: country_distinct columns: - name: service_country - name: official_name - name: alpha_2 
```
---
## <a id='generate_justsql_schema'></a>16. generate_justsql_schema(project_id, dataset_id, tables)

- **Type**: PROCEDURE
- **Tags**: operations
- **Region**: us,eu
- **Description**: Generates a JSON schema for use with JustSQL GPT using the specified <project_id>, <dataset_id>, and list of <tables> (https://chat.openai.com/g/g-hzlGYume7-justsql-for-bigquery).

```sql
CREATE OR REPLACE PROCEDURE `justfunctions.eu.generate_justsql_schema`(`project_id` string, `dataset_id` string, `tables` array<string>)
options(
    description = '''Generates a JSON schema for use with JustSQL GPT using the specified <project_id>, <dataset_id>, and list of <tables> (https://chat.openai.com/g/g-hzlGYume7-justsql-for-bigquery).'''
)
BEGIN

DECLARE query_string STRING;
DECLARE json_schema STRING DEFAULT '';
DECLARE tables_string STRING;

SET tables_string = ARRAY_TO_STRING(ARRAY(SELECT '\'' || x || '\'' FROM UNNEST(tables) AS x), ',');

SET query_string = CONCAT(
  'SELECT ',
  'CONCAT(\'{ "tables": [\', STRING_AGG(table_schema_, \',\' ORDER BY table_name), \'] }\' ) AS json_schema ',
  'FROM (  SELECT  table_name,table_schema,table_catalog,',
  'CONCAT(\'{ "table_name": "\', CONCAT(table_catalog,\'.\',table_schema,\'.\',table_name), \'", "columns": [\', STRING_AGG(CONCAT(\'{ "name": "\',column_name,\'","type":"\',data_type,\'"}\'), \',\'),\'] }\') AS table_schema_ ',
  'FROM \`',project_id,'.',dataset_id,'.INFORMATION_SCHEMA.COLUMNS\` ',
  'WHERE table_name IN (', tables_string, ') ',
  'GROUP BY 1,2,3 ) A'
);

EXECUTE IMMEDIATE query_string INTO json_schema;
SELECT json_schema;


END;
```
**Example Query**:

```sql
CALL `justfunctions.eu.generate_justsql_schema`("justfunctions","eu","['date_calendar']")
```

**Example Output**:

```
{ "tables": [{ "table_name": "justfunctions.eu.date_calendar", "columns": [{ "name": "date","type":"DATE"},{ "name": "Quarter","type":"STRING"},{ "name": "month_name","type":"STRING"},{ "name": "epoch","type":"INT64"},{ "name": "date_id","type":"INT64"},{ "name": "day_of_month","type":"INT64"},{ "name": "day_suffix","type":"STRING"}] }] }
```
---
## <a id='greatest_not_null'></a>17. greatest_not_null(arr)

- **Type**: SQL
- **Tags**: operations
- **Region**: us,eu
- **Description**: This SQL function returns the greatest (maximum) value among multiple columns in the array <arr>, while properly handling NULL values.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.greatest_not_null`(`arr` any type)  AS ((SELECT max(a) FROM UNNEST(arr) a WHERE a is not NULL)
)
  OPTIONS ( description = '''This SQL function returns the greatest (maximum) value among multiple columns in the array <arr>, while properly handling NULL values.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.greatest_not_null`("['col_1', 'col_2', 'col_3']")
```

**Example Output**:

```
1
```
---
## <a id='least_not_null'></a>18. least_not_null(arr)

- **Type**: SQL
- **Tags**: operations
- **Region**: us,eu
- **Description**: This SQL function returns the least (minimum) value among multiple columns in the array <arr>, while properly handling NULL values.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.least_not_null`(`arr` any type)  AS ((SELECT min(a) FROM UNNEST(arr) a WHERE a is not NULL)
)
  OPTIONS ( description = '''This SQL function returns the least (minimum) value among multiple columns in the array <arr>, while properly handling NULL values.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.least_not_null`("['col_1', 'col_2', 'col_3']")
```

**Example Output**:

```
1
```
---
## <a id='parse_yaml'></a>19. parse_yaml(string)

- **Type**: JS
- **Tags**: operations, text
- **Region**: us,eu
- **Description**: Converts a YAML <string> to JSON format.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.parse_yaml`(`string` string) RETURNS json
	LANGUAGE js AS r'''try {
  return jsyaml.load(string);
} catch(e) {
  return '{}';
}
''' OPTIONS ( description = '''Converts a YAML <string> to JSON format.'''  , library = [  "gs://justfunctions/bigquery-functions/js-yaml.min.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.parse_yaml`("--- updated_at: - 2023-11-12 08:08:25.291779000 Z - 2023-11-12 08:25:18.648572080 Z status: - new - canceled ")
```

**Example Output**:

```
{'status': ['new', 'canceled'], 'updated_at': ['2023-11-12T08:08:25.291Z', '2023-11-12T08:25:18.648Z']}
```
---
## <a id='safe_least'></a>20. safe_least(x, y)

- **Type**: SQL
- **Tags**: operations
- **Region**: us,eu
- **Description**: Safely compares two values <x> and <y> and returns the lesser of the two while properly handling NULL values.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.safe_least`(`x` any type, `y` any type)  AS (CASE
  WHEN x IS NULL AND y IS NULL THEN NULL
  WHEN x IS NULL THEN y
  WHEN y IS NULL THEN x
  ELSE LEAST(x, y)
END
)
  OPTIONS ( description = '''Safely compares two values <x> and <y> and returns the lesser of the two while properly handling NULL values.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.safe_least`("1","None")
```

**Example Output**:

```
1
```
---
## <a id='detect_outlier_iqr'></a>21. detect_outlier_iqr(value, value_percentile_25, value_percentile_75)

- **Type**: SQL
- **Tags**: STATISTICS
- **Region**: us,eu
- **Description**: Detects if a <value> is an outlier based on the IQR method, using the 25th percentile <value_percentile_25> and 75th percentile <value_percentile_75>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.detect_outlier_iqr`(`value` FLOAT64, `value_percentile_25` FLOAT64, `value_percentile_75` FLOAT64) 
  RETURNS INT64 AS (CASE 
WHEN 
value < value_percentile_25 - 1.5 * (value_percentile_75 - value_percentile_25) THEN -1
WHEN 
value > value_percentile_75 + 1.5 * (value_percentile_75 - value_percentile_25) THEN 1 
ELSE 0 
END
)
  OPTIONS ( description = '''Detects if a <value> is an outlier based on the IQR method, using the 25th percentile <value_percentile_25> and 75th percentile <value_percentile_75>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.detect_outlier_iqr`("5","2","14")
```

**Example Output**:

```
0
```
---
## <a id='percentile'></a>22. percentile(arr, percentile)

- **Type**: SQL
- **Tags**: STATISTICS, percentile
- **Region**: us,eu
- **Description**: Finds the specified <percentile> of an array <arr>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.percentile`(`arr` array<float64>, `percentile` int) 
  RETURNS float64 AS ((
SELECT
COALESCE(arr[SAFE_OFFSET(CAST(ARRAY_LENGTH(arr)*percentile/100 AS INT)-1)],COALESCE(arr[SAFE_OFFSET (0)],999))
FROM (SELECT ARRAY_AGG(x IGNORE NULLS ORDER BY x) AS arr FROM UNNEST(arr) AS x)
)
)
  OPTIONS ( description = '''Finds the specified <percentile> of an array <arr>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.percentile`("[1.2, 2.3, 3.2, 4.2, 5]")
```

**Example Output**:

```
3.2
```
---
## <a id='clean_email'></a>23. clean_email(email)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Converts an <email> address to lowercase and removes any sub-address (also known as plus addressing).

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.clean_email`(`email` STRING) 
  RETURNS STRING AS (LOWER(justfunctions.eu.remove_email_plus_address(email)))
  OPTIONS ( description = '''Converts an <email> address to lowercase and removes any sub-address (also known as plus addressing).''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.clean_email`("HeLLo+other@gmail.com")
```

**Example Output**:

```
hello@gmail.com
```
---
## <a id='clean_special_symbols'></a>24. clean_special_symbols(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Cleans special symbols in a <string> using custom symbols.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.clean_special_symbols`(`string` string) 
  RETURNS string AS (REGEXP_REPLACE(string, '''[^\\p{L}\\p{N}\\s]+''', ''))
  OPTIONS ( description = '''Cleans special symbols in a <string> using custom symbols.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.clean_special_symbols`("Vacation✈️ time!🌴😀🏖️")
```

**Example Output**:

```
vacation time
```
---
## <a id='clean_special_symbols_custom'></a>25. clean_special_symbols_custom(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Cleans special symbols in a <string> using custom symbols.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.clean_special_symbols_custom`(`string` string) 
  RETURNS string AS (REGEXP_REPLACE(string, r'[\'♥◄£⌠Æ`╥&è°Üε\^Ÿü▄¡↓\]▲¢>|Î¸.•¤→│®;…Œ§´ï›Ä√ß╝♪Ì℃Ò¨˜ò©à/┼≡"ÂÑ♠∟ƒ@▓ÕôÍⁿ┴╣“ž↔―╢╞\?™╤ð}¦—‡„╠³óÞ℉ÿ∙∩▀↨╫╒ÊÓù║<ÈÏ☺±╬▌â╪╘┘$Ë╓█÷Ý≤Ž╟#≥þÇ\(╨·\*⌡š†⌂œØ↕€♂╦’ã╖╔ÐÅ■ê”ú┬‼ç¿▒ª┌äÛ╕ÉÔºö♦ñÀ♀├↑╗ì\\╧♫╡○└Öý-←╚╩♣Ã¥å¬¯‰\[ˆû≈₧Š►▐∞!Ù,²▬î╛=×┐\:–─═‘◘é\+◙\)‹_Á{░Ú¹⌐ë»‚☼%╙▼~⊙á\'õø¶☻«┤æí]+', ''))
  OPTIONS ( description = '''Cleans special symbols in a <string> using custom symbols.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.clean_special_symbols_custom`("Vacation✈️ time!🌴😀🏖️")
```

**Example Output**:

```
vacation time
```
---
## <a id='clean_url'></a>26. clean_url(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Removes http://, ftp://, https://, the URL tail, and the last URL slash from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.clean_url`(`url` STRING) 
  RETURNS STRING AS (REGEXP_REPLACE(SPLIT(url,'?')[SAFE_OFFSET(0)],r'(https?|ftp):\/\/|\/$', ''))
  OPTIONS ( description = '''Removes http://, ftp://, https://, the URL tail, and the last URL slash from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.clean_url`("https://hey.com/me/?231#213")
```

**Example Output**:

```
hey.com/me
```
---
## <a id='decode_url'></a>27. decode_url(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Decodes a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.decode_url`(`url` STRING) 
  RETURNS STRING AS (((
  SELECT STRING_AGG(
    IF(REGEXP_CONTAINS(y, r'^%[0-9a-fA-F]{2}'), 
      SAFE_CONVERT_BYTES_TO_STRING(FROM_HEX(REPLACE(y, '%', ''))), y), '' 
    ORDER BY i
    )
  FROM UNNEST(REGEXP_EXTRACT_ALL(url, r"%[0-9a-fA-F]{2}(?:%[0-9a-fA-F]{2})*|[^%]+")) y
  WITH OFFSET AS i 
)))
  OPTIONS ( description = '''Decodes a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.decode_url`("https%3A%2F%2Fjustdataplease.com%2Fjustfunctions-bigquery%2F%3Futm_campaign%3Dtest")
```

**Example Output**:

```
https://justdataplease.com/justfunctions-bigquery/?utm_campaign=test
```
---
## <a id='dedup_chars'></a>28. dedup_chars(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Deduplicates characters in a <string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.dedup_chars`(`string` string) 
  RETURNS string AS ((SELECT
STRING_AGG(
  IF
    (c = SPLIT(string, '')[SAFE_OFFSET(off - 1)],
      NULL,
      c), '' ORDER BY off)
FROM
UNNEST(SPLIT(string, '')) AS c
WITH OFFSET off)
)
  OPTIONS ( description = '''Deduplicates characters in a <string>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.dedup_chars`("Helloooo!")
```

**Example Output**:

```
Helo!
```
---
## <a id='detect_department_email'></a>29. detect_department_email(email)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Detects if an <email> belongs to a business department (e.g., sales, HR, support).

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.detect_department_email`(`email` STRING) 
  RETURNS INT AS (((
     WITH A AS (SELECT SPLIT(email,"@")[offset(0)] email_part)

     SELECT 
     CASE 
        WHEN email_part IN (
           'info', 'test', 'hello', 'hey', 'help', 
           'press', 'support', 'sales', 'dev', 'developers', 'marketing', 
           'admin', 'hq', 'finance', 'operations', 'home', 'headquarters', 
           'jobs', 'main', 'here', 'one', 'hr', 'tech', 'billing', 
           'accounts', 'partnerships', 'team', 'contact',
           'feedback', 'legal', 'solutions', 'services', 'training', 
           'products', 'careers', 'service', 'management', 'events', 
           'subscriptions', 'media', 'research', 'security', 'investor', 
           'relations', 'customerservice',  'bookings', 'reservations', 
           'licensing', 'advertising', 'affiliates', 
           'design', 'editor', 'collaborations', 'solutions', 'analytics',
           'client', 'membership', 'strategy', 'businessdev', 'feedback', 
           'office', 'customer', 'cs', 'outreach') 
        OR REGEXP_CONTAINS(email_part,'support')
        THEN 1 ELSE 0 END is_department_email 
        FROM A 
)))
  OPTIONS ( description = '''Detects if an <email> belongs to a business department (e.g., sales, HR, support).''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.detect_department_email`("sales@dev.io")
```

**Example Output**:

```
1
```
---
## <a id='detect_free_email'></a>30. detect_free_email(email)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Detects if an <email> belongs to a free email service (e.g., Gmail, Yahoo, Outlook).

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.detect_free_email`(`email` STRING) 
  RETURNS INT AS (justfunctions.eu.detect_free_email_domain(
      justfunctions.eu.extract_url_domain_base(email)
))
  OPTIONS ( description = '''Detects if an <email> belongs to a free email service (e.g., Gmail, Yahoo, Outlook).''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.detect_free_email`("jason@gmail.com")
```

**Example Output**:

```
1
```
---
## <a id='detect_free_email_domain'></a>31. detect_free_email_domain(email_domain)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Detects if an <email_domain> belongs to a free email service (e.g., Gmail, Yahoo, Outlook).

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.detect_free_email_domain`(`email_domain` STRING) 
  RETURNS INT AS ((SELECT CASE WHEN CHAR_LENGTH(email_domain)<=1 OR LOWER(email_domain) IN ('10minutemail', '126', '21cn', '33mail', 'alice', 'aliyun', 'aol', 'arnet', 'att', 'bell', 'bellsouth', 'binkmail', 'bluewin', 'blueyonder', 'bol', 'bt', 'btinternet', 'burnermail', 'charter', 'club', 'cock', 'comcast', 'cox', 'daum', 'deadaddress', 'disroot', 'dropmail', 'e4ward', 'earthlink', 'email', 'eu', 'fakeinbox', 'fakemailgenerator', 'fastmail', 'fibertel', 'foxmail', 'free', 'freenet', 'freeserve', 'games', 'getnada', 'gishpuppy', 'globo', 'globomail', 'gmail', 'gmx', 'googlemail', 'guerrillamail', 'hanmail', 'hotmail','windowslive', 'hush', 'hushmail', 'icloud', 'ig', 'iname', 'inbox', 'inboxalias', 'incognitomail', 'itelefonica', 'jetable', 'juno', 'keemail', 'laposte', 'lavabit', 'libero', 'list', 'live', 'love', 'mac', 'mail', 'mail2world', 'mailblocks', 'mailcatch', 'maildrop', 'mailexpire', 'mailfence', 'mailinator', 'mailmoat', 'mailnesia', 'mailnull', 'mailoo', 'me', 'mintemail', 'moakt', 'mohmal', 'msn', 'myspamless', 'mytrashmail', 'nate', 'naver', 'neuf', 'neverbox', 'nomail', 'notsharingmy', 'ntlworld', 'nym', 'o2', 'oi', 'onet', 'online', 'orange', 'outlook', 'pobox', 'pookmail', 'poste', 'posteo', 'prodigy', 'proton', 'qq', 'r7', 'rambler', 'rediffmail', 'rocketmail', 'rogers', 'runbox', 'safe-mail', 'sbcglobal', 'seznam', 'sfr', 'shaw', 'shieldemail', 'sina', 'sky', 'skynet', 'sohu', 'spam', 'spambog', 'spambox', 'spamcowboy', 'spamevader', 'spamex', 'spamgourmet', 'spamhole', 'spaml', 'spamoff', 'spamspot', 'spamthis', 'speedy', 'startmail', 'sympatico', 't-online', 'talktalk', 'techemail', 'telenet', 'teletu', 'temp', 'tempinbox', 'tempmail', 'temporaryemail', 'terra', 'thisisnotmyrealemail', 'throwawaymail', 'tin', 'tiscali', 'trashmail', 'tuta', 'tutamail', 'tutanota', 'tvcablenet', 'uol', 'verizon', 'vfemail', 'virgilio', 'virgin', 'voo', 'walla', 'wanadoo', 'web', 'wow', 'ya', 'yahoo', 'yandex', 'yeah', 'ygm', 'ymail', 'yopmail', 'zipmail', 'zoho') OR REGEXP_CONTAINS(email_domain,r'[0-9]') THEN 1 ELSE 0 END ))
  OPTIONS ( description = '''Detects if an <email_domain> belongs to a free email service (e.g., Gmail, Yahoo, Outlook).''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.detect_free_email_domain`("gmail")
```

**Example Output**:

```
1
```
---
## <a id='detect_useragent_device_type'></a>32. detect_useragent_device_type(useragent)

- **Type**: SQL
- **Tags**: text, useragent
- **Region**: us,eu
- **Description**: Detects the device type from a <useragent> string. It can be a tablet, mobile, PC, TV, or other.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.detect_useragent_device_type`(`useragent` STRING) 
  RETURNS STRING AS (CASE 
  WHEN REGEXP_CONTAINS(useragent, r'(?i)(iPad|Tablet|Kindle|Tab|GT-P)') THEN 'tablet'
  WHEN REGEXP_CONTAINS(useragent, r'(?i)(Android)') AND NOT REGEXP_CONTAINS(useragent, r'(?i)(Mobile)') THEN 'tablet' 
  WHEN REGEXP_CONTAINS(useragent, r'(?i)(Mobile|iPhone|Android|Windows Phone)') THEN 'mobile'
  WHEN REGEXP_CONTAINS(useragent, r'(?i)(SmartTV|AppleTV|GoogleTV|HbbTV|netcast|NETTV|OpenTV|Tizen|Web0S|SonyDTV)') THEN 'tv'
  WHEN REGEXP_CONTAINS(useragent, r'(?i)(Windows NT|Macintosh|Linux|X11)') THEN 'pc'
  ELSE 'other'
END
)
  OPTIONS ( description = '''Detects the device type from a <useragent> string. It can be a tablet, mobile, PC, TV, or other.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.detect_useragent_device_type`("Mozilla/5.0 (iPad; CPU OS 12_5_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1")
```

**Example Output**:

```
tablet
```
---
## <a id='extract_all_url_parameters'></a>33. extract_all_url_parameters(url)

- **Type**: JS
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts all parameters from a <url> in JSON format.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_all_url_parameters`(`url` STRING) RETURNS JSON
	LANGUAGE js AS r'''// Remove the fragment identifier (everything after '#')
var main_part = url.split('#')[0];

// Extract the query string part
var query_string = main_part.split('?')[1];
var params = query_string.split('&');
var obj = {};
for(var i = 0; i < params.length; i++) {
  var keyValue = params[i].split('=');
  obj[keyValue[0]] = keyValue[1];
}
return obj;
''' OPTIONS ( description = '''Extracts all parameters from a <url> in JSON format.'''  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_all_url_parameters`("justdataplease.com/test/?medium=cpc&source=google&keyword=hey&source=facebook")
```

**Example Output**:

```
{"keyword":"hey","medium":"cpc","source":"facebook"}
```
---
## <a id='extract_email_domain'></a>34. extract_email_domain(url)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Extracts the domain from an <email>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_email_domain`(`url` STRING) 
  RETURNS STRING AS (NET.REG_DOMAIN(url))
  OPTIONS ( description = '''Extracts the domain from an <email>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_email_domain`("jason@justdataplease.com")
```

**Example Output**:

```
justdataplease.com
```
---
## <a id='extract_email_domain_base'></a>35. extract_email_domain_base(url)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Extracts the base domain from an <email>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_email_domain_base`(`url` STRING) 
  RETURNS STRING AS (REPLACE (NET.REG_DOMAIN(url), CONCAT('.',NET.PUBLIC_SUFFIX(url)),""))
  OPTIONS ( description = '''Extracts the base domain from an <email>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_email_domain_base`("jason@justdataplease.com")
```

**Example Output**:

```
justdataplease
```
---
## <a id='extract_url_domain'></a>36. extract_url_domain(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the domain from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_domain`(`url` STRING) 
  RETURNS STRING AS (NET.REG_DOMAIN(url))
  OPTIONS ( description = '''Extracts the domain from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_domain`("https://hey.com/me/?231#213")
```

**Example Output**:

```
hey.com
```
---
## <a id='extract_url_domain_base'></a>37. extract_url_domain_base(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the base domain from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_domain_base`(`url` STRING) 
  RETURNS STRING AS (REPLACE (NET.REG_DOMAIN(url), CONCAT('.',NET.PUBLIC_SUFFIX(url)),""))
  OPTIONS ( description = '''Extracts the base domain from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_domain_base`("https://hey.com/me/?231#213")
```

**Example Output**:

```
hey
```
---
## <a id='extract_url_language'></a>38. extract_url_language(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the language from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_language`(`url` STRING) 
  RETURNS STRING AS (CASE 
  -- North America
  WHEN REGEXP_CONTAINS(url, '/en(-[A-Za-z]{2})?/') THEN 'english'
  WHEN REGEXP_CONTAINS(url, '/es/') THEN 'spanish'

  -- Europe
  WHEN REGEXP_CONTAINS(url, '/fr/') THEN 'french'
  WHEN REGEXP_CONTAINS(url, '/de/') THEN 'german'
  WHEN REGEXP_CONTAINS(url, '/it/') THEN 'italian'
  WHEN REGEXP_CONTAINS(url, '/ru/') THEN 'russian'
  WHEN REGEXP_CONTAINS(url, '/pt-pt/') THEN 'portuguese'
  WHEN REGEXP_CONTAINS(url, '/el/') THEN 'greek'
  WHEN REGEXP_CONTAINS(url, '/sv-') THEN 'swedish'
  WHEN REGEXP_CONTAINS(url, '/pl/') THEN 'polish'
  WHEN REGEXP_CONTAINS(url, '/tr/') THEN 'turkish'
  WHEN REGEXP_CONTAINS(url, '/nl/') THEN 'dutch'
  WHEN REGEXP_CONTAINS(url, '/uk/') THEN 'ukrainian'
  WHEN REGEXP_CONTAINS(url, '/cs/') THEN 'czech'
  WHEN REGEXP_CONTAINS(url, '/da/') THEN 'danish'
  WHEN REGEXP_CONTAINS(url, '/fi/') THEN 'finnish'
  WHEN REGEXP_CONTAINS(url, '/hu/') THEN 'hungarian'
  WHEN REGEXP_CONTAINS(url, '/ro/') THEN 'romanian'
  WHEN REGEXP_CONTAINS(url, '/sk/') THEN 'slovak'
  WHEN REGEXP_CONTAINS(url, '/pt/') THEN 'portuguese'

  -- Asia
  WHEN REGEXP_CONTAINS(url, '/ar/') THEN 'arabic'
  WHEN REGEXP_CONTAINS(url, '/zh(-[A-Za-z]{2,5})?/') THEN 'chinese'
  WHEN REGEXP_CONTAINS(url, '/ja/') THEN 'japanese'
  WHEN REGEXP_CONTAINS(url, '/ko/') THEN 'korean'
  WHEN REGEXP_CONTAINS(url, '/hi/') THEN 'hindi'
  WHEN REGEXP_CONTAINS(url, '/ur/') THEN 'urdu'
  WHEN REGEXP_CONTAINS(url, '/bn/') THEN 'bengali'
  WHEN REGEXP_CONTAINS(url, '/fa/') THEN 'persian'
  WHEN REGEXP_CONTAINS(url, '/ta/') THEN 'tamil'
  WHEN REGEXP_CONTAINS(url, '/vi/') THEN 'vietnamese'
  WHEN REGEXP_CONTAINS(url, '/th/') THEN 'thai'
  WHEN REGEXP_CONTAINS(url, '/id/') THEN 'indonesian'
  WHEN REGEXP_CONTAINS(url, '/ms/') THEN 'malay'

  -- Africa
  WHEN REGEXP_CONTAINS(url, '/ar/') THEN 'arabic'  -- Arabic is also spoken widely in North Africa

  -- South America
  -- Spanish and Portuguese are majorly spoken here and are already added above

  -- Oceania
  -- English is a major language here and is already added above

  ELSE 'unknown'
END
)
  OPTIONS ( description = '''Extracts the language from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_language`("www.justdataplease.com/en-US/")
```

**Example Output**:

```
english
```
---
## <a id='extract_url_parameter'></a>39. extract_url_parameter(url, parameter)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the value of a specified <parameter> from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_parameter`(`url` STRING, `parameter` STRING) 
  RETURNS STRING AS (REGEXP_EXTRACT(url, "[?&]" || parameter || "=([^&]+)"))
  OPTIONS ( description = '''Extracts the value of a specified <parameter> from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_parameter`("www.google.com?medium=cpc&source=google&keyword=hey&source=facebook","source")
```

**Example Output**:

```
facebook
```
---
## <a id='extract_url_path'></a>40. extract_url_path(url, clean_url_tail)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the URL path from a <url>, optionally removing the URL tail.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_path`(`url` STRING, `clean_url_tail` BOOL) 
  RETURNS STRING AS (CASE WHEN clean_url_tail THEN 
  SPLIT(SPLIT(SPLIT(url,NET.HOST(url))[SAFE_OFFSET(1)],'?')[SAFE_OFFSET(0)],'#')[SAFE_OFFSET(0)]
ELSE
  SPLIT(url,NET.HOST(url))[SAFE_OFFSET(1)]
END)
  OPTIONS ( description = '''Extracts the URL path from a <url>, optionally removing the URL tail.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_path`("https://hey.com/me/?parameter=1","True")
```

**Example Output**:

```
/me/
```
---
## <a id='extract_url_prefix'></a>41. extract_url_prefix(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the URL prefix from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_prefix`(`url` STRING) 
  RETURNS STRING AS (SPLIT(url,".")[OFFSET(0)])
  OPTIONS ( description = '''Extracts the URL prefix from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_prefix`("https://en.hey.com/me/?231#213")
```

**Example Output**:

```
en
```
---
## <a id='extract_url_suffix'></a>42. extract_url_suffix(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the URL suffix from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_suffix`(`url` STRING) 
  RETURNS STRING AS (NET.PUBLIC_SUFFIX(url))
  OPTIONS ( description = '''Extracts the URL suffix from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_suffix`("https://en.hey.com/me/?231#213")
```

**Example Output**:

```
com
```
---
## <a id='extract_url_tail'></a>43. extract_url_tail(url)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Extracts the URL tail from a <url>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.extract_url_tail`(`url` STRING) 
  RETURNS STRING AS (SPLIT(url,'?')[SAFE_OFFSET(1)])
  OPTIONS ( description = '''Extracts the URL tail from a <url>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.extract_url_tail`("https://hey.com/me/?parameter=1")
```

**Example Output**:

```
parameter=1
```
---
## <a id='fuzzy_distance_dam'></a>44. fuzzy_distance_dam(string_1, string_2)

- **Type**: JS
- **Tags**: text, similarity
- **Region**: us,eu
- **Description**: Calculates Damerau-Levenshtein distance between <string_1> and <string_2>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.fuzzy_distance_dam`(`string_1` STRING, `string_2` STRING) RETURNS INT64
	LANGUAGE js AS r'''const initMatrix = (string_1, string_2) => {
  if (undefined == string_1 || undefined == string_2) {
    return null;
  }
  let d = [];
  for (let i = 0; i <= string_1.length; i++) {
    d[i] = [];
    d[i][0] = i;
  }
  for (let j = 0; j <= string_2.length; j++) {
    d[0][j] = j;
  }
  return d;
};
const damerau = (i, j, string_1, string_2, d, cost) => {
  if (i > 1 && j > 1 && string_1[i - 1] === string_2[j - 2] && string_1[i - 2] === string_2[j - 1]) {
    d[i][j] = Math.min.apply(null, [d[i][j], d[i - 2][j - 2] + cost]);
  }
};
if (
  undefined == string_1 ||
  undefined == string_2 ||
  "string" !== typeof string_1 ||
  "string" !== typeof string_2
) {
  return -1;
}
let d = initMatrix(string_1, string_2);
if (null === d) {
  return -1;
}
for (var i = 1; i <= string_1.length; i++) {
  let cost;
  for (let j = 1; j <= string_2.length; j++) {
    if (string_1.charAt(i - 1) === string_2.charAt(j - 1)) {
      cost = 0;
    } else {
      cost = 1;
    }
    d[i][j] = Math.min.apply(null, [
      d[i - 1][j] + 1,
      d[i][j - 1] + 1,
      d[i - 1][j - 1] + cost
    ]);
    damerau(i, j, string_1, string_2, d, cost);
  }
}
return d[string_1.length][string_2.length];''' OPTIONS ( description = '''Calculates Damerau-Levenshtein distance between <string_1> and <string_2>.'''  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.fuzzy_distance_dam`("pyhtno","python")
```

**Example Output**:

```
2
```
---
## <a id='fuzzy_distance_leven'></a>45. fuzzy_distance_leven(string_1, string_2)

- **Type**: JS
- **Tags**: text, similarity
- **Region**: us,eu
- **Description**: Calculates Levenshtein distance between <string_1> and <string_2>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.fuzzy_distance_leven`(`string_1` STRING, `string_2` STRING) RETURNS INT64
	LANGUAGE js AS r'''return fuzzball.distance(string_1,string_2);''' OPTIONS ( description = '''Calculates Levenshtein distance between <string_1> and <string_2>.'''  , library = [  "gs://justfunctions/bigquery-functions/fuzzball.umd.min.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.fuzzy_distance_leven`("pyhtno","python")
```

**Example Output**:

```
3
```
---
## <a id='fuzzy_nysiis'></a>46. fuzzy_nysiis(string)

- **Type**: SQL
- **Tags**: text, similarity
- **Region**: us,eu
- **Description**: Calculates NYSIIS code for <string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.fuzzy_nysiis`(`string` STRING) 
  RETURNS STRING AS (((
select
  string_agg(c, "" order by off asc)
from (select
        c,
        off,
        coalesce(lag(c) over (order by off) = c, false) as same_as_prev_char
      from unnest(split((select
              regexp_replace(regexp_replace(regexp_replace(string_agg(new_c, "" order by off), r"s+$", ""), "ay$", "y"), "a+$", "") as step_7
            from (select
                    c,
                    if(off = 0, c, 
                    case 
                      when off != 0 and c = 'e' and next_c = 'v' then 'a'
                      when off != 1 and c = 'v' and prev_c = 'e' then 'f'

                      when c in ('a', 'e', 'i', 'o', 'u') then 'a'

                      when c = 'q' then 'g'
                      when c = 'z' then 's'
                      when c = 'm' then 'n'

                      when c = 'k' and next_c = 'n' then 'n'
                      when off != 1 and prev_c = 'k' and c = 'n' then null
                      when c = 'k' then 'c'

                      when c = 's' and next_c = 'c' and next2_c = 'h' then 's'
                      when off != 1 and prev_c = 's' and c = 'c' and next_c = 'h' then 's'
                      when off != 2 and prev2_c = 's' and prev_c = 'c' and c = 'h' then 's'

                      when c = 'p' and next_c = 'h' then 'f'
                      when off != 1 and prev_c = 'p' and c = 'h' then 'f'

                      when off != 1 and (c = 'h' and (prev_c not in ('a', 'e', 'i', 'o', 'u') or next_c not in ('a', 'e', 'i', 'o', 'u'))) then prev_c
                      when off != 1 and c = 'w' and prev_c in ('a', 'e', 'i', 'o', 'u') then prev_c
                      else c
                    end) as new_c,
                    off
                  from (select
                          c,
                          off,
                          lag(c) over (order by off) as prev_c,
                          lag(c, 2) over (order by off) as prev2_c,
                          lead(c) over (order by off) as next_c,
                          lead(c, 2) over (order by off) as next2_c
                        from unnest(split(regexp_replace(regexp_replace(regexp_replace(
                                          regexp_replace(regexp_replace(regexp_replace(
                                          regexp_replace(lower(string), "^mac", "mcc"),
                                                          "^kn", "nn"),
                                                          "^k", "c"),
                                                          "^p(h|f)", "ff"),
                                                          "^sch", "sss"),
                                                          "(e|i)e$", "y"),
                                                          "(dt|rt|rd|nt|nd)$", "d")
                                      , "")) as c with offset off -- starts at 0
                        )
                  )
            where new_c is not null
            ), "")) as c with offset off
      )
where ((not same_as_prev_char) or (same_as_prev_char and off = 1))
)))
  OPTIONS ( description = '''Calculates NYSIIS code for <string>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.fuzzy_nysiis`("python")
```

**Example Output**:

```
pytan
```
---
## <a id='normalize_text'></a>47. normalize_text(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Normalizes a given <string> by converting it to lowercase, applying transliteration, and removing special symbols.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.normalize_text`(`string` string) 
  RETURNS string AS (TRIM(
  justfunctions.eu.remove_extra_whitespaces(
      justfunctions.eu.transliterate_anyascii(
            justfunctions.eu.clean_special_symbols(
                  LOWER(
                    string
                  )
            )
      )
  )
))
  OPTIONS ( description = '''Normalizes a given <string> by converting it to lowercase, applying transliteration, and removing special symbols.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.normalize_text`("🎉 Welcome to Athens in 2023! Καλώς ήρθες!")
```

**Example Output**:

```
welcome to athens in 2023
```
---
## <a id='parse_useragent'></a>48. parse_useragent(useragent)

- **Type**: JS
- **Tags**: text, useragent
- **Region**: us,eu
- **Description**: Parses the details from a <useragent> string.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.parse_useragent`(`useragent` STRING) RETURNS STRUCT<
browser STRUCT<name STRING, version STRING, major STRING>,
engine  STRUCT<name STRING, version STRING>,
os      STRUCT<name STRING, version STRING>,
device  STRUCT<vendor STRING, model STRING, type STRING>,
arch    STRING
>

	LANGUAGE js AS r'''let a = UAParser(useragent);
a.arch = a.cpu.architecture;
return a;
''' OPTIONS ( description = '''Parses the details from a <useragent> string.'''  , library = [  "gs://justfunctions/bigquery-functions/ua-parser.min.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.parse_useragent`("Mozilla/5.0 (iPad; CPU OS 12_5_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1")
```

**Example Output**:

```
name : Mobile Safari |
browser.version : 12.1.2 |
browser.major : 12 |
engine.name : WebKit |
engine.version : 605.1.15 |
os.name : iOS |
os.version : 12.5.7 |
device.vendor : Apple |
device.model : iPad |
device.type : tablet |
arch : null

```
---
## <a id='remove_accents'></a>49. remove_accents(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Removes accents from a <string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.remove_accents`(`string` string) 
  RETURNS string AS (regexp_replace(normalize(string, nfd), r"\pm", ''))
  OPTIONS ( description = '''Removes accents from a <string>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.remove_accents`("¿Dóndé Éstá Mí Ágúá?")
```

**Example Output**:

```
¿Donde Esta Mi Agua?
```
---
## <a id='remove_email_plus_address'></a>50. remove_email_plus_address(email)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**:  any sub-address (also known as plus addressing) from an <email> address.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.remove_email_plus_address`(`email` STRING) 
  RETURNS STRING AS (REGEXP_REPLACE(email,r'(\+\w+)(@)', r'\2'))
  OPTIONS ( description = ''' any sub-address (also known as plus addressing) from an <email> address.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.remove_email_plus_address`("hey+other@gmail.com")
```

**Example Output**:

```
hey@gmail.com
```
---
## <a id='remove_en_stopwords'></a>51. remove_en_stopwords(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Removes English stopwords from a <string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.remove_en_stopwords`(`string` string) 
  RETURNS string AS (REGEXP_REPLACE(LOWER(string),r"\ba\b|\babout\b|\babove\b|\bafter\b|\bagain\b|\bagainst\b|\ball\b|\bam\b|\ban\b|\band\b|\bany\b|\bare\b|\baren't\b|\bas\b|\bat\b|\bbe\b|\bbecause\b|\bbeen\b|\bbefore\b|\bbeing\b|\bbelow\b|\bbetween\b|\bboth\b|\bbut\b|\bby\b|\bcan't\b|\bcannot\b|\bcould\b|\bcouldn't\b|\bdid\b|\bdidn't\b|\bdo\b|\bdoes\b|\bdoesn't\b|\bdoing\b|\bdon't\b|\bdown\b|\bduring\b|\beach\b|\bfew\b|\bfor\b|\bfrom\b|\bfurther\b|\bhad\b|\bhadn't\b|\bhas\b|\bhasn't\b|\bhave\b|\bhaven't\b|\bhaving\b|\bhe\b|\bhe'd\b|\bhe'll\b|\bhe's\b|\bher\b|\bhere\b|\bhere's\b|\bhers\b|\bherself\b|\bhim\b|\bhimself\b|\bhis\b|\bhow\b|\bhow's\b|\bi\b|\bi'd\b|\bi'll\b|\bi'm\b|\bi've\b|\bif\b|\bin\b|\binto\b|\bis\b|\bisn't\b|\bit\b|\bit's\b|\bits\b|\bitself\b|\blet's\b|\bme\b|\bmore\b|\bmost\b|\bmustn't\b|\bmy\b|\bmyself\b|\bno\b|\bnor\b|\bnot\b|\bof\b|\boff\b|\bon\b|\bonce\b|\bonly\b|\bor\b|\bother\b|\bought\b|\bour\b|\bours\b|\bourselves\b|\bout\b|\bover\b|\bown\b|\bsame\b|\bshan't\b|\bshe\b|\bshe'd\b|\bshe'll\b|\bshe's\b|\bshould\b|\bshouldn't\b|\bso\b|\bsome\b|\bsuch\b|\bthan\b|\bthat\b|\bthat's\b|\bthe\b|\btheir\b|\btheirs\b|\bthem\b|\bthemselves\b|\bthen\b|\bthere\b|\bthere's\b|\bthese\b|\bthey\b|\bthey'd\b|\bthey'll\b|\bthey're\b|\bthey've\b|\bthis\b|\bthose\b|\bthrough\b|\bto\b|\btoo\b|\bunder\b|\buntil\b|\bup\b|\bvery\b|\bwas\b|\bwasn't\b|\bwe\b|\bwe'd\b|\bwe'll\b|\bwe're\b|\bwe've\b|\bwere\b|\bweren't\b|\bwhat\b|\bwhat's\b|\bwhen\b|\bwhen's\b|\bwhere\b|\bwhere's\b|\bwhich\b|\bwhile\b|\bwho\b|\bwho's\b|\bwhom\b|\bwhy\b|\bwhy's\b|\bwith\b|\bwon't\b|\bwould\b|\bwouldn't\b|\byou\b|\byou'd\b|\byou'll\b|\byou're\b|\byou've\b|\byour\b|\byours\b|\byourself\b|\byourselves\b",''))
  OPTIONS ( description = '''Removes English stopwords from a <string>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.remove_en_stopwords`("The query in the database is returning the rows with the specified column values.")
```

**Example Output**:

```
query   database  returning  rows   specified column values.
```
---
## <a id='remove_extra_spaces'></a>52. remove_extra_spaces(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Removes extra spaces (tab, space, newline, paragraph, etc.) in a <string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.remove_extra_spaces`(`string` string) 
  RETURNS string AS (TRIM(REGEXP_REPLACE(REGEXP_REPLACE(string,r'\n+|\t+|\r+|\\n+|\\t+|\\r+|\\s+',''), r'\s+', ' ')))
  OPTIONS ( description = '''Removes extra spaces (tab, space, newline, paragraph, etc.) in a <string>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.remove_extra_spaces`("\tHi     there
.\n\n")
```

**Example Output**:

```
Hi there.
```
---
## <a id='remove_extra_whitespaces'></a>53. remove_extra_whitespaces(string)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Removes extra whitespaces in a <string>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.remove_extra_whitespaces`(`string` string) 
  RETURNS string AS (REGEXP_REPLACE(string, r'\s+',' '))
  OPTIONS ( description = '''Removes extra whitespaces in a <string>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.remove_extra_whitespaces`("Hi     there
.")
```

**Example Output**:

```
Hi there
.
```
---
## <a id='replace_en_contractions'></a>54. replace_en_contractions(string, replacement)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Replaces English contractions in a <string> with the specified <replacement>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.replace_en_contractions`(`string` string, `replacement` string) 
  RETURNS string AS ((WITH 
words AS (SELECT * FROM unnest(SPLIT(REGEXP_REPLACE(LOWER(string),replacement," "), " ")) as word),

list AS (SELECT LOWER(JSON_EXTRACT_SCALAR(c,"$.key")) key_part,LOWER(JSON_EXTRACT_SCALAR(c,"$.value")) value_part  FROM
unnest([
'{"key":"I\'m","value":"I am"}',
'{"key":"I\'m\'a","value":"I am about to"}',
'{"key":"I\'m\'o","value":"I am going to"}',
'{"key":"I\'ve","value":"I have"}',
'{"key":"I\'ll","value":"I will"}',
'{"key":"I\'ll\'ve","value":"I will have"}',
'{"key":"I\'d","value":"I would"}',
'{"key":"I\'d\'ve","value":"I would have"}',
'{"key":"Whatcha","value":"What are you"}',
'{"key":"amn\'t","value":"am not"}',
'{"key":"ain\'t","value":"are not"}',
'{"key":"aren\'t","value":"are not"}',
'{"key":"\'cause","value":"because"}',
'{"key":"can\'t","value":"cannot"}',
'{"key":"can\'t\'ve","value":"cannot have"}',
'{"key":"could\'ve","value":"could have"}',
'{"key":"couldn\'t","value":"could not"}',
'{"key":"couldn\'t\'ve","value":"could not have"}',
'{"key":"daren\'t","value":"dare not"}',
'{"key":"daresn\'t","value":"dare not"}',
'{"key":"dasn\'t","value":"dare not"}',
'{"key":"didn\'t","value":"did not"}',
'{"key":"didn’t","value":"did not"}',
'{"key":"don\'t","value":"do not"}',
'{"key":"don’t","value":"do not"}',
'{"key":"doesn\'t","value":"does not"}',
'{"key":"e\'er","value":"ever"}',
'{"key":"everyone\'s","value":"everyone is"}',
'{"key":"finna","value":"fixing to"}',
'{"key":"gimme","value":"give me"}',
'{"key":"gon\'t","value":"go not"}',
'{"key":"gonna","value":"going to"}',
'{"key":"gotta","value":"got to"}',
'{"key":"hadn\'t","value":"had not"}',
'{"key":"hadn\'t\'ve","value":"had not have"}',
'{"key":"hasn\'t","value":"has not"}',
'{"key":"haven\'t","value":"have not"}',
'{"key":"he\'ve","value":"he have"}',
'{"key":"he\'s","value":"he is"}',
'{"key":"he\'ll","value":"he will"}',
'{"key":"he\'ll\'ve","value":"he will have"}',
'{"key":"he\'d","value":"he would"}',
'{"key":"he\'d\'ve","value":"he would have"}',
'{"key":"here\'s","value":"here is"}',
'{"key":"how\'re","value":"how are"}',
'{"key":"how\'d","value":"how did"}',
'{"key":"how\'d\'y","value":"how do you"}',
'{"key":"how\'s","value":"how is"}',
'{"key":"how\'ll","value":"how will"}',
'{"key":"isn\'t","value":"is not"}',
'{"key":"it\'s","value":"it is"}',
'{"key":"\'tis","value":"it is"}',
'{"key":"\'twas","value":"it was"}',
'{"key":"it\'ll","value":"it will"}',
'{"key":"it\'ll\'ve","value":"it will have"}',
'{"key":"it\'d","value":"it would"}',
'{"key":"it\'d\'ve","value":"it would have"}',
'{"key":"kinda","value":"kind of"}',
'{"key":"let\'s","value":"let us"}',
'{"key":"luv","value":"love"}',
'{"key":"ma\'am","value":"madam"}',
'{"key":"may\'ve","value":"may have"}',
'{"key":"mayn\'t","value":"may not"}',
'{"key":"might\'ve","value":"might have"}',
'{"key":"mightn\'t","value":"might not"}',
'{"key":"mightn\'t\'ve","value":"might not have"}',
'{"key":"must\'ve","value":"must have"}',
'{"key":"mustn\'t","value":"must not"}',
'{"key":"mustn\'t\'ve","value":"must not have"}',
'{"key":"needn\'t","value":"need not"}',
'{"key":"needn\'t\'ve","value":"need not have"}',
'{"key":"ne\'er","value":"never"}',
'{"key":"o\'","value":"of"}',
'{"key":"o\'clock","value":"of the clock"}',
'{"key":"ol\'","value":"old"}',
'{"key":"oughtn\'t","value":"ought not"}',
'{"key":"oughtn\'t\'ve","value":"ought not have"}',
'{"key":"o\'er","value":"over"}',
'{"key":"shan\'t","value":"shall not"}',
'{"key":"sha\'n\'t","value":"shall not"}',
'{"key":"shalln\'t","value":"shall not"}',
'{"key":"shan\'t\'ve","value":"shall not have"}',
'{"key":"she\'s","value":"she is"}',
'{"key":"she\'ll","value":"she will"}',
'{"key":"she\'d","value":"she would"}',
'{"key":"she\'d\'ve","value":"she would have"}',
'{"key":"should\'ve","value":"should have"}',
'{"key":"shouldn\'t","value":"should not"}',
'{"key":"shouldn\'t\'ve","value":"should not have"}',
'{"key":"so\'ve","value":"so have"}',
'{"key":"so\'s","value":"so is"}',
'{"key":"somebody\'s","value":"somebody is"}',
'{"key":"someone\'s","value":"someone is"}',
'{"key":"something\'s","value":"something is"}',
'{"key":"sux","value":"sucks"}',
'{"key":"that\'re","value":"that are"}',
'{"key":"that\'s","value":"that is"}',
'{"key":"that\'ll","value":"that will"}',
'{"key":"that\'d","value":"that would"}',
'{"key":"that\'d\'ve","value":"that would have"}',
'{"key":"\'em","value":" them"}',
'{"key":"there\'re","value":"there are"}',
'{"key":"there\'s","value":"there is"}',
'{"key":"there\'ll","value":"there will"}',
'{"key":"there\'d","value":"there would"}',
'{"key":"there\'d\'ve","value":"there would have"}',
'{"key":"these\'re","value":"these are"}',
'{"key":"they\'re","value":"they are"}',
'{"key":"they\'ve","value":"they have"}',
'{"key":"they\'ll","value":"they will"}',
'{"key":"they\'ll\'ve","value":"they will have"}',
'{"key":"they\'d","value":"they would"}',
'{"key":"they\'d\'ve","value":"they would have"}',
'{"key":"this\'s","value":"this is"}',
'{"key":"this\'ll","value":"this will"}',
'{"key":"this\'d","value":"this would"}',
'{"key":"those\'re","value":"those are"}',
'{"key":"to\'ve","value":"to have"}',
'{"key":"wanna","value":"want to"}',
'{"key":"wasn\'t","value":"was not"}',
'{"key":"we\'re","value":"we are"}',
'{"key":"we\'ve","value":"we have"}',
'{"key":"we\'ll","value":"we will"}',
'{"key":"we\'ll\'ve","value":"we will have"}',
'{"key":"we\'d","value":"we would"}',
'{"key":"we\'d\'ve","value":"we would have"}',
'{"key":"weren\'t","value":"were not"}',
'{"key":"what\'re","value":"what are"}',
'{"key":"what\'d","value":"what did"}',
'{"key":"what\'ve","value":"what have"}',
'{"key":"what\'s","value":"what is"}',
'{"key":"what\'ll","value":"what will"}',
'{"key":"what\'ll\'ve","value":"what will have"}',
'{"key":"when\'ve","value":"when have"}',
'{"key":"when\'s","value":"when is"}',
'{"key":"where\'re","value":"where are"}',
'{"key":"where\'d","value":"where did"}',
'{"key":"where\'ve","value":"where have"}',
'{"key":"where\'s","value":"where is"}',
'{"key":"which\'s","value":"which is"}',
'{"key":"who\'re","value":"who are"}',
'{"key":"who\'ve","value":"who have"}',
'{"key":"who\'s","value":"who is"}',
'{"key":"who\'ll","value":"who will"}',
'{"key":"who\'ll\'ve","value":"who will have"}',
'{"key":"who\'d","value":"who would"}',
'{"key":"who\'d\'ve","value":"who would have"}',
'{"key":"why\'re","value":"why are"}',
'{"key":"why\'d","value":"why did"}',
'{"key":"why\'ve","value":"why have"}',
'{"key":"why\'s","value":"why is"}',
'{"key":"will\'ve","value":"will have"}',
'{"key":"won\'t","value":"will not"}',
'{"key":"won\'t\'ve","value":"will not have"}',
'{"key":"would\'ve","value":"would have"}',
'{"key":"wouldn\'t","value":"would not"}',
'{"key":"wouldn\'t\'ve","value":"would not have"}',
'{"key":"y\'all","value":"you all"}',
'{"key":"y\'all\'re","value":"you all are"}',
'{"key":"y\'all\'ve","value":"you all have"}',
'{"key":"y\'all\'d","value":"you all would"}',
'{"key":"y\'all\'d\'ve","value":"you all would have"}',
'{"key":"you\'re","value":"you are"}',
'{"key":"you\'ve","value":"you have"}',
'{"key":"you\'ll\'ve","value":"you shall have"}',
'{"key":"you\'ll","value":"you will"}',
'{"key":"you\'d","value":"you would"}',
'{"key":"you\'d\'ve","value":"you would have"}',
'{"key":"\'aight","value":"alright"}',
'{"key":"abt","value":"about"}',
'{"key":"acct","value":"account"}',
'{"key":"altho","value":"although"}',
'{"key":"asap","value":"as soon as possible"}',
'{"key":"avg","value":"average"}',
'{"key":"b4","value":"before"}',
'{"key":"bc","value":"because"}',
'{"key":"bday","value":"birthday"}',
'{"key":"btw","value":"by the way"}',
'{"key":"convo","value":"conversation"}',
'{"key":"cya","value":"see ya"}',
'{"key":"diff","value":"different"}',
'{"key":"dunno","value":"do not know"}',
'{"key":"g\'day","value":"good day"}',
'{"key":"howdy","value":"how do you do"}',
'{"key":"idk","value":"I do not know"}',
'{"key":"ima","value":"I am going to"}',
'{"key":"imma","value":"I am going to"}',
'{"key":"innit","value":"is it not"}',
'{"key":"iunno","value":"I do not know"}',
'{"key":"kk","value":"okay"}',
'{"key":"lemme","value":"let me"}',
'{"key":"msg","value":"message"}',
'{"key":"nvm","value":"nevermind"}',
'{"key":"ofc","value":"of course"}',
'{"key":"ppl","value":"people"}',
'{"key":"prolly","value":"probably"}',
'{"key":"pymnt","value":"payment"}',
'{"key":"r ","value":"are "}',
'{"key":"rlly","value":"really"}',
'{"key":"rly","value":"really"}',
'{"key":"rn","value":"right now"}',
'{"key":"spk","value":"spoke"}',
'{"key":"tbh","value":"to be honest"}',
'{"key":"tho","value":"though"}',
'{"key":"thx","value":"thanks"}',
'{"key":"tlked","value":"talked"}',
'{"key":"tmmw","value":"tomorrow"}',
'{"key":"tmr","value":"tomorrow"}',
'{"key":"tmrw","value":"tomorrow"}',
'{"key":"u","value":"you"}',
'{"key":"ur","value":"you are"}',
'{"key":"woulda","value":"would have"}',
'{"key":"\'all","value":""}',
'{"key":"\'am","value":""}',
'{"key":"\'d","value":" would"}',
'{"key":"\'ll","value":" will"}',
'{"key":"\'re","value":" are"}',
'{"key":"doin\'","value":"doing"}',
'{"key":"goin\'","value":"going"}',
'{"key":"nothin\'","value":"nothing"}',
'{"key":"somethin\'","value":"something"}',
'{"key":"havin\'","value":"having"}',
'{"key":"lovin\'","value":"loving"}',
'{"key":"\'coz","value":"because"}',
'{"key":"thats","value":"that is"}',
'{"key":"whats","value":"what is"}']) as c)
SELECT string_agg(CASE WHEN value_part IS NOT NULL THEN value_part ELSE word END," ") final  FROM words LEFT JOIN list ON list.key_part=words.word
)
)
  OPTIONS ( description = '''Replaces English contractions in a <string> with the specified <replacement>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.replace_en_contractions`("I'll be great tmr thx","r"\s+"")
```

**Example Output**:

```
I will be great tomorrow thanks
```
---
## <a id='replace_html_tags'></a>55. replace_html_tags(string, replacement)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Replaces HTML tags in a <string> with the specified <replacement>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.replace_html_tags`(`string` string, `replacement` string) 
  RETURNS string AS (TRIM(REGEXP_REPLACE(string, r"<[^>]*>", replacement)))
  OPTIONS ( description = '''Replaces HTML tags in a <string> with the specified <replacement>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.replace_html_tags`("<div class=\'test\'>hello world<a href=\'#\'>hello world<\a><\\div>"," ")
```

**Example Output**:

```
hello world hello world
```
---
## <a id='replace_urls'></a>56. replace_urls(string, replacement)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Replaces URL patterns in a <string> with the specified <replacement>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.replace_urls`(`string` string, `replacement` string) 
  RETURNS string AS (REGEXP_REPLACE(string, r'((ftp|https?)\:\/\/)?[a-zA-Z0-9\.\/\?\:@\-_=#]+\.([a-zA-Z0-9\&\.\!\%\/\?\:@\-_=#])*', replacement))
  OPTIONS ( description = '''Replaces URL patterns in a <string> with the specified <replacement>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.replace_urls`("Google it https://www.google.com/ !","")
```

**Example Output**:

```
Google it !
```
---
## <a id='split_url'></a>57. split_url(url, part)

- **Type**: SQL
- **Tags**: text, url
- **Region**: us,eu
- **Description**: Splits a <url> into parts using the '/' symbol.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.split_url`(`url` STRING, `part` INT) 
  RETURNS STRING AS ((WITH split_parts as (
SELECT SPLIT("/" || TRIM(url,"/"), "/") split_str
)
SELECT split_str[safe_ordinal(part+1)]
from split_parts)
)
  OPTIONS ( description = '''Splits a <url> into parts using the '/' symbol.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.split_url`("hey.com/me/?231#213","2")
```

**Example Output**:

```
me
```
---
## <a id='stemmer_greek'></a>58. stemmer_greek(string)

- **Type**: JS
- **Tags**: NLP, text, stemmer
- **Region**: us,eu
- **Description**: Returns the stem of a <string>. Supports the Greek language.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.stemmer_greek`(`string` string) RETURNS string
	LANGUAGE js AS r'''return utils.greekStemmer(string.toUpperCase());''' OPTIONS ( description = '''Returns the stem of a <string>. Supports the Greek language.'''  , library = [  "gs://justfunctions/bigquery-functions/stemmers.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.stemmer_greek`("καλησπερα")
```

**Example Output**:

```
ΚΑΛΗΣΠΕΡ
```
---
## <a id='stemmer_lancaster'></a>59. stemmer_lancaster(string)

- **Type**: JS
- **Tags**: NLP, text, stemmer
- **Region**: us,eu
- **Description**: Returns the stem of a <string> using the Lancaster algorithm. Supports the English language.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.stemmer_lancaster`(`string` string) RETURNS string
	LANGUAGE js AS r'''return utils.lancasterStemmer(string);''' OPTIONS ( description = '''Returns the stem of a <string> using the Lancaster algorithm. Supports the English language.'''  , library = [  "gs://justfunctions/bigquery-functions/stemmers.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.stemmer_lancaster`("replied")
```

**Example Output**:

```
reply
```
---
## <a id='stemmer_porter'></a>60. stemmer_porter(string)

- **Type**: JS
- **Tags**: NLP, text, stemmer
- **Region**: us,eu
- **Description**: Returns the stem of a <string> using the Porter algorithm. Supports the English language.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.stemmer_porter`(`string` string) RETURNS string
	LANGUAGE js AS r'''return utils.porterStemmer(string);''' OPTIONS ( description = '''Returns the stem of a <string> using the Porter algorithm. Supports the English language.'''  , library = [  "gs://justfunctions/bigquery-functions/stemmers.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.stemmer_porter`("replied")
```

**Example Output**:

```
repli
```
---
## <a id='surrogate_key'></a>61. surrogate_key(string)

- **Type**: SQL
- **Tags**: text, surrogate key
- **Region**: us,eu
- **Description**: Creates a hashed value of multiple field <string>. Use CONCAT to create <string> to include multiple fields.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.surrogate_key`(`string` STRING) 
  RETURNS INT64 AS (CAST(FARM_FINGERPRINT(string) AS INT64))
  OPTIONS ( description = '''Creates a hashed value of multiple field <string>. Use CONCAT to create <string> to include multiple fields.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.surrogate_key`("python")
```

**Example Output**:

```
2065202487608477923
```
---
## <a id='surrogate_key_str'></a>62. surrogate_key_str(string)

- **Type**: SQL
- **Tags**: text, surrogate key
- **Region**: us,eu
- **Description**: Creates a hashed value of multiple field <string>. Use CONCAT to create <string> to include multiple fields.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.surrogate_key_str`(`string` STRING) 
  RETURNS STRING AS (CAST(FARM_FINGERPRINT(string) AS STRING))
  OPTIONS ( description = '''Creates a hashed value of multiple field <string>. Use CONCAT to create <string> to include multiple fields.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.surrogate_key_str`("python")
```

**Example Output**:

```
2065202487608477923
```
---
## <a id='transliterate_anyascii'></a>63. transliterate_anyascii(string)

- **Type**: JS
- **Tags**: NLP, text, transliteration
- **Region**: us,eu
- **Description**: Converts Unicode characters in a <string> to their best ASCII representation.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.transliterate_anyascii`(`string` string) RETURNS string
	LANGUAGE js AS r'''try {
  return utils.anyAscii(string);
} catch (e) {
  return string
}
''' OPTIONS ( description = '''Converts Unicode characters in a <string> to their best ASCII representation.'''  , library = [  "gs://justfunctions/bigquery-functions/transliteration.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.transliterate_anyascii`("καλημέρα")
```

**Example Output**:

```
kalimera
```
---
## <a id='validate_email'></a>64. validate_email(email)

- **Type**: SQL
- **Tags**: text, email
- **Region**: us,eu
- **Description**: Validates if an <email> address is properly formatted.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.validate_email`(`email` STRING) 
  RETURNS INT AS (CASE
   WHEN NET.REG_DOMAIN(lower(email)) IS NULL THEN 0
   WHEN REGEXP_CONTAINS(lower(email), "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$") THEN 1
   ELSE 0
END
)
  OPTIONS ( description = '''Validates if an <email> address is properly formatted.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.validate_email`("12/jason@gmail.com")
```

**Example Output**:

```
0
```
---
## <a id='word_distance'></a>65. word_distance(string_1, string_2)

- **Type**: JS
- **Tags**: text, similarity
- **Region**: us,eu
- **Description**: Calculates Levenshtein distance between <string_1> and <string_2>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.word_distance`(`string_1` STRING, `string_2` STRING) RETURNS INT64
	LANGUAGE js AS r'''return fuzzball.distance(string_1,string_2);''' OPTIONS ( description = '''Calculates Levenshtein distance between <string_1> and <string_2>.'''  , library = [  "gs://justfunctions/bigquery-functions/fuzzball.umd.min.js" ]  )
```
**Example Query**:

```sql
SELECT `justfunctions.eu.word_distance`("python","pithon")
```

**Example Output**:

```
1
```
---
## <a id='word_tokens'></a>66. word_tokens(string, symbol)

- **Type**: SQL
- **Tags**: NLP, text
- **Region**: us,eu
- **Description**: Splits a <string> into words using the specified <symbol>.

```sql
CREATE OR REPLACE FUNCTION `justfunctions.eu.word_tokens`(`string` string, `symbol` string) 
  RETURNS ARRAY<STRING> AS (SPLIT(REGEXP_REPLACE(LOWER(string),symbol," "), " "))
  OPTIONS ( description = '''Splits a <string> into words using the specified <symbol>.''')
```
**Example Query**:

```sql
SELECT `justfunctions.eu.word_tokens`("this is a sentence","\\s+")
```

**Example Output**:

```
['this', 'is', 'a', 'sentence']
```
---
