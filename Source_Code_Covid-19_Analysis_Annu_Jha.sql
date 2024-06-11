-- ---------------------CORONA VIRUS ANALYSIS --------------------------------
-- Creating Database for storing COVID-19 data
CREATE DATABASE IF NOT EXISTS CORONA_VIRUS_DATA;

-- Set this database as default database for further analysis
USE CORONA_VIRUS_DATA;

-- Table Creation
CREATE TABLE CORONA_VIRUS 
(
    Province TEXT,
    Country_Region TEXT,
    Latitude TEXT,
    Longitude TEXT,
    Date TEXT,
    Confirmed TEXT,
    Deaths TEXT,
    Recovered TEXT
);

-- Diaplay table details
DESCRIBE corona_virus;

-- Run Query to see records
SELECT * FROM CORONA_VIRUS; # TOTAL ROW SHOULD BE 78387

-- Load Data (Records) in tha table
LOAD DATA INFILE 'CORONA_VIRUS_DATASET.CSV' INTO TABLE corona_virus
FIELDS TERMINATED BY ','
IGNORE 1 LINES; # Getting error as csv file not in the secure file folder

-- Check the secure file possition in MySQL
SELECT @@secure_file_priv;

-- C:\ProgramData\MySQL\MySQL Server 8.0\Uploads
-- CHANGE "\" SLASH TO "/" SLASH
 
 -- Now loading the data(records) in the table
/* LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Corona_Virus_Dataset.csv'
INTO TABLE corona_virus FIELDS TERMINATED BY ',';
*/

-- Load Data (Records) in tha table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Corona_Virus_Dataset.csv'
INTO TABLE corona_virus 
FIELDS TERMINATED BY ',' 
(Province, Country_Region, Latitude, Longitude, Date, Confirmed, Deaths, Recovered);
# Successfully loaded the records in the table

-- Display the records
SELECT * FROM CORONA_VIRUS;

-- Counting the rows
SELECT COUNT(*) FROM CORONA_VIRUS; # 78387 includes column name as first row

-- ----------------------------Data Cleaning -------------------------
-- Run a SELECT query to view the first few rows:
SELECT * FROM corona_virus LIMIT 5;

-- Delete the first row as it contain column name
DELETE FROM corona_virus
LIMIT 1;

-- Verify Deletion
SELECT * FROM corona_virus LIMIT 5;
SELECT * FROM corona_virus;
SELECT COUNT(*) FROM corona_virus; # 78385

-- Change "Confirmed", "Deaths", "Recovered" columns Datatype 
ALTER TABLE corona_virus
    MODIFY Confirmed INT,
    MODIFY Deaths INT,
    MODIFY Recovered INT;
    
-- Change "Latitude", "Longitude" columns Datatype
ALTER TABLE corona_virus
    MODIFY Latitude FLOAT,
    MODIFY Longitude FLOAT;
    
-- ----------Convert Date column datatype text to date datatype ---------------
-- ALTER TABLE corona_virus ADD COLUMN NewDate DATE;

-- Step 1: Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Step 2: Add a new DATE column
ALTER TABLE corona_virus ADD COLUMN NewDate DATE;

-- Step 3: Update the new column with converted values
UPDATE corona_virus
SET NewDate = STR_TO_DATE(Date, '%d-%m-%Y');

-- Step 4: Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;
    
 -- Step 5: Verify the data (optional)
SELECT * FROM corona_virus WHERE NewDate IS NULL AND Date IS NOT NULL;

-- Step 6: Drop the old column and rename the new column
ALTER TABLE corona_virus DROP COLUMN Date;
ALTER TABLE corona_virus CHANGE COLUMN NewDate Date DATE;

DESCRIBE corona_virus;

SELECT DATE FROM corona_virus; 
  
/* The successful execution of the basic query includes creating the database, 
creating tables, loading data using the load query, and changing the data type 
for each column.
*/

-- ---------------------CORONA VIRUS ANALYSIS --------------------------------

