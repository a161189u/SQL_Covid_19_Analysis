-- ---------------------CORONA VIRUS ANALYSIS --------------------------------
-- Creating Database
CREATE DATABASE IF NOT EXISTS CORONA_VIRUS_DATA;

-- Set this databse as default database for further analysis
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
SELECT COUNT(*) FROM corona_virus; # 78386

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







