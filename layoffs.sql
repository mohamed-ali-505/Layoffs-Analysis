SET GLOBAL local_infile = 1;
CREATE DATABASE layoffs_db;

CREATE TABLE layoffs (
    company VARCHAR(255),
    location VARCHAR(255),
    industry VARCHAR(255),
    total_laid_off INT,
    percentage_laid_off DECIMAL(5,2),
    date VARCHAR(20),
    stage VARCHAR(255),
    country VARCHAR(255),
    funds_raised_millions DECIMAL(15,2)
);

LOAD DATA LOCAL INFILE 'C:/Users/Mohamed ali/Desktop/layoffs/layoffs.csv'
INTO TABLE layoffs
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions);


USE layoffs_db;
SELECT * FROM layoffs ; 

-- 1. Remove duplicates 
-- 2. standardize the data 
-- 3. remove the null values 
-- 4. remove any column
-- ........

-- 1. Remove duplicates 
CREATE TABLE layoffs_staging
LIKE layoffs;
INSERT layoffs_staging
SELECT * FROM layoffs;
SELECT * FROM layoffs_staging;

SELECT * , 
ROW_NUMBER() OVER (PARTITION BY company, 'location', industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions ORDER BY company) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
SELECT * , 
ROW_NUMBER() OVER (PARTITION BY company, 'location', industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions ORDER BY company) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

SELECT * FROM layoffs_staging 
WHERE company = "Casper";

CREATE TABLE `layoffs_staging2` (
  `company` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` decimal(5,2) DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `stage` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `funds_raised_millions` decimal(15,2) DEFAULT NULL,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT * , 
ROW_NUMBER() OVER (PARTITION BY company, 'location', industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions ) AS row_num
FROM layoffs_staging;

select * from layoffs_staging2 WHERE row_num > 1;
DELETE
from layoffs_staging2 
WHERE row_num > 1;

-- 2. standardize the data 
SELECT company , TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = TRIM(company);
    
SELECT DISTINCT industry 
FROM layoffs_staging2 
ORDER BY 1;

SELECT * 
FROM layoffs_staging2 
WHERE industry LIKE '%Crypto%';


UPDATE layoffs_staging2 
SET industry = 'Crypto' 
WHERE industry LIKE '%Crypto%';


SELECT DISTINCT country 
FROM layoffs_staging2 
ORDER BY 1;

UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date` ,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2 
MODIFY `date` DATE;

-- 3. remove the null values


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company =  "Airbnb";

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
 
UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = '';    

UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2 
ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- 4. remove any column
ALTER TABLE layoffs_staging2 
DROP COLUMN row_num






