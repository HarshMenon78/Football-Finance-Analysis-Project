/* Problem 1 : Calculate the total revenue and total expenditure for each club, and rank them from highest to lowest revenue : 
   - First we will retrieve all the club info i.e the club_id and their corresponding club_name from the club_dim table, for which we will mention the club_dim table in the JOIN statement after mentioning the FROM club_revenue table, which we will join on the basis of common column of club_id. Similarly we will also JOIN the club_expenditure table with the club_revenue table on the common column of club_id, to overall find the club's(id's) corresponding name from club_dim, revnue figure from culub_revenue & expenditure figures from club_expenditure table.
   - Then in we are going to retrieve the SUM of all the amount_euros_millions of revenue corresponding to that club_id and club_name, which will be done by using the SUM() aggregation function on the amount_euros_millions column of the club_revenue table and same with the amount_euros_millions from the club_expenditure table.
   - In the GROUP BY clause we will group the result on the basis of each groups present in the club_id comumn and club_name column , making cohort group of club_id and their corresponding club_names, since each club_id has only one club_name corresponding to it, it will show the aggregation result of "total_revenue" of that club corresponding to its club_id and corresponding club_name.
   - Finally we use ORDER BY clause to order the result in descending order(using DESC) of total_revenue, so that the club with highest revenue will be at the top and the club with lowest revenue will be at the bottom.
   - Here we have to keep the approach of creating seperate CTEs to retrieve total revenue and total expenditure figures , since the amount_euros_millions being common in both them will cause calculation errors if we decide to stick to the no CTE approach and call both these SUM values in the main clause's SELECT statement making sure we JOIN the tables... so it will cause errors and we need to avoid that method.
*/
WITH total_club_revenue AS ( -- In this CTE we will retrieve the club info(club_id) and their corresponding total revenue i.e the SUM of amount_euros_millions of all the revenue_streams which generate the club revenue.
SELECT -- retrieves the club info(of club_id, club_name) and their corresponding total revenue in euros (in millions) from the club revenue table.
    club_id,
    SUM(amount_euros_millions) AS total_revenue -- will retrieve the SUM of all the amount_euros_millions of revenue corresponding to that club_id from the club_revenue table.
FROM -- this is the club_revenue table which contains the revenue data of each club.
    club_revenue
GROUP BY -- this groups the result on the basis of each groups present in the club_id column.
    club_id
),
total_club_expenditure AS ( -- In this CTE we will retrieve the club info(club_id) and their corresponding total expenditure i.e the SUM of amount_euros_millions of all the expenditure_streams which the club incurred in that season.
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_expenditure -- will retrieve the SUM of all the amount_euros_millions of expenditure corresponding to that club_id from the club_expenditure table.
FROM -- this is the club_expenditure table which contains the expenditure data of each club.
    club_expenditure
GROUP BY -- this groups the result on the basis of each groups present in the club_id column.
    club_id
)
SELECT
    cd.club_id, ----|
    cd.club_name,---|-- will retireve the club_id and their corresponding club_names from the club_dim table.
    total_revenue,
    total_expenditure
FROM
    club_dim AS cd
JOIN -- Inner joining the tables of club_dim and total_club_revenue, to display all the clubs which are common in both the tables...(even if we had used the LEFT JOIN or RIGHT JOIN the result would have been the same , since both the tables include exatly all the same clubs mentioned in both entirely, hence in case of LEFT JOIN if all the clubs of left table[cr] was mentioned in the club_id common column, then its corresponing value from right table will also exist which will be non null since both the tables consist all the clubs mentioned in either of them, no more no less, hence same will be the case in RIGHT JOIN , if all the clubs from the right table[cd] will be displayed , their corresponding info from cr table will also be existing which is non null similarly)
    total_club_revenue AS tcr ON cd.club_id = tcr.club_id
JOIN -- Inner joining the tables of club_dim and total_club_expenditure on the basis of common column of club_id, to basically also find the expenditure figures(i.e tce.amount_euros_millions) of each of the clubs corresponding to their revenue figures fetched from total_club_revenue table and their name fetched from club_dim table on the basis of the common column of club_id present between all three of these tables.
    total_club_expenditure AS tce ON cd.club_id = tce.club_id
ORDER BY -- this will order the result in descending order of total_revenue, so that the club with highest revenue will be at the top and the club with lowest revenue will be at the bottom.
    total_revenue DESC;

/* Problem 2 :  For each club, calculate the percentage contribution of each revenue stream (Matchday, Broadcast, Sponsorship, Other) to total revenue :- 
   - First we create a CTE called club_rev_info, which will retrieve the club_id, revenue_type, amount_euros_millions and total_revenue_of_club using the SUM() aggregation function used along the window function[using OVER()] so that the total_revenue of each club is shown corresponding to each of their partition of club_id.
   - Then in the main query we will retrieve all the columns called in the previous CTE of club_rev_info and also retrieve the club_name from the club_dim table by joining it with the club_rev_info CTE on the basis of common column of club_id.
   - We will also calculate the percentage contribution of each revenue stream to total revenue of that club using the formula (amount_euros_millions/total_revenue_of_club) * 100 and round it upto 2 decimal places using the ROUND() function.
   - Finally we use ORDER BY clause to order the result in descending order(using DESC) of total_revenue_of_club, so that the club with highest total revenue will be at the top and the club with lowest total revenue will be at the bottom.
*/
WITH club_rev_info AS ( -- This CTE will retrieve the club_id, revenue_type, amount_euros_millions and total_revenue_of_club using the SUM() aggregation function used along the window function[using OVER()] so that the total_revenue of each club is shown corresponding to each of their partition of club_id, i.e corresponding to each row on the basis of their club_id their total_revenue_of_club will be shown.
SELECT
    club_id, ----------------|
    revenue_type, -----------| -- Will retrieve club's revenue info like club_id, revenue_type and amount_euros_millions from the club_revenue table.
    amount_euros_millions, --|
    SUM(amount_euros_millions) OVER(PARTITION BY club_id) AS total_revenue_of_club -- this will retrieve the total revenue of the club, since we used the SUM() aggregation function along with the window function[using OVER()] where we mentioned the PARTITION BY sub-clause and mentioned the column of club_id, so the total_revenue of each club is shown corresponding to each of their partition of club_id.
FROM
    club_revenue
)
SELECT -- This main query will retrieve all the columns called in the previous CTE of club_rev_info and also retrieve the club_name from the club_dim table by joining it with the club_rev_info CTE on the basis of common column of club_id, and also calculate the percentage contribution of each revenue stream to total revenue of that club using the formula (amount_euros_millions/total_revenue_of_club) * 100 and round it upto 2 decimal places using the ROUND() function.
    cri.club_id,
    cd.club_name,
    revenue_type,
    amount_euros_millions,
    total_revenue_of_club,
    ROUND(((amount_euros_millions/total_revenue_of_club) * 100), 2) AS percentage_revenue_stream_makes_of_total_revenue_of_club -- this will calculate the percentage contribution of each revenue stream to total revenue of that club using the formula (amount_euros_millions/total_revenue_of_club) * 100 and round it upto 2 decimal places using the ROUND() function.
FROM
    club_rev_info AS cri
JOIN -- Inner joining the CTE of club_rev_info and the club_dim table, to display all the clubs which are common in both the tables...(even if we had used the LEFT JOIN or RIGHT JOIN the result would have been the same , since both the tabeles include exatly all the same clubs mentioned in both entireley, hence in case of LEFT JOIN if all the clubs of left table[cri] was mentioned in the club_id common column, then its corresponing value from right table will aslo exist which will be non null since both the tables consist all the clubs mentioned in either of them , no more no less, hence same will be the case in RIGHT JOIN , if all the clubs from the right table[cd] will be displayed , their corresponding info from cri table will also be existing which is non null similarly. 
    club_dim AS cd ON cri.club_id = cd.club_id
ORDER BY -- Finally we use ORDER BY clause to order the result in descending order(using DESC) of total_revenue_of_club, so that the club with highest total revenue will be at the top and the club with lowest total revenue will be at the bottom.
    total_revenue_of_club DESC;

/* Problem 3 : Identify the single dominant (highest-contributing) revenue stream for each club :- 
   - First we create a CTE called club_rev_info, which will retrieve the club_id, revenue_type, amount_euros_millions and also rank the revenue streams for each club based on their contribution to total revenue using the DENSE_RANK() window function, which will assign a rank to each revenue stream for each club based on their amount_euros_millions in descending order.
   - Then in the main query we will retrieve all the info called out in the previous CTE of club_rev_info and also retrieve the club_name from the club_dim table by joining it with the club_rev_info CTE on the basis of common column of club_id.
   - We will also filter out the revenue streams for each club which has the rank of 1 using the WHERE clause, i.e the revenue stream which has the highest contribution to total revenue of that club, since we are only interested in the single dominant (highest-contributing) revenue stream for each club.
   - Finally we use ORDER BY clause to order the result in descending order(using DESC) of amount_euros_millions, so that the club with highest revenue stream will be at the top and the club with lowest revenue stream will be at the bottom.
*/
WITH club_rev_info AS ( -- This CTE will retrieve the club info(i.e club_id, revenue_type, amount_euros_millions) and also rank the revenue streams for each club based on their contribution to total revenue using the DENSE_RANK() window function, which will assign a rank to each revenue stream for each club based on their amount_euros_millions in descending order.
SELECT
    club_id, ----------------|
    revenue_type, -----------| -- Will retrieve the club's revenue info like club_id, revenue_type & amount_euros_millions from the club_revenue table.
    amount_euros_millions, --|
    DENSE_RANK() OVER(PARTITION BY club_id ORDER BY amount_euros_millions DESC) AS rnk_club_revenue_type -- this will rank the revenue streams for each club based on their value(amount_euros_millions arranged in descending order) using the DENSE_RANK() window function, we used the DENSE_RANK() instead of the normal RANK() or ROW_NUMBER() function, since we want to assign the same rank to the revenue streams with the same value of amount_euros_millions, and for the next revenue stream in order of their value should be assigned the next rank in order without any gaps in ranking , like it does in the case if we had used the RANK() function.
FROM -- we are retrieving the clubs' revenue information from club_revenue table.
    club_revenue
)
SELECT -- In this Main query we will retrieve all the info called out in the previous CTE of club_rev_info and also retrieve the club_name from the club_dim table by joining it with the club_rev_info CTE on the basis of common column of club_id, and also filter out the revenue streams for each club which has the rank of 1.
    cri.club_id, -- since this column is ambigous(i.e present in both the tables), we had to mention the reference of the table from which we are retrieving this column, hence we mentioned the reference of the CTE of club_rev_info as cri.club_id.
    cd.club_name, -- since this coulumn is the foreign table's column, we just mentioned the table reference for the simplicity of understanding the code, in the JOIN statement to tell apart which column is being pulled from which table in this joining of the two tables.
    revenue_type,
    amount_euros_millions,
    rnk_club_revenue_type
FROM
    club_rev_info AS cri
JOIN -- this will inner join the CTE of club_rev_info(taken as the left table) and the club_dim table(taken as the right table), to display all the clubs which are common in both the tables i.e all the clubs overlall in the dataset...(even if we had used the LEFT JOIN or RIGHT JOIN to join the two tables, the result would have been the same , since both the tabeles include exatly all the same clubs mentioned in both entireley, hence in case of LEFT JOIN if all the clubs of left table[cri] was mentioned in the club_id common column, then its corresponing value from right table[cd] will also exist which will be non null since both the tables consist all the clubs mentioned in either of them , no more no less, hence same will be the case in RIGHT JOIN but vice-versa.
    club_dim AS cd ON cri.club_id = cd.club_id
WHERE -- this will filter out the revenue streams for each club which has the rankof 1, i.e the revenue stream which has the highest contribution to total revenue of that club, since we are only interested in the single dominant (highest-contributing) revenue stream for each club.
    rnk_club_revenue_type = 1
ORDER BY -- this will order the result in descending order of amount_euros_millions, so that the club with highest revenue stream will be at the top and the club with lowest revenue stream will be at the bottom.
    amount_euros_millions DESC;