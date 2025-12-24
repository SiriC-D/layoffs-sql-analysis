# Tech Layoffs Analysis using SQL

## Overview
This project analyzes global technology-sector layoffs from the COVID-19 period (2019) to the present.
The dataset contains company-level layoff events with information about industry, location, funding,
company stage, and timing of layoffs.

The primary focus of this project is **cleaning a messy real-world dataset using MySQL** and then
performing **exploratory data analysis (EDA)** to uncover trends across time, industries, and funding levels.

---

## Dataset
- **Name:** Layoffs Dataset
- **Description:** Company-level tech layoffs from 2019 to present
- **Source:** https://www.kaggle.com/datasets/swaptr/layoffs-2022

### Original Schema Issues
The raw dataset contained several real-world data problems:
- `total_laid_off` stored as **TEXT** with decimal values (e.g. `24.0`)
- Empty strings (`''`) in numeric columns
- `percentage_laid_off` stored as text instead of numeric
- Dates stored as strings (`MM/DD/YYYY`)
- Inconsistent industry labels (e.g. `Crypto`, `Crypto Currency`)
- Duplicate records representing the same layoff event

---

## Tools & Environment
- **Database:** MySQL 8 (strict SQL mode)
- **Language:** SQL

---

## Data Cleaning Approach
Data cleaning was performed using a **staging table** to ensure raw data remained unchanged.

### Key Cleaning Steps
1. Created a staging table to preserve raw data
2. Converted empty strings in numeric columns to `NULL`
3. Cleaned and converted `total_laid_off` from text decimals to integers
4. Converted `percentage_laid_off` to a `DECIMAL` data type
5. Standardized categorical fields such as `industry` and `country`
6. Converted string-based date fields to proper `DATE` format
7. Removed duplicate records using `ROW_NUMBER()` window function
8. Removed rows where both layoff metrics were missing

All cleaning logic is documented in:
data_cleaning.sql

---

## Exploratory Data Analysis (EDA)
EDA was performed on the cleaned dataset to answer business-driven questions such as:
- Which companies experienced the highest number of layoffs?
- Which industries were most affected?
- How did layoffs evolve over time?
- How did layoffs differ between early-stage and late-stage companies?
- Did highly funded companies avoid layoffs?

### Key Analyses Performed
- Company-level aggregation of total layoffs
- Industry-wise and country-wise layoff impact
- Yearly and monthly layoff trends
- Funding bucket analysis vs layoffs
- Identification of companies with multiple layoff rounds
- Detection of complete company shutdowns (100% layoffs)

All analysis queries are available in:
eda.sql


---

## Key Insights
- Layoff activity peaked during specific post-COVID periods.
- Certain industries consistently experienced higher layoffs.
- Multiple companies conducted repeated rounds of layoffs.
- High funding levels did not guarantee immunity from layoffs.
- Both early-stage and late-stage companies were significantly impacted.

---

## Project Structure
layoffs-sql-analysis/
│
├── data_cleaning.sql - SQL scripts for cleaning and preprocessing
├── eda.sql - Exploratory data analysis queries
└── README.md - Project documentation


---

## Conclusion
This project demonstrates an end-to-end SQL workflow involving real-world data cleaning challenges
and analytical exploration. It highlights practical SQL skills such as handling strict-mode casting,
window functions, and time-based analysis.

---

## Author
Created as part of a data analysis portfolio project.