-- To avoid any errors, check missing value / null value 
SELECT * 
FROM corona_virus
WHERE Province IS NULL
OR Country_Region IS NULL
OR Latitude IS NULL
OR Longitude IS NULL
OR Confirmed IS NULL
OR Deaths IS NULL
OR Recovered IS NULL
OR DATE IS NULL;
 
-- Q1. Write a code to check NULL values
SELECT *
FROM corona_virus
WHERE Province IS NULL
   OR country_Region IS NULL
   OR Latitude IS NULL
   OR Longitude IS NULL
   OR Confirmed IS NULL
   OR Deaths IS NULL
   OR Recovered IS NULL
   OR Date IS NULL;

SELECT *
FROM 
   corona_virus
WHERE 
   COALESCE(Province, country_Region, Latitude, Longitude, Date, Confirmed, Deaths, Recovered) IS NULL;
# Output: In this table there is no null values.

-- Q2. If NULL values are present, update them with zeros for all columns. 

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Perform the update
UPDATE corona_virus
SET 
    Province = COALESCE(Province, '0'),
    country_Region = COALESCE(country_Region, '0'),
    Latitude = COALESCE(Latitude, '0'),
    Longitude = COALESCE(Longitude, '0'),
    Date = COALESCE(Date, '0'),
    Confirmed = COALESCE(Confirmed, '0'),
    Deaths = COALESCE(Deaths, '0'),
    Recovered = COALESCE(Recovered, '0');

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Verify the update
/* SELECT * FROM corona_virus
WHERE Province = '0'
   OR country_Region = '0'
   OR Latitude = '0'
   OR Longitude = '0'
   OR Date = '0'
   OR Confirmed = '0'
   OR Deaths = '0'
   OR Recovered = '0';
   */
   
   -- check 0 value in Province, Country_Region and in Date coumn
SELECT *
FROM corona_virus
WHERE Province = '0' OR country_Region = '0' OR Date = '0'; 
/*
 In above code getting error for Date column. that is incorrect value for Date.
 Might be MySQL consider 0 as string adnd date datatype is date.
*/

DESCRIBE CORONA_VIRUS; # To check the datatype for each columns

# alternate query to check "0" value in columns

SELECT *
FROM corona_virus
WHERE Province LIKE '0'
   OR country_Region LIKE '0'
   OR Date LIKE '0'; # Return nothing means there are no "0" value in respective columns
  
  -- Q3. check total number of rows
SELECT 
   COUNT(*) AS Total_Rows
FROM 
   corona_virus; # 78385

-- Q4. Check what is start_date and end_date

SELECT MIN(date) AS START_DATE, MAX(date) AS END_DATE
FROM corona_virus;
 
-- Q5. Number of month present in dataset

/*SELECT COUNT(DISTINCT DATE_FORMAT(Date, '%Y-%m')) AS unique_months
FROM corona_virus;
*/
-- LIST YEAR AND MONTH FROM DATE 
SELECT DISTINCT(DATE_FORMAT(Date, '%Y-%b')) AS YEAR_MONTHS
FROM corona_virus;

-- COUNT NUMBER OF MONTHS
SELECT COUNT(DISTINCT(DATE_FORMAT(Date, '%Y-%b'))) AS TOTAL_MONTHS
FROM corona_virus; # 18 MONTHS MEANS 18 ROWS RETURN

-- EXTRACT MONTHS (ARVIND REVIEW)
SELECT 
   MONTH(DATE) AS MONTHS, 
   COUNT(*) AS NO_MONTH
FROM 
   corona_virus
GROUP BY 
   MONTHS; # 12 MONTHS

-- Q6. Find monthly average for confirmed, deaths, recovered

SELECT # in this format output will be sorted in year and months wise like 2020-Jan, 2020-Feb,,,so on
   DATE_FORMAT(Date, '%b-%Y') AS YEAR_MONTHS,
   FLOOR(AVG(Confirmed)) AS AVG_CONFIRMED_CASES,                     
   FLOOR(AVG(Recovered)) AS AVG_RECOVERED_CASES,                     
   FLOOR(AVG(Deaths)) AS AVG_NO_OF_DEATHS
