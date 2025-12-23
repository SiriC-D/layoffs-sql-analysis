-- ============================================================
-- Project: SQL Data Cleaning
-- Dataset: Layoffs Dataset (Tech layoffs from COVID 2019–Present)
-- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Database: world_layoffs
-- ============================================================


-- ------------------------------------------------------------
-- STEP 0: Inspect raw data (READ ONLY)
-- ------------------------------------------------------------
SELECT *
FROM layoffs
LIMIT 20;


-- ------------------------------------------------------------
-- STEP 1: Create a staging table
-- Purpose: Keep raw data untouched
-- ------------------------------------------------------------
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- ------------------------------------------------------------
-- STEP 2: Handle empty strings in numeric columns
-- MySQL cannot cast '' to numbers
-- ------------------------------------------------------------
SELECT *
FROM layoffs_staging
WHERE total_laid_off = ''
   OR percentage_laid_off = '';

UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE total_laid_off = '';

UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';


-- ------------------------------------------------------------
-- STEP 3: Clean and convert total_laid_off
-- Column contains values like '24.0', '200.0'
-- ------------------------------------------------------------

-- Identify non-integer values
SELECT total_laid_off
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
  AND total_laid_off NOT REGEXP '^[0-9]+$';

-- Convert decimal strings safely to integers (STRICT MODE SAFE)
UPDATE layoffs_staging
SET total_laid_off =
    CAST(CAST(total_laid_off AS DECIMAL(10,1)) AS UNSIGNED)
WHERE total_laid_off IS NOT NULL;

-- Verify cleanup
SELECT total_laid_off
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
  AND total_laid_off NOT REGEXP '^[0-9]+$';

-- Change datatype
ALTER TABLE layoffs_staging
MODIFY total_laid_off INT;


-- ------------------------------------------------------------
-- STEP 4: Clean and convert percentage_laid_off
-- Values represent fractions (0.25 = 25%)
-- ------------------------------------------------------------
SELECT DISTINCT percentage_laid_off
FROM layoffs_staging
WHERE percentage_laid_off IS NOT NULL
LIMIT 20;

SELECT percentage_laid_off
FROM layoffs_staging
WHERE percentage_laid_off IS NOT NULL
  AND percentage_laid_off NOT REGEXP '^[0-9]*\\.?[0-9]+$';

ALTER TABLE layoffs_staging
MODIFY percentage_laid_off DECIMAL(5,2);


-- ------------------------------------------------------------
-- STEP 5: Standardize categorical text columns
-- ------------------------------------------------------------

-- Industry cleanup
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

-- Populate missing industry using same company
UPDATE layoffs_staging t1
JOIN layoffs_staging t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Standardize Crypto naming
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency', 'crypto');

-- Trim company and country names
UPDATE layoffs_staging
SET company = TRIM(company);

UPDATE layoffs_staging
SET country = TRIM(country);

-- Remove trailing periods from country names
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- Validate categories
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs_staging
ORDER BY country;


-- ------------------------------------------------------------
-- STEP 6: Convert date columns
-- ------------------------------------------------------------
SELECT date, date_added
FROM layoffs_staging
LIMIT 20;

UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY date DATE;

UPDATE layoffs_staging
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY date_added DATE;


-- ------------------------------------------------------------
-- STEP 7: Deduplication using ROW_NUMBER()
-- ------------------------------------------------------------
CREATE TABLE layoffs_staging2 AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   company,
                   location,
                   industry,
                   total_laid_off,
                   percentage_laid_off,
                   date,
                   stage,
                   country,
                   funds_raised
           ) AS row_num
    FROM layoffs_staging
) t
WHERE row_num = 1;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ------------------------------------------------------------
-- STEP 8: Remove unusable rows
-- ------------------------------------------------------------
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ------------------------------------------------------------
-- STEP 9: Final validation
-- ------------------------------------------------------------
SELECT COUNT(*) FROM layoffs_staging;
SELECT COUNT(*) FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
LIMIT 20;

DESCRIBE layoffs_staging2;
