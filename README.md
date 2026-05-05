# World Layoffs - Data Cleaning (SQL)

## Project Overview
Cleaned a real-world dataset of company layoffs using MySQL.
Raw data contained duplicates, inconsistent values, wrong data types and null values.

## Steps Performed
1. **Remove Duplicates** — Used ROW_NUMBER() with PARTITION BY to identify and delete duplicate rows
2. **Standardization** — Trimmed whitespace, fixed Crypto industry variants, removed trailing periods from country names
3. **Fix Date Format** — Converted date column from TEXT to proper DATE type using STR_TO_DATE()
4. **Handle NULLs** — Removed rows where both total_laid_off and percentage_laid_off were NULL

## Files
| File | Description |
|------|-------------|
| `layoffs.csv` | Raw dataset |
| `layoffs_staging.sql` | Full data cleaning SQL script |

## Tools Used
- MySQL
- MySQL Workbench

## Dataset
World layoffs data containing company, location, industry, total laid off, percentage laid off, date, stage, country and funds raised.


## 🔍 Key Findings After Cleaning

1. **Tech industry** had the highest number of layoffs globally
2. **United States** accounts for the majority of worldwide layoffs
3. **Post-IPO stage companies** laid off the most employees
4. **2022–2023** saw the peak of layoffs — post pandemic correction
5. **Consumer and Retail** sectors were heavily impacted after tech