FROM 
   corona_virus
GROUP BY 
   YEAR_MONTHS; 
/*   YEAR(Date), MONTH(Date),YEAR_MONTHS
ORDER BY 
   YEAR(Date), MONTH(Date), YEAR_MONTHS;
*/
-- Another way------------------
/* SELECT (DATE_FORMAT(Date, '%Y-%M')) AS YEAR_MONTHS 
FROM corona_virus; # '%M' RETURNS MONTH NAME AND '%m' RETURN MONTH NUMBER
*/
SELECT 
   DISTINCT((DATE_FORMAT(Date, '%Y-%b'))) AS YEAR_MONTHS, # %b RETURN SHORT NAME FOR MONTHS AND %M RETURN FULL NAME
   FLOOR(AVG(Confirmed)) AS AVG_CONFIRMED_CASES,                     
   FLOOR(AVG(Recovered)) AS AVG_RECOVERED_CASES,                     
   FLOOR(AVG(Deaths)) AS AVG_NO_OF_DEATHS
FROM corona_virus
GROUP BY YEAR_MONTHS
ORDER BY YEAR_MONTHS;

-- USED MONTH FUNCTION TO EXTRACT MONTH
SELECT 
   MONTH(Date) AS MONTHS, # GET MONTH NUMBER INSTEAD OF MONTH NAME
   FLOOR(AVG(Confirmed)) AS CONFIRMED_CASES,
   FLOOR(AVG(Recovered)) AS RECOVERED_CASES,
   FLOOR(AVG(Deaths)) AS NO_OF_DEATHS
FROM corona_virus
GROUP BY MONTHS
ORDER BY MONTHS; # HERE ONLY MONTH INCLUDED NOT YEAR
   
-- Another way to solve this query------------------------------------------------
SELECT 
   DATE_FORMAT(Date, '%Y-%m') AS YEAR_MONTHS,
   DATE_FORMAT(DATE,'%b') AS MONTH_NAME,
   FLOOR(AVG(Confirmed)) AS AVG_CONFIRMED_CASES,                     
   FLOOR(AVG(Recovered)) AS AVG_RECOVERED_CASES,                     
   FLOOR(AVG(Deaths)) AS AVG_NO_OF_DEATHS
FROM corona_virus
GROUP BY YEAR_MONTHS, MONTH_NAME
ORDER BY YEAR_MONTHS;

-- Q7. Find most frequent value for confirmed, deaths, recovered each month 
SELECT
    DATE_FORMAT(Date, '%Y-%b') AS YEAR_MONTHS,
    SUBSTRING_INDEX(GROUP_CONCAT(Confirmed ORDER BY Confirmed DESC), ',', 1) AS most_frequent_confirmed,
    SUBSTRING_INDEX(GROUP_CONCAT(Deaths ORDER BY Deaths DESC), ',', 1) AS most_frequent_deaths,
    SUBSTRING_INDEX(GROUP_CONCAT(Recovered ORDER BY Recovered DESC), ',', 1) AS most_frequent_recovered
FROM 
    corona_virus
GROUP BY
    YEAR(DATE),MONTH(DATE),YEAR_MONTHS
ORDER BY
    YEAR(DATE),MONTH(DATE),YEAR_MONTHS;

-- Q8. Find minimum values for confirmed, deaths, recovered per year

/* SELECT DISTINCT(DATE_FORMAT(DATE, '%Y')) AS YEAR,
   MIN(Confirmed) AS `MIN OF CONFIRMED CASES`,
   MIN(Recovered) AS `MIN OF RECOVERED CASES`,
   MIN(Deaths) AS `MIN OF DEATHS`
FROM corona_virus
GROUP BY YEAR;
*/
SELECT YEAR(date) AS YEAR,
   MIN(Confirmed) AS `MIN OF CONFIRMED CASES`,
   MIN(Recovered) AS `MIN OF RECOVERED CASES`,
   MIN(Deaths) AS `MIN OF DEATHS`
FROM 
   corona_virus
GROUP BY 
   YEAR;

-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT YEAR(date) AS YEAR,
   MAX(Confirmed) AS `MAX OF CONFIRMED CASES`,
   MAX(Recovered) AS `MAX OF RECOVERED CASES`,
   MAX(Deaths) AS `MAX OF DEATHS`
FROM 
   corona_virus
GROUP BY 
   YEAR;

-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT 
    date_format(DATE, '%Y-%b') AS MONTH, 
    SUM(Confirmed) AS TOTAL_CONFIRMED_CASES,
    SUM(Recovered) AS TOTAL_RECOVERED_CASES,
    SUM(Deaths) AS TOTAL_DEATHS
FROM 
    corona_virus
GROUP BY 
    MONTH;
    
-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
   SUM(Confirmed) AS TOTAL_CONFIRMED_CASES,
   ROUND(AVG(Confirmed),2) AS AVG_CONFIRMED_CASES,
   ROUND(VARIANCE(Confirmed),2) AS VAR_CONFIRMED_CASES,
   ROUND(STDDEV(Confirmed),2) AS STDEV_CONFIRMED_CASES
FROM 
   corona_virus;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT
   DATE_FORMAT(DATE, '%Y-%b') AS YEAR_MONTHS,
   SUM(Deaths) AS TOTAL_DEATHS,
   ROUND(AVG(Deaths),2) AS AVERAGE_DEATHS,
   ROUND(VARIANCE(Deaths),2) AS VARIANCE_DEATHS,
   ROUND(STDDEV(Deaths),2) AS STDDEV_DEATHS
FROM 
   corona_virus
GROUP BY 
   YEAR_MONTHS; # IN THIS WAY RESULT WILL BE SORTED IN YEAR AND MONTH WISE LIKE 2020-JAN, 2020-FEB LIKE THAT
-- ORDER BY
   -- YEAR_MONTHS;
   
-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
   SUM(Recovered) AS TOTAL_RECOVERED_CASES,
   ROUND(AVG(Recovered),2) AS AVG_RECOVERED_CASES,
   ROUND(VARIANCE(Recovered),2) AS VAR_RECOVERED_CASES,
   ROUND(STDDEV(Recovered),2) AS STDEV_RECOVERED_CASES
FROM 
   corona_virus;

-- Q14. Find Country having highest number of the Confirmed case

SELECT 
   COUNTRY_REGION, 
   SUM(CONFIRMED) AS TOTAL_CONFIRMED_CASES
FROM 
   corona_virus
GROUP BY 
   Country_Region
ORDER BY 
   TOTAL_CONFIRMED_CASES DESC
LIMIT 1;

-- Q15. Find Country having lowest number of the death case

SELECT 
  COUNTRY_REGION, 
  SUM(Deaths) AS TOTAL_DEATHS
FROM 
   corona_virus
GROUP BY 
   Country_Region
ORDER BY 
   TOTAL_DEATHS ASC
LIMIT 1;

-- Q16. Find top 5 countries having highest recovered case

SELECT 
   COUNTRY_REGION, 
   SUM(Recovered) AS TOTAL_RECOVERED
FROM 
   corona_virus
GROUP BY 
   Country_Region
ORDER BY 
   TOTAL_RECOVERED DESC
LIMIT 5;

-- IN TERMS OF PERCENTAGE NUMBER OF RECOVERED CASES ARE DIFFERENT
SELECT 
    country_Region,
    SUM(Recovered) AS total_recovered,
    SUM(Confirmed) AS total_confirmed,
    (SUM(Recovered) / SUM(Confirmed)) * 100 AS recovery_percentage
FROM corona_virus
GROUP BY country_Region
HAVING SUM(Confirmed) > 0 -- To avoid division by zero
ORDER BY recovery_percentage DESC
LIMIT 5;

-- --------------DONE BY ANNU JHA-------------------------------------------------------------



