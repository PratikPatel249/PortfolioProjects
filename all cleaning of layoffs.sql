--duplicate values--
with duplicate as (select *,ctid,row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions)
as rank
from layoffs)
delete from layoffs
where ctid in (select ctid from duplicate where rank>1);

--standarizing format--triming white space--
select company,trim(company) from layoffs;
update layoffs
set company=trim(company);
--updating the value where industry name is different although meaning is same --
select distinct(industry) from layoffs order by 1;
select * from layoffs where industry like 'Crypto%';

update layoffs
set industry='Crypto'
where industry like '%Crypto%';
--now all the values of crypto industry are labbeled in one form which is crypto insted of crypto currency etc so on --

-- now we are doing sa,e fpr locations --
select distinct(location) from layoffs order by 1;
--the most values are unique as far i can say--
--lets do the same for countries--
select distinct(country) from layoffs order by 1 ;
--here united states is repeating two times differently so we will update the value in one form--
select distinct(country),trim(trailing '.' from country) as trimmed from layoffs order by 1 ;
update layoffs
set country=trim(trailing '.' from country)
where country like '%United States%';

select distinct(country) from layoffs;

select date from layoffs;

--here we change the date column to date format--
SET datestyle TO MDY;
ALTER TABLE layoffs
ALTER COLUMN date TYPE DATE USING date::DATE;
select * from layoffs;

--now we are updating or removing the null values --
select * from layoffs where industry is null or industry ='';
select * from layoffs where company='Airbnb';

--lets add the value of industry where the the same company has value for industry--
select * from layoffs t1 join layoffs t2 on t1.company=t2.company
where (t1.industry is null or t1.industry = '') and t2.industry is not null; 
--here we are updating the blanlk space with null to review what we we can fill in the null value--
update layoffs
set industry=null
where industry = '';
--here by using self join , i have used the relevent rows to fill the industry value --
UPDATE layoffs t1
SET industry = t2.industry
FROM layoffs t2
WHERE t1.industry IS NULL
AND t1.industry = t2.industry
AND t2.industry IS NOT NULL;

UPDATE layoffs t1
SET industry='Travel'
where company='Airbnb' and location ='SF Bay Area';

SELECT * 
FROM layoffs 
WHERE company IN ('Jull', 'Carvana');
--here we can see that carvana industry in one row is null but we have other entry of same name so we can fill it throuth--
update layoffs 
set industry='Transportation'
where company='Carvana' and location = 'Phoenix';
SELECT *
FROM layoffs where company='Juul';
--the same steps we gonna do for a company named Juul --
update layoffs 
set industry='Consumer'
where company='Juul' and location = 'SF Bay Area';

select * from layoffs where company='Bally''s Interactive';
--this company has just one value so there is no way to replace its industry--

--now we want to ensure those values where two main values are null--
select * from layoffs where total_laid_off is null and percentage_laid_off is null;

--now because there is no alternative than deleting tha values which are null--
delete from layoffs where total_laid_off is null and percentage_laid_off is null;

--lets ensure if there any null value is there in whole table --
SELECT * 
FROM layoffs
WHERE company IS NULL
   OR location IS NULL
   OR industry IS NULL
   OR total_laid_off IS NULL
   OR percentage_laid_off IS NULL
   OR date IS NULL
   OR stage IS NULL
   OR country IS NULL
   OR funds_raised_millions IS NULL;





