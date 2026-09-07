/* Problem 4 : Calculate the net operating position(Total Revenue − Total Expenditure) for each club and flag whether it is a surplus or deficit :- 
   - We create the first CTE named rev_total, where we will retrieve the club_id and find the SUM of amount_euros_millions for all the revenue types existing for that club_id(for which will group the CTE's query with club_id using GROUP BY clause) from the club_revenue table.
   - Similarly we also create the second CTE named exp_total where in we will again retrieve the club_id and its SUM of amount_euros_millions but this time from club_expenditure table and group it on the basis of club_id(using GROUP BY clause and mentioning club_id in it) so that the SUm of all the amount_euros_millions for all the expenditure types existing for that club_id is calculated mentioned in the club_expenditure table.
   - Then in the main query we will retrieve the club's revenue & expenditure info mentioned in the above two CTE's and also retrieve its club_name from the club_dim table, for all of which we need to assign their tables's aliasses as references... and to make the columns of all these tables work together we will INNER JOIN them on the common column of club_id, so that corresponding to each club_id which is common in all three tables(all the clubs in the dimension table of club_dim is being shown in both the facts tables of club_revenue and club_expenditure, so we can give any table reference to the club_id column) their corresponding total of amount_euros_millions from the club_revenue and the total of amount_euros_millions from the club_expenditure table be shown in the result-set.
   - Also in the main query we will create the entity of 'balance' for which we will subtract the club's expenditure from club's revenue, we will also create the entity of 'balance_status' for which we will use CASE statements to assign the results of that entity/column on the basis of the club's balance figures , if the balance > 0 THEN 'Surplus' ELSE 'Deficit'.
   - Finally we will arrange the results displayed in the result-set called out in the main query(i.e club_id, club_name[from club_dim table], total_revenue[from rev_total CTE{which further takes it from club_revenue table}] & total_expenditure[from exp_total CTE{which furthermore retrieves it from club_ependiture table}]) in descending order of their total_revenue & total_exenditure using ORDER BY clause & DESC keyword. The result will be arranged in descending order of total_revenue first, in case any two or more club's revenue are same then they will be arranged in ascending order of their expenditure(i.e out of the clubs with same revenue the clubs having the least expenditure will be appearing first in the arrangement).
*/
WITH rev_total AS ( -- This CTE will retrieve us the club-wise(club_id-wise) distribution of revenue, by finding the total revenue of each club_id by summing up the amount_euros_millions(using SUM() aggregation function) of each of the club's revenue_type(which corresponds to the club_id) with each other.
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_revenue -- This will calculate the total revenue for each club by summing up the amount_euros_millions for each club_id from the club_revenue table(i.e of all its revenue streams).
FROM -- will retrieve the data from the club_revenue table, since this table is what contains the revenue data for each club, and when we SUM the amount_euros_millions for each club_id, we will get the total revenue for each club.
    club_revenue
GROUP BY -- Grouping the result by the existing categories in club_id column to calculate total revenue for each club, i.e get the aggregated results(SUM of amount_euros_millions) for each categories in club_id i.e for each club in our revenue table.
    club_id
), exp_total AS ( -- This CTE will retrieve us the club-wise(club_id-wise) distribution of expenditure, by finding the total expenditure of each club_id by summing up the amount_euros_millions(using SUM() aggregation function) of each of the club's expenditure_type(which corresponds to the club_id) with each other.
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_expenditure -- This will calculate the total expenditure for each club by summing up the amount_euros_millions for each club_id from the club_expenditure table(i.e of all its expenditure streams).
FROM -- will retrieve the data from the club_expenditure table, since this table is what contains the expenditure data for each club, and when we SUM the amount_euros_millions for each club_id, we will get the total expenditure for each club.
    club_expenditure
GROUP BY -- Grouping the result by the existing categories in club_id column to calculate total expenditure for each club, i.e get the aggregated results(SUM of amount_euros_millions) for each categories in club_id i.e for each club in our expenditure table.
    club_id
)
SELECT -- In the main query we will retrieve the club-info of club_id which is common in both the CTE(and the tables used in the CTE) which we made, club_name from the club_dim table, total_revenue from the rev_total CTE, total_expenditure from the exp_total CTE, then the balance will also be calculated by subtracting the total_expenditure from the total_revenue, also we use CASE statements to determine the balance status. Then finally make all these columns synchronize with each other we use JOIN statement to inner join all the tables with each other on the common column which is club_id.
    cd.club_id, --------|
    cd.club_name, ------|-- retrieved club_id and club_name from the club_dim table which contains the club information.
    rt.total_revenue, --|
    et.total_expenditure, --|-- We retrieved the club-wise total_revenue and total_expenditure from the CTEs we made, rev_total and exp_total respectively.
    (rt.total_revenue - et.total_expenditure) AS operating_position, -- We calculated the operating_position by subtracting the total_expenditure from the total_revenue for each club.
    CASE -- we used the CASE statement to tetermine the balance status of each club, if the balance of the club is greater than 0 then it is a surplus, else it is a deficit.
        WHEN (rt.total_revenue - et.total_expenditure) > 0 THEN 'Surplus'
        ELSE 'Deficit'
    END AS balance_status
