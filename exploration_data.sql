select * from layoffs3;

select max(percentage_laid_off) ,max( total_laid_off ) from layoffs3;

select min(percentage_laid_off), min( total_laid_off ) from layoffs3;
select avg(percentage_laid_off) , avg( total_laid_off ) from layoffs3;

select company, total_laid_off from layoffs3 
where total_laid_off = (select max(total_laid_off) from layoffs3);

select company, total_laid_off, percentage_laid_off from layoffs3 
where percentage_laid_off = 
(select max(percentage_laid_off) from layoffs3) order by company;

select company, sum(total_laid_off) from layoffs3 
group by company
order by 2 desc;

select country, sum(total_laid_off) from layoffs3 
group by country
order by 2 desc;


select YEAR (date), sum(total_laid_off) as laid_off from layoffs3 
group by YEAR (date)
order by 2 desc;

select substring(date,1,7) as year_months, sum(total_laid_off) as laid_off from layoffs3 
group by year_months
order by 2 desc;

- 
----- I want to look at 

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs3
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;




-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs3
GROUP BY dates
ORDER BY dates ASC;

-- Using it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs3
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC