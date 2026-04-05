-- ============================================
-- Data Cleaning Project - World Layoffs
-- ============================================

SELECT count(*) FROM world_layoff.layoffs_staging;


-- 1: Remove Duplicates


-- Check all data first
select *,
row_number() over(
partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging; 

-- Using CTE to identify duplicate rows
with duplicate_cte as 
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num>1;

SELECT count(*)
FROM world_layoff.layoffs_staging;

-- Creating staging table to safely delete duplicates without touching raw data

CREATE TABLE `world_layoff`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

-- Inserting data with row numbers to tag duplicates
INSERT INTO `world_layoff`.`layoffs_staging2`
    (`company`, `location`, `industry`, `total_laid_off`, 
     `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`, `row_num`)
SELECT `company`, `location`, `industry`, `total_laid_off`,
       `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
           percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM world_layoff.layoffs_staging;

select count(*) from layoffs_staging2;

-- Deleting duplicate rows (keeping only row_num = 1)
SET SQL_SAFE_UPDATES = 0;
DELETE FROM world_layoff.layoffs_staging2
WHERE row_num >= 2;
SET SQL_SAFE_UPDATES = 1;

-- Verify no duplicates remain
select * FROM layoffs_staging2
WHERE row_num >= 2;


-- 2: Standardization


-- Trim whitespace from company names
update layoffs_staging2
set company = trim(company);

select * FROM layoffs_staging2;

-- Check distinct industry values for inconsistencies
SELECT DISTINCT industry
FROM world_layoff.layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
where industry like 'Crypto%';

-- Standardize all Crypto variants to 'Crypto'
update layoffs_staging2
set industry ='Crypto'
where industry like 'Crypto%';

-- Check for NULL or blank industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Set blank industry to NULL for consistency        
update layoffs_staging2
set industry = NULL where industry = '';

-- Check country for inconsistencies
SELECT DISTINCT country,trim(trailing '.' from country)
FROM world_layoff.layoffs_staging2
ORDER BY 1;

-- Remove trailing period from 'United States.'
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

--  3: Fix Date Format

-- Disable strict mode to handle any invalid date values
SET sql_mode = '';                                    

-- Convert date column from text to proper date format
update layoffs_staging2
set `date` = str_to_date(`date`,"%m/%d/%Y");

-- Change column type from TEXT to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

--  4: Handle NULL Values

-- Check how many rows have NULL total_laid_off
SELECT count(*)
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- Check rows where both key metrics are NULL (these are useless rows)
SELECT count(*)
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
and percentage_laid_off IS NULL;

-- Check remaining NULL industry rows
SELECT count(*)
FROM layoffs_staging2
WHERE industry IS NULL 
or industry = '';

-- Delete rows where both key metrics are NULL (no useful data)
SET SQL_SAFE_UPDATES = 0;
DELETE FROM world_layoff.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
SET SQL_SAFE_UPDATES = 1;


-- 5: Final Cleanup

-- Drop row_num column as it was only needed for duplicate removal
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final check of cleaned data
SELECT * 
FROM world_layoff.layoffs_staging2;
