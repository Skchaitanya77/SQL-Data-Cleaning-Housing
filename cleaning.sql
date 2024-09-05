-- Data Cleaning --
select * from layoffs1;

-- remove duplicates --

create table layoffs2 like layoffs1;

select * from layoffs2;

insert layoffs2 select * from layoffs1;
select * from layoffs2;

with duplicate_cte as
(
select * , row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date', 
stage, country, funds_raised_millions ) as row_num from layoffs2 ) 
select * from duplicate_cte where row_num > 1; 

-- creating a table with row-num so that we can delete duplicates
CREATE TABLE `layoffs3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs3;

insert into layoffs3
select * , row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, 'date', 
stage, country, funds_raised_millions ) as row_num from layoffs2;

select * from  layoffs3 where row_num > 1; 
SET SQL_SAFE_UPDATES = 0;

delete from layoffs3 where row_num > 1 ;

-- removed all duplicates
select * from  layoffs3 where row_num > 1; 
select * from  layoffs3;


--- standardizing--data

select company, trim(company) from layoffs3;
--- removing extra spaces -before -and -after words 

update layoffs3 set company = trim(company);
---- updated --table --with --no extra spaces
select company, trim(company) from layoffs3;
-- looking which industry has diplicate  names like crypto cryptocurrency etc---
select distinct industry from layoffs3 order by industry;
--- we could see crypto is written in 3 different forms ---- 

select * from layoffs3 where industry like 'crypto%';

update layoffs3 set industry = 'Crypto' where industry like 'crypto%';

select distinct country from layoffs3 order by country; 

select distinct country from layoffs3 where country like 'united States%';

-- two differnt forms of unitedstates

update layoffs3 set country = 'United States' where country like 'united States%';
--- or this using trim
update layoffs3 set country = trim(trailing '.' from country) where country like 'united States%';


select distinct country from layoffs3 where country like '%States%';

---- transforming text to  date
select date from layoffs3;

select date , str_to_date(date, '%m/%d/%Y') from layoffs3;

update layoffs3 set date = str_to_date(date, '%m/%d/%Y');

select date from layoffs3;
-- changing data type to date 

alter table layoffs3 modify date Date; 

----- null and blank values

select * from layoffs3 where total_laid_off is null and 
percentage_laid_off is null;


select * from layoffs3 where industry is null or 
industry = '';


select t1.industry, t2.industry from layoffs3 t1
join layoffs3 t2 on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- changing blans to null first

update layoffs3 set industry = null where industry = '';

select industry from layoffs3 where industry = '';

update layoffs3 t1
join layoffs3 t2 on t1.company = t2.company
set t1.industry = t2.industry where t1.industry is null
and t2.industry is not null;

select industry, company from layoffs3 where company = 'Airbnb';

select industry, company from layoffs3 where company like 'bally%';

-- deleting them because it does make any sense if perecentages
-- are null 
-- if we wanto find out which company did what

delete 
from layoffs3 where total_laid_off is null and 
percentage_laid_off is null;

alter table layoffs3 drop column row_num;

select count(*) from layoffs3 where total_laid_off is null;
select count(*) from layoffs3 where percentage_laid_off is null;
select * from layoffs3 where total_laid_off is null and 
percentage_laid_off is null;
