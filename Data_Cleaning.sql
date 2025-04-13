
/* To verify the accuracy of imported data */
select count(*)
from `WorldLifeExpectancy.csv` ;


/* A brief overview of this dataset */
SELECT * FROM `WorldLifeExpectancy.csv` LIMIT 10

/* See how many duplicates we have, and remove them from the dataset */

-- 1 Check duplicated rows
-- Duplicates are some rows which have the same records of information.
-- In this dataset, samples were taken from each country over each year. In hence, if one country was shown twice
-- in the same year, they will be duplicated.

SELECT Country, `Year`, CONCAT(Country,`Year`) as CountryYear, COUNT(CONCAT(Country,`Year`)) as num
FROM `WorldLifeExpectancy.csv` 
GROUP BY Country, `Year`, CountryYear
HAVING num > 1



-- 2 Identify Row_ID for duplicates
-- The Row_ID is unique, which can be used as an index.
-- I am going to remove duplicates based on the Row_ID.

-- Find out the index of duplicated samples
select * from

(select Row_ID, CONCAT(Country,`Year`) as 'country_with_year', row_number() over(partition by CONCAT(Country,`Year`)) as 'row_num'
from `WorldLifeExpectancy.csv`) as row_table

where row_num > 1
;

-- Drop the duplicates
DELETE FROM `WorldLifeExpectancy.csv` 
WHERE Row_ID IN 

(select Row_ID from

(select Row_ID, CONCAT(Country,`Year`) as 'country_with_year', row_number() over(partition by CONCAT(Country,`Year`)) as 'row_num'
from `WorldLifeExpectancy.csv`) as row_table

where row_num > 1)
;


/* See how many blanks or noles we have */

 -- 1 See where the blanks are
SELECT * FROM `WorldLifeExpectancy.csv`
WHERE Status = ''
;

-- 2 How to fill the blank cells in Status column by using the Status which we have known for each country?

-- Check values in Status, see how these missing values are suppoesd to be populated.
SELECT DISTINCT(Status)
from `WorldLifeExpectancy.csv`
WHERE Status <> ''
;

-- See rows with missing values in Status
SELECT Country, Status FROM `WorldLifeExpectancy.csv`
WHERE Status = ''
;

/* Mason's version */
SELECT DISTINCT(Country), Status FROM `WorldLifeExpectancy.csv`
WHERE Status <> ''
;

-- 
SELECT * FROM 

(SELECT Country, Status FROM `WorldLifeExpectancy.csv`
WHERE Status = '') as og_table

LEFT JOIN

(SELECT DISTINCT(Country) as Modi_Country, Status as Modi_Status FROM `WorldLifeExpectancy.csv`
WHERE Status <> '') as Modi_table

ON og_table.Country = Modi_table.Modi_Country
;

-- 
SELECT * FROM 

(SELECT * FROM 

(SELECT Country, Status FROM `WorldLifeExpectancy.csv`
WHERE Status = '') as og_table

LEFT JOIN

(SELECT DISTINCT(Country) as Modi_Country, Status as Modi_Status FROM `WorldLifeExpectancy.csv`
WHERE Status <> '') as Modi_table

ON og_table.Country = Modi_table.Modi_Country) as Check_table

WHERE Modi_Status = 'Developing'
;

-- 
UPDATE `WorldLifeExpectancy.csv` 
SET Status = 'Developing'
WHERE Country IN

(SELECT Country FROM 

(SELECT * FROM 

(SELECT Country, Status FROM `WorldLifeExpectancy.csv`
WHERE Status = '') as og_table

LEFT JOIN

(SELECT DISTINCT(Country) as Modi_Country, Status as Modi_Status FROM `WorldLifeExpectancy.csv`
WHERE Status <> '') as Modi_table

ON og_table.Country = Modi_table.Modi_Country) as Check_table

WHERE Modi_Status = 'Developing') as Check_Base_Developing
;


/* Alex's version */
-- 
SELECT t1.Country, t1.Status, t2.Country, t2.Status FROM 
`WorldLifeExpectancy.csv` t1 
JOIN `WorldLifeExpectancy.csv` t2
ON t1.Country = t2.Country 
;

SELECT t1.Country, t1.Status, t2.Country, t2.Status FROM 
`WorldLifeExpectancy.csv` t1 
JOIN `WorldLifeExpectancy.csv` t2
ON t1.Country = t2.Country 
WHERE t1.Status = '' AND t2.Status <> ''
;
-- 

-- There are two tables
-- One of them has Country and Missing Status, the other one has Country with corresponding Status
-- I use the known status of each country to fill the blank cells in status
UPDATE `WorldLifeExpectancy.csv` t1

JOIN `WorldLifeExpectancy.csv` t2

ON t1.Country = t2.Country 

SET t1.Status = 'Developing'

WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

-- After finishing the Developing countries, I did the developed countries based on the same concept.
UPDATE `WorldLifeExpectancy.csv` t1

JOIN `WorldLifeExpectancy.csv` t2

ON t1.Country = t2.Country 

SET t1.Status = 'Developed'

WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

-- Lets check whether we have succeed in filling the missing status or not
SELECT *
FROM `WorldLifeExpectancy.csv`
WHERE Status = '' OR Status = NULL 
;


/* Next, I saw missing values in the 'Life expectancy' column */

SELECT *
FROM `WorldLifeExpectancy.csv`
;

-- Interestingly, the amout of Life expectancy has a increasing trend over years.
-- For example, in Afghanistan, the number starts from 54 in 2007 to 58 in 2017.

SELECT Country , `Year` , w.`Life expectancy` 
FROM `WorldLifeExpectancy.csv` w
;

-- Take a look at the missing values
SELECT *
FROM `WorldLifeExpectancy.csv` w
WHERE w.`Life expectancy` IS NULL 
;

-- Based on the same concept, i am using the self join to fill the blank, 
-- by using the average of Life expectancy between two years, across each country.
-- For example, the number of Life expectancy is missing in 2018 in Afghanistan, 
-- so I will populate it with the average between 2017 and 2019

-- Now lets bulid the function step by step
SELECT t1.Country , t1.`Year`, t1.`Life expectancy` , 
t2.Country , t2.Year , t2.`Life expectancy` ,
t3.Country , t3.Year , t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM `WorldLifeExpectancy.csv` as t1
JOIN `WorldLifeExpectancy.csv` as t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year -1
JOIN `WorldLifeExpectancy.csv` t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year +1
WHERE t1.`Life expectancy` IS NULL 
;




UPDATE `WorldLifeExpectancy.csv` as t1
JOIN `WorldLifeExpectancy.csv` as t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year -1
JOIN `WorldLifeExpectancy.csv` t3
	ON t1.Country = t3.Country	
	AND t1.Year = t3.Year +1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` IS NULL 
;

-- So far, I have finfished cleaning this dataset.























