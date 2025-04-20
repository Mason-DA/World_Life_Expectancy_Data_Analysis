/* First, we gonna see how has each country done in their Life Expectancy */

-- Firstly, lets start from the min, max, average, gap exploration for the key metirc Life Expectancy
SELECT Country , MIN(w.`Life expectancy`), MAX(w.`Life expectancy`) 
FROM `WorldLifeExpectancy.csv` w
GROUP BY Country 
HAVING MIN(w.`Life expectancy`) <> 0
AND MAX(w.`Life expectancy`) <> 0
ORDER BY Country DESC
;

-- Life Expectancy Increase over 15 years
SELECT Country ,  (MAX(w.`Life expectancy`) - MIN(w.`Life expectancy`)) as Life_Increase_15_years
FROM `WorldLifeExpectancy.csv` w
GROUP BY Country 
HAVING MIN(w.`Life expectancy`) <> 0
AND MAX(w.`Life expectancy`) <> 0
ORDER BY Life_Increase_15_years DESC
;

SELECT Country , ROUND(AVG(w.`Life expectancy`),0) AS Life_exp
FROM `WorldLifeExpectancy.csv` w
GROUP BY Country 
HAVING Life_exp <> 0
ORDER BY Life_exp ASC
;

-- Life expectancy increase around the world over 15 years
SELECT `Year` , AVG(w.`Life expectancy`) 
FROM `WorldLifeExpectancy.csv` w
WHERE w.`Life expectancy` <> 0
GROUP BY Year
;


-- What's the correlation between life expectancy and GDP?
-- If there is , is it positive or negative?
SELECT Country , ROUND(AVG(w.`Life expectancy`),0) as Life_exp , ROUND(AVG(GDP),0) avg_gdp
FROM  `WorldLifeExpectancy.csv` w
GROUP BY Country 
HAVING Life_exp <> 0
AND avg_gdp <> 0
ORDER BY avg_gdp ASC 	
;

SELECT Country , ROUND(AVG(w.`Life expectancy`),0) as Life_exp , ROUND(AVG(GDP),0) avg_gdp
FROM  `WorldLifeExpectancy.csv` w
GROUP BY Country 
HAVING Life_exp <> 0
AND avg_gdp <> 0
ORDER BY avg_gdp DESC 	
;


-- What's the life expectancy in high gdp countries? And low gdp ones?
SELECT SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Counts, 
		AVG(CASE WHEN GDP >= 1500 THEN w.`Life expectancy` ELSE NULL END) High_GDP_Life_exp,
		SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) Low_GDP_Counts,
		AVG(CASE WHEN GDP < 1500 THEN w.`Life expectancy` ELSE NULL END) Low_GDP_Life_exp
FROM `WorldLifeExpectancy.csv` w
;

-- Do developed countries do better in Life Expectancy than developing ones?
SELECT Status, AVG(w.`Life expectancy`), Count(DISTINCT Country)
FROM `WorldLifeExpectancy.csv` w
GROUP BY Status
;

-- In summary
