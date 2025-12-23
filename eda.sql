-- ============================================================
-- Project: Exploratory Data Analysis (EDA)
-- Dataset: Layoffs Dataset
-- Description: Tech layoffs from COVID-19 (2019) to present
-- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Cleaned Table Used: layoffs_staging2
-- ============================================================


-- ------------------------------------------------------------
-- 1. BASIC DATA OVERVIEW
-- ------------------------------------------------------------

-- Total number of layoff records
SELECT COUNT(*) AS total_records
FROM layoffs_staging2;

-- Date range covered by the dataset
SELECT 
    MIN(date) AS start_date, 
    MAX(date) AS end_date
FROM layoffs_staging2;


-- ------------------------------------------------------------
-- 2. OVERALL LAYOFF IMPACT
-- ------------------------------------------------------------

-- Total number of employees laid off across all records
SELECT SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2;


-- ------------------------------------------------------------
-- 3. COMPANY-LEVEL ANALYSIS
-- ------------------------------------------------------------

-- Top 10 companies by total layoffs
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Companies with multiple layoff rounds
SELECT company,
       COUNT(*) AS layoff_rounds,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
HAVING layoff_rounds > 1
ORDER BY layoff_rounds DESC, total_layoffs DESC;

-- Companies that shut down completely (100% layoffs)
SELECT company, total_laid_off, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1;


-- ------------------------------------------------------------
-- 4. INDUSTRY ANALYSIS
-- ------------------------------------------------------------

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Top industry-year combinations by layoffs
SELECT industry,
       YEAR(date) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry, year
ORDER BY total_layoffs DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 5. GEOGRAPHIC ANALYSIS
-- ------------------------------------------------------------

-- Top 10 countries by total layoffs
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 10;

-- Countries with the highest number of layoff events
SELECT country,
       COUNT(*) AS layoff_events
FROM layoffs_staging2
GROUP BY country
ORDER BY layoff_events DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 6. TIME-BASED ANALYSIS
-- ------------------------------------------------------------

-- Yearly layoffs trend
SELECT YEAR(date) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year;

-- Monthly layoffs trend
SELECT DATE_FORMAT(date, '%Y-%m') AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY month
ORDER BY month;

-- Month-over-month change in layoffs
SELECT
    month,
    total_layoffs,
    total_layoffs -
    LAG(total_layoffs) OVER (ORDER BY month) AS change_from_previous_month
FROM (
    SELECT DATE_FORMAT(date, '%Y-%m') AS month,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY month
) t;


-- ------------------------------------------------------------
-- 7. COMPANY STAGE ANALYSIS
-- ------------------------------------------------------------

-- Layoffs by company stage
SELECT stage,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- Early-stage vs late-stage company comparison
SELECT
    CASE
        WHEN stage IN ('Seed', 'Series A', 'Series B')
            THEN 'Early Stage'
        ELSE 'Late Stage'
    END AS company_stage,
    COUNT(*) AS companies,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company_stage;


-- ------------------------------------------------------------
-- 8. FUNDING ANALYSIS
-- ------------------------------------------------------------

-- Funding buckets vs total layoffs
SELECT
    CASE
        WHEN funds_raised < 50 THEN '< $50M'
        WHEN funds_raised BETWEEN 50 AND 200 THEN '$50M–$200M'
        WHEN funds_raised BETWEEN 200 AND 500 THEN '$200M–$500M'
        ELSE '> $500M'
    END AS funding_bucket,
    COUNT(*) AS company_count,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE funds_raised IS NOT NULL
GROUP BY funding_bucket
ORDER BY total_layoffs DESC;

-- Highly funded companies that still laid off employees
SELECT company, funds_raised, total_laid_off
FROM layoffs_staging2
WHERE funds_raised > 500
ORDER BY total_lay_off DESC;


-- ------------------------------------------------------------
-- 9. INDUSTRY PEAK LAYOFF PERIODS
-- ------------------------------------------------------------

-- Industries most affected during peak layoff months
SELECT industry,
       DATE_FORMAT(date, '%Y-%m') AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry, month
ORDER BY total_layoffs DESC
LIMIT 10;