FROM -- Retrieved the information originally from the club_dim table, though it dosent carry the info of total_revenue and total_expenditure, but it carries the club_id and club_name which is mentioned in the very top linked to it, and the rest of the entities will be retrieved from the created CTEs which will be mentioned in the JOIN clauses joined to the club_dim table on club_id column and hence will carry the references to the other entities called in the select clause too, so it was optional to put it in the FROM statement, but we put it to make the query more readable and understandable, if we choose not to put that and put any CTE which we created first , we will have to tailor our JOIN clause tables mentioned accordingly.
    club_dim AS cd
JOIN -- We used JOIN statement to inner join the club_dim table with the rev_total CTE on the common column of club_id, so along the club_id and their club_name displayed in SELECT clause, their corresponding total_revenue will also be displayed in the SELECT clause itself which is present in the rev_total CTE.
    rev_total AS rt ON cd.club_id = rt.club_id
JOIN -- We used JOIN statement to inner join the club_dim table with the exp_total CTE on the common table of club_id, so along with the club_id, club_name from the club_dim table and their corresponding total_revenue from the exp_total CTE(which was previously inner joined to club_dim) will also be shown, we also get their corresponding total_expenditure from the exp_total CTE.
    exp_total AS et ON cd.club_id = et.club_id
ORDER BY -- This will finally we order the resut in descending order of total_revenue and total_expenditure using DESC keyword, so that the clubs with the highest total_revenue and total_expenditure will be displayed first in the result set(in case two or more club's total_revenue is the same , then they will be arranged in descending order of total_expenditure i.e the club having the most total_expenditure will be displayed first in the result set, since in the ORDER BY clause we have mentioned total_revenue first and then total_expenditure, so that means the total_revenue will be given more priority than total_expenditure in the ordering of the result set).
    total_revenue DESC,
    total_expenditure;

/* Problem 5: For each club, break down expenditure by category (Wages, Amortisation, Other Operating, Net Interest) and show each category's percentage share of total club expenditure :- 
   - We will create the first CTE of expenditure_info wher we will retrieve all the info of the club's individual expenditure_type and its corresponding amount_euros_millions of that particular expenditure type, also corresponding to it we will find the aggregated value of total_expenditure_club using window function(since window function is used in situations like these where we need to retrieve the aggregated values corresponding to the individual row info from the original table[in this case of club_expenditure table], and we would use GROUP BY in those cases where we want a colum's group/category-wise aggrgated value distribution).
   - Also in the first CTE of expenditure_info we are going to retrieve the club_name info of the club_id corresponding to which we retrieved their expenditure info form club_expenditure table, this club_name info of the club_ids exist in club_dim, for which we will need to JOIN the tables together where we chose INNER JOIN so that we can join club_expenditure(from where we retrieve the individual and  total expenditure info respectiveley) with club_dim(from where we retrieve the club_name info of all the club_id's whose corresponding expenditure related info we retrieved from ce table) so that we retrieve their corresponding info, INNER JOIN will be done on the common column of a club_id, and it will retrieve info which will be common in both the cd and ce table which is all the clubs(since the club detailed in club_dim is being mentioned in ce table).
   - In the main query we will retrieve all the info from first CTE of expenditure_info(club_id, club_name, expenditure_type, its correspnding amount_euros_millions & total_expenditure club in window function) and also will also declare a new entity named category_percentage_to_total_club_expenditure which will give us the percentage values of what that amount of that particular expenditure of the club makes up of the total expenditure of the club.
   - Finally we will order the result in descending order of total_expense_club_millions(the total expenditure of the club) so that the clubs having the most total expenditure be shown first and if multiple clubs have same total_expenditure then the clubs will be arranged in ascending order of their club_names.
*/
WITH expenditure_info AS ( -- In this CTE we will retrieve the info of club(id, name) their expenditure streams(expenditure_category) and the amount incurred on that expense stream by the club(amount_euros_millions), all while also beside each of these row explaining the expenditure streams and their amounts, their club's total expenditure will also be shown alongside them creating a new entity(will be shown as a new column which shows the total expense incurred by the club, whoose expenditure stream and the amount on that expense is being shown in that particular row).
SELECT
    ce.club_id, -- will show the club_id from the joint between the club_expenditure table(mentioned in the FROM statement) and club_dim table(mentioned in the JOIN statement), since club_id is an ambigous column so we haad to mention from which table we retrieving the column's value from , but end of the day it doesent actually retrieves the values from there its just a reference and the actual retrieval is done on the basis of what kinda JOIN is used(Left/Right/Inner)
    cd.club_name, -- will retrieve the club_name from the joint between the club_expenditure table(mentioned in the FROM statement) and club_dim table(mentioned in the JOIN statement), now here club_name isn't an ambigous column(i.e appearing in any other table and only exists in club_dim table) but we mentioning the table reference for understanding simplicity.
    expenditure_type, -------|-- Will find out the expenditure_type & amount_euros_millions of the expenditure in figures respectiveley.
    amount_euros_millions, --|
    SUM(amount_euros_millions) OVER(PARTITION BY ce.club_id) AS total_expense_club_millions -- We are using window function(by using the window function OVER()) to find out the aggregated result of SUM over amount_euros_millions over the PARTITION of each of the club_ids(clubs) to find their corresponding total expense corresponding to each of the row from the result set which has that particular club_id... basically distributing the total_expense club-wise throughout all the clubs in the result-set.
FROM
    club_expenditure AS ce
JOIN -- Since we mentioned club_name in the SELECT clause, we will have to retrieve the info of the club's name from the club_dim table corresponding to the club_id which is mentioned in club_expense with the expense details... We used INNER JOIN to join the two tables of club_dim & club_expenditure together on the common column of club_id here which will ensure that only the common values from the common columns of both tables i.e the club_id column be shown in the result-set.
    club_dim AS cd ON cd.club_id = ce.club_id
)
SELECT -- In the Main query we will call out all the columns and entities we called in the previous CTE of expenditure_info and then we will also create a new entity called 'category_percentage_to_total_club_expenditure' which will find out the percentage each of the expenditure category's amount makes up to the total expenditure amount of that club.
    club_id,
    club_name,
    expenditure_type,
    amount_euros_millions,
    total_expense_club_millions,
    ROUND((amount_euros_millions / total_expense_club_millions) * 100, 2) AS category_percentage_to_total_club_expenditure -- this entity finds out what percentage the expense category's amount makes up of the total expenditure amount of the club, for which we will use the formula ((expense amount / total expense of club) * 100) hence this will give the what percentage figures of how much that expense category's amount makes up of the total expense amount of the club, and the ROUND('formula',2) will ensure the outputed result is in 2 decimal places.
FROM
    expenditure_info AS ei
ORDER BY -- Will make sure the result is arrranged in descending order of total_expense_club(i.e the clubs having the most expenditure be shown at top) & secondly on the basis of ascending order of club_name(i.e in case if 2 or more clubs have the same total_expense amount, then the club having the orderwise earlier alphabets in its name be appearing first).
    total_expense_club_millions DESC,
    category_percentage_to_total_club_expenditure DESC;

/* Problem 6 : Rank all 10 clubs on the basis of their net operating position's(i.e total_revenue - total_expenditure of that club, better called the net operating ballance's) unsustainability level(basically ranking all 10 clubs on the basis of their unsustainable financial behaviour with the clubs having their expense significantly outmatching their revenue ranked at the top , while the clubs with their revenue being significantly more than their expense being ranked at the bottom):- 
   - We create the first CTE named total_club_revenue where we retrieve the club_id and their corresponding total_revenue(SUM of all amount_euros_millions from all revenue streams) from the club_revenue table, grouping by club_id so that we get the aggregated total revenue for each individual club.
   - We create the second CTE named total_club_expenditure where we retrieve the club_id and their corresponding total_expenditure(SUM of all amount_euros_millions from all expenditure streams) from the club_expenditure table, grouping by club_id so that we get the aggregated total expenditure for each individual club.
   - We create a third CTE named club_balance where we INNER JOIN both revenue_info and expenditure_info CTEs together with the club_dim table on the common column of club_id, so that we can retrieve each club's id, name, total_revenue_millions, total_expenditure_millions from all three sources and calculate a new entity called balance_millions by subtracting total_expenditure from total_revenue for each club.
   - In the main query we retrieve all the information from club_balance CTE and create a new ranking entity using DENSE_RANK() window function which ranks all clubs in ascending order of their balance_millions, so that clubs with negative balance(deficit/overspending) appear at the top with rank 1, and clubs with positive balance(surplus) appear at the bottom with higher ranks.
   - Finally we ORDER BY the ranking in ascending order so that the clubs ranked as most unsustainable (highest overspending relative to earnings with lowest/most negative balance) appear at the top, while clubs ranked as most sustainable (lowest overspending or highest surplus) appear at the bottom, giving us a clear picture of financial sustainability across all clubs.
*/
WITH total_club_revenue AS ( -- In this CTE we will retrieve the club info(club_id) and their corresponding total revenue i.e the SUM of amount_euros_millions of all the revenue_streams from the club_revenue table.
SELECT -- retrieves the club info(of club_id, club_name) and their corresponding total revenue in euros (in millions) from the club revenue table.
    club_id,
    SUM(amount_euros_millions) AS total_revenue_millions -- will retrieve the SUM of all the amount_euros_millions of revenue corresponding to that club_id from the club_revenue table.
FROM -- this is the club_revenue table which contains the revenue data of each club.
    club_revenue
GROUP BY -- this groups the result on the basis of each groups present in the club_id column.
    club_id
),
total_club_expenditure AS ( -- In this CTE we will retrieve the club info(club_id) and their corresponding total expenditure i.e the SUM of amount_euros_millions of all the expenditure_streams which the club incurred in that season.
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_expenditure_millions -- will retrieve the SUM of all the amount_euros_millions of expenditure corresponding to that club_id from the club_expenditure table.
FROM -- this is the club_expenditure table which contains the expenditure data of each club.
    club_expenditure
GROUP BY -- this groups the result on the basis of each groups present in the club_id column.
    club_id
),
club_balance AS ( -- In this CTE we will retrieve all the columns and entities from the previous two CTEs of total_club_revenue & total_club_expenditure along with the club's infor such as club_id and club_name from club_dim table(dosent matter if its LEFT table, since only those clubs will be mentioned in result which will be common in all the three tables cuz of inner join, that being all the clubs in the database since all clubs in club_dim have been covered in tcr taable and tce table) while inner joining all these tables together to find the club's corresponding id, name, total revenue & total expenditure corresponding to each other.
SELECT
    cd.club_id,
    cd.club_name,
    total_revenue_millions,
    total_expenditure_millions,
    (total_revenue_millions - total_expenditure_millions) AS balance_millions -- This entity will calculate the balance left behind after subtracting the total expenses of the club from its total revenue...
FROM -- We retrieved the information originally from the club_dim table, though it dosent carry the info of total_revenue and total_expenditure, but it carries the club_id and club_name which is mentioned in the very top linked to it, and the rest of the entities will be retrieved from the created CTEs above(tcr & tce) which will be mentioned in the INNER JOIN clauses joined to the club_dim table on club_id column and hence will carry the references to the other entities called in the select clause too, so it was optional to put it in the FROM statement, but we put it to make the query more readable and understandable, if we choose not to put that and put any CTE which we created first , we will have to tailor our JOIN clause tables mentioned accordingly. Also it dosent matter that the club_dim table is the LEFT table in heresince the join menthod is INNER JOIN the clubs common in all three inner joined tables will only be displayed i.e all clubs in the database, since al the clubs explained/detailed in the club_dim table are also called out in the club_revenue and club_expenditure tables which were being called out respectively in total_revenue_club and total_expenditure_club CTEs.
    club_dim AS cd
JOIN -- Inner joining the tables of club_dim and total_club_revenue, to display all the clubs which are common in both the tables...(even if we had used the LEFT JOIN or RIGHT JOIN the result would have been the same , since both the tables include exatly all the same clubs mentioned in both entirely, hence in case of LEFT JOIN if all the clubs of left table[cr] was mentioned in the club_id common column, then its corresponing value from right table will also exist which will be non null since both the tables consist all the clubs mentioned in either of them, no more no less, hence same will be the case in RIGHT JOIN , if all the clubs from the right table[cd] will be displayed , their corresponding info from cr table will also be existing which is non null similarly)
    total_club_revenue AS tcr ON cd.club_id = tcr.club_id
JOIN -- Inner joining the tables of club_dim & total_club_expenditure, to display the all the common clubs in the three tables of cd, tcr & tce(which is all the clubs in this database since each club being detailed in club_dim, has their revenue and expenditure information shown in the tcr & tce tables).
    total_club_expenditure AS tce ON cd.club_id = tce.club_id
)
SELECT -- In the main query we will retrieve all the columns and entities from the previs CTE of club_balance(which inturn retrieves all its info from the tcr & tce CTEs) and finally rank each of the rows using DENSE_RANK() on the basis of the ascending order of their balance_millions.
    club_id,
    club_name,
    total_revenue_millions,
    total_expenditure_millions,
    balance_millions,
    DENSE_RANK() OVER(ORDER BY balance_millions) AS rnk_clubs_unstability -- This will rank all the rows in the result set i.e the clubs with their total revenue and expenditure corresponding to them on the basis of their balance_millions, the DENSE_RANK() function will allow us to rank each of the rows in the result set in such a way that if two or more clubs have the same ballance_millions then they be ranked the same and the next row/club with the next ballance_millions in ornder will be recieving the next rank in order without any gap in the rankings... unlike in the case as it would in the case of RANK() where the same balance clubs will get the same rank but next row in order of the balance_millions will recieve the rank after gap(where this gap will be of the possible ranks the same balance clubs could have got if it wasin ROW_NUMBER() type of distribution/ranking).
FROM
    club_balance AS cb
ORDER BY -- Finally ordering in ascending order of the rank(i.e the clubs with the least balance shows up at the top and the clubs with the most balance shows up at the bottom)
    rnk_clubs_unstability;