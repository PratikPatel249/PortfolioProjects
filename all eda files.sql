select * from layoffs

--

--1. Industries with the Highest Total Layoffs--
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 10;

--2. Industries with the Highest Layoff Percentage (Relative Impact)--
SELECT industry, AVG(percentage_laid_off) AS avg_layoff_percentage
FROM layoffs
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
ORDER BY avg_layoff_percentage DESC
LIMIT 5;


--3. Layoff Trends Over Time (Monthly Layoffs)--

SELECT DATE_TRUNC('month', date) AS month, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY month
ORDER BY month;

--4. Layoffs Over Time by Industry--

SELECT DATE_TRUNC('month', date) AS month, 
       industry, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY month, industry
ORDER BY month, total_layoffs DESC;


--5. Companies with the Largest Single Layoffs

SELECT company, industry, total_laid_off, date
FROM layoffs
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;

--6. Countries Most Affected by Layoffs--

SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_layoffs DESC;

--7. Funding vs. Layoffs ,Do Well-Funded Companies Lay Off More?--

SELECT industry, 
       sum(funds_raised_millions) AS total_funding, 
       sum(total_laid_off) AS total_layoffs
FROM layoffs
WHERE total_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL
GROUP BY industry
ORDER BY 2,3 DESC;

--8. Rolling Total of Layoffs Per Month--
SELECT 
    DATE_TRUNC('month', date) AS month, 
    SUM(total_laid_off) AS monthly_layoffs, 
    SUM(SUM(total_laid_off)) OVER (ORDER BY DATE_TRUNC('month', date)) AS rolling_total
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY month
ORDER BY month;

--9 Which Companies Had 1 (100% of Their Workforce Laid Off)?--
SELECT company, industry, total_laid_off, percentage_laid_off, date
FROM layoffs
WHERE percentage_laid_off = 1 and total_laid_off is not null
ORDER BY date DESC;


--10 - if we order by funcs_raised_millions we can see how big some of these companies were--
SELECT *
FROM layoffs
WHERE  percentage_laid_off = 1 and funds_raised_millions is not null
ORDER BY funds_raised_millions DESC;



--11 Ranking Industries by Layoffs Per Year--

WITH Industry_Year AS 
(
  SELECT industry, EXTRACT(YEAR FROM date) AS year, 
         SUM(total_laid_off) AS total_layoffs
  FROM layoffs
  WHERE total_laid_off IS NOT NULL
  GROUP BY industry, year
)
, Industry_Year_Rank AS (
  SELECT industry, year, total_layoffs, 
         DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS ranking
  FROM Industry_Year
)
SELECT industry, year, total_layoffs, ranking
FROM Industry_Year_Rank
WHERE ranking <= 3
AND year IS NOT NULL
ORDER BY year ASC, total_layoffs DESC;


