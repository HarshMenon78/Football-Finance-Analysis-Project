-- Create the football finance database :-
CREATE DATABASE football_finance_db;

/* Create the tables for the football finance database(club_dim, club_revenue, club_expenditure) :-
*/
-- Club Dimension Table (club_dim) : This table will contain the details of the football clubs, such as club name, country, league, domestic league rank, UCL stage, ownership type, city, and stadium name. The primary key for this table will be the club_id.
CREATE TABLE club_dim (
    club_id VARCHAR(10) PRIMARY KEY,
    club_name VARCHAR(100),
    country VARCHAR(50),
    league VARCHAR(100),
    domestic_league_rank_2024_25 INT,
    ucl_stage_2024_25 VARCHAR(50),
    ownership_type VARCHAR(50),
    city VARCHAR(20),
    stadium_name VARCHAR(100)
);

-- Club Revenue Table (club_revenue) : This table will contain the revenue details of the football clubs, such as revenue type and amount in euros (in millions). The primary key for this table will be a combination of club_id, season, and revenue_type. The club_id will be a foreign key referencing the club_dim table.
CREATE TABLE club_revenue (
    club_id VARCHAR(10) REFERENCES club_dim(club_id),
    season VARCHAR(10),
    revenue_type VARCHAR(50),
    amount_euros_millions NUMERIC(6,2),
    PRIMARY KEY (club_id, season, revenue_type)
);

-- Club Expenditure Table (club_expenditure) : This table will contain the expenditure details of the football clubs, such as expenditure type and amount in euros (in millions). The primary key for this table will be a combination of club_id, season, and expenditure_type. The club_id will be a foreign key referencing the club_dim table.
CREATE TABLE club_expenditure (
    club_id VARCHAR(10) REFERENCES club_dim(club_id),
    season VARCHAR(10),
    expenditure_type VARCHAR(50),
    amount_euros_millions NUMERIC(6,2),
    PRIMARY KEY (club_id, season, expenditure_type)
);

-- Import the data from the cleaned CSV files into our newly created empty tables inside the football finance database(it dosent really matter if the names of the column headers is different in the csv file and the table created, since its a comma seperated value and we have included that there are headers present [HEADERS TRUE], it will automatically ignore the column headers mentioned in the CSV files(i.e the first row of the csv) and keep the original headers of the empty tables we created in the database) :-
COPY club_dim -- basically reffers to "copy the below given file with its provided link in the FROM statement into the recently created table(of club_dim existing in our football_finance_db SQL database) beside COPY statement".
FROM 'C:\Users\Harsh\OneDrive\Desktop\Data Analytics Projects\Football Finance Analysis Project\Data\Cleaned Data\CSV\Club_dim.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

COPY club_revenue -- basically reffers to "copy the below given file with its provided link in the FROM statement into the recently created table(of club_revenue existing in our football_finance_db SQL database) beside COPY statement".
FROM 'C:\Users\Harsh\OneDrive\Desktop\Data Analytics Projects\Football Finance Analysis Project\Data\Cleaned Data\CSV\Club_Revenue.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

COPY club_expenditure -- basically reffers to copy into... i.e copy the data from the table whose path/link is provided in the FROM statement into the newly created table of club_expenditure, the only way this will work is if the table data(in FROM statement) matches the format how club_expenditure table in our postgresql database was designed with tits columns and its datatypes.
FROM 'C:\Users\Harsh\OneDrive\Desktop\Data Analytics Projects\Football Finance Analysis Project\Data\Cleaned Data\CSV\Club_Expenditure.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

-- Confirm if the data has been successfully imported to each of the columns of the newly created tables :-
SELECT * FROM club_dim;
SELECT * FROM club_revenue;
SELECT * FROM club_expenditure;

-- Altering the table structure of the tables using "ALTER TABLE" command to fix the data type missmatched lengths done by mistake previously while creating the tables(since the changes to be made in were only in the club_dim table we only included that) :-
ALTER TABLE club_dim ALTER COLUMN club_name TYPE VARCHAR(50);
ALTER TABLE club_dim ALTER COLUMN league TYPE VARCHAR(50);
ALTER TABLE club_dim ALTER COLUMN stadium_name TYPE VARCHAR(50);