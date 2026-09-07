/* Problem 13 : What is the UCL competition stage-wise Average broadcast revenue per UCL round progressed, showing which UCL stage-reached clubs make the most revenue money through broadcast :-
   - We are approaching this question by retrieving the information in an easy way that too from two tables of Club_dim(from where we retrieve the info of which club belongs to which ucl_stage_2024_25) & club_revenue(for amount_euros_millions for the revenue_type of 'Broadcast & Reward Prices'), and JOINING the two tables on the common column of club_id to retrieve the corresponding info of ucl_stage_2024_25 and amount_euros_millions of broadcasting revenue of each club.
   - We will retrieve the ucl_stage_2024_25 and find the average of amount_euros_millions from club_revenue table using AVG function, and round the result to 2 decimal places using ROUND function.
   - We will filter out the revenue_type to only include 'Broadcast & Reward Prices' of whoose amount_euros_million's average will be taken in SELECT clause, using WHERE clause.
   - We will GROUP BY the result on the basis of ucl_stage_2024_25, so that corrsponding to each of the categories in ucl_stage_2024_25 column we can find the aggregated result of AVG(amount_euros_millions) of revenue(revenue_type of 'broadcasting & reward prices') of all the clubs which belonging to that particular ucl_stage_2024_25.
   - Finally we will ORDER BY the result in descending order of avg_broadcast_revenue_ucl_stage, so that the UCL stages having clubs whoose combined broadcast_revenue_club's average value is the highest will be displayed on the top of the result set, and the UCL stages having clubs with lower average broadcast revenue will be displayed in the bottom.
*/
SELECT -- We won't be creating any CTEs in this case since we are retrieving the information in an easy way that too from two tables of Club_dim(from where we retrieve the info of which club belongs to which ucl_stage_2024_25) & club_revenue(for amount_euros_millions for the revenue_type of 'Broadcast & Reward Prices'), and JOINING the two tables on the common column of club_id to retrieve the corresponding info of ucl_stage_2024_25 and amount_euros_millions of broadcasting revenue of each club.
    ucl_stage_2024_25,
    ROUND(AVG(amount_euros_millions), 2) AS avg_broadcast_revenue_ucl_stage -- This will find the avgerage broadcast revenue(since we mentioned revenue_type = 'Broadcast & Reward Prices' in WHERE clause) of all the clubs which belong to that particular ucl_stage_2024_25. ROUND([formula], 2) is used to round the result of the AVG function to 2 decimal places.
FROM -- Since our Pivoting entity of ucl_stage_2024_25 of each of the club_ids is mentioned in club_dim we mention the cd table in the FROM statement. We could have gone the other way by mentioning the club_revenue table in the FROM statement and then JOINING the club_dim table to it, but we chose to go this way for the sake of simplicity and clarity.
    club_dim AS cd
JOIN -- Since we also retrieve the value of amount_euros_millions from club_revenue table for the revenue_type of "Broadcast revenue", We are using INNER JOIN to join the club_dim table with the club_revenue table on the common column of club_id, hence only the club_ids which are common in both the tables will be displayed in the result-set, which being all of them since all the club_ids mentioned in club_dim table are also present in club_revenue table.
    club_revenue AS cr ON cd.club_id = cr.club_id
WHERE -- This is where we filter out the revenue_type to only include 'Broadcast & Reward Prices' of whoose amount_euros_million's average will be taken in SELECT clause, using WHERE clause.
    revenue_type = 'Broadcast & Reward Prices'
GROUP BY -- GROUPING BY on the basis of ucl_stage_2024_25, so that we can calculate the average_broadcast_revenue_ucl_stage of all the the UCL stages based on their club's total broadcast revenue and finding their avgerage.
    ucl_stage_2024_25
ORDER BY -- Then finally ORDER BY descendiing order(using DESC keyword) of avg_broadcast_revenue_ucl_stage, so that the UCL stages having clubs whoose combined broadcast_revenue_club's average value is the highest will be displayed on the top of the result set, and the UCL stages having clubs with lower average broadcast revenue will be displayed in the bottom.
    avg_broadcast_revenue_ucl_stage DESC;    

/* Problem 14 : What is each club's broadcast revenue as a percentage of total revenue and flag clubs with high dependency risk (above a defined threshold, e.g 35%) :- 
   - We are approaching this question by making 2 CTEs even though we are retrieving both the values from the same table of club_revenue but retrieving 2 different entities of total_revenue_club and broadcast_revenue(of club), since if we try to retrieve both in the same query... we will eventually run into deadlock/error position where we wont be able to retrieve both at once since one requires either grouping/window function usage(of total_revenue), but even if we use window function to declare total_revenue_club, we will struggle to get its proper result since we gonna put the filter of revenue_type = 'Broadcasting & Reward Prices'(to retrieve broadcast_revenue).
   - We will create the 1st CTE named revenue_info where we will retrieve the club_id wise total_revenue_club(total revenue of the club) GROUPED on the basis of club_id, so that the total_revenue(SUM(cr.amount_euros_millions)) is calculated for each categories in the column of club_id from the cr table.
   - We will create the 2nd CTE named broadcast_revenue_info where we will retrieve the info of broadcast_revenue for ach club, for which we will retrieve the club_id and its corresponding amount(amount_euros_millions, without the SUM because we are just finding out the already mentioned value of a revenue_type inside of the table and not an aggregated result of any kind) and most importantly put the filter in WHERE cause of revenue_type = 'Broadcast & Reward Prices', so that we get broadcast_revenue(amount_euros_millions corresponding to the revenue_type of 'Broadcast & Reward Prices') corresponding to each club_id, this time we don't need to mention GROUPING function since there is no aggregation happening rather its showing the actual amount of a particular revenue_type corresponding to the club_id(shown in cr table) which has been filtered out to show only the broadcasting revenue.
   - In the 3rd CTE of broadcasting_ratio we will be focusing on displaying the result as the question has asked, i.e we will display the club_id, club_name(from club_dim table) and its corresponding total_revenue_club(from revenue_info CTE) and broadcast_revenue(from broadcast_revenue_info CTE) and find their corresponding broadcasting_dependency_percentage, which is basically tells what portion/percentage does the broadcasting revenue of the club makes up of the entire revenue of the club. To retrieve all these values from different tables/CTEs we need to ensure that all these tables & CTEs(cd, ri & bri) are INNER JOINED together on the common column of club_id... so that only those clubs which are common in the club_id column of all the 3 tables will be displayed in the result-set which being all of them since all the tables detailed in club_dim are included in cr table aswell(which is used to retrieve info in both the CTEs of ri and bri).
   - In the Main query we will retrieve all the info retrieved in the 3rd CTE of broadcasting_ratio, and also declare an entity called broadcasting_revenue_dependency_ratio_status using CASE statements, where we will assign the clubs with broadcasting_dependency_percentage > 40% as 'High Dependency', the ones with broadcasting_dependency_percentage > 35% as 'Moderate dependency' and for the rest of them we will assign them as 'Low Dependency'.
   - Finally we will be arranging the result-set in descending order of broadcasting_dependency_percentage, so that the clubs which are the most dependent of broadcast_revenue will be shown first.
*/
WITH revenue_info AS ( -- This is our first CTE where we will retrieve the total revenue of all the clubs(total_revenue_club), for which we will use SUM of cr.amount_euros_millions GROUPED on the basis of club_id, which will be retrieved from club_revenue table(which displays the revenue in amounts for each revenue streams of each of the clubs), for which we will GROUP the result on the basis of club-id, so we get the corresponding agregated result on the basis of each club_id... i.e each amount_euros_millions SUMMED should be of that club_id(for all its individual revenue stream's revenue amount summed) shown in result set.
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_revenue_club
FROM
    club_revenue
GROUP BY -- GROUPING BY club_id so that all the aggregation be done on the basis of the categories in the club_id column.
    club_id
),
broadcast_revenue_info AS ( -- This is our 2nd CTE which will retrieve the information of broadcast_revenue of each club(club_id), where we will call out the club_id and their corresponding cr.amount_euros_millions from club_revenue table... WHERE revenue_type is 'Broadcasting & Reward Prices'.
SELECT
    club_id,
    amount_euros_millions AS broadcast_revenue
FROM
    club_revenue
WHERE -- Filtering out the revenue_type of 'Broadcast & Reward Prices' so that only the amount_euros_millions(revenue amount) of revenue recieved from broadcasting and reward prices only be counted.
    revenue_type = 'Broadcast & Reward Prices'
),
broadcasting_ratio AS ( -- This is our 3rd CTE where we will retrieve the broadcasting_dependency_ratio of what the broadcasting_revenue will actually make up of its club's total_revenue_club. For this we will retrieve the values from the junction(INNER JOIN) of three tables being club_dim(from where we will retrieve the info of what is the club_id's crresponding club_name is), broadcasting_revenue_info(from where we will retrieve the broadcasting_revenue info of each of the club_id), revenue_info(from where we will retrieve the total_revenue_club of all the club_id). Since we INNER JOIN all these tables on the common column of club_id... so only those club_id values which are common in all the tables will be shown in the result-set irrespective of what the left table is and all... and hence only those club_ids which have a corrresponding club_id value in all the tables will be shown in the result-set.
SELECT
    cd.club_id, -- Here we need to mention the table reference since club_id is an ambigous column and needs to be mentioned for a table reference... but that doesent mean that since the table reference os of cd so it will retrieve only those club_ids which are there in cd table, rather since its INNER JOIN it will include all those club_ids which are common in all the tables INNER JOINED(i.e cd, ri & bri).
    club_name,
    broadcast_revenue,
    total_revenue_club,
    ROUND(((broadcast_revenue / total_revenue_club) * 100), 2) AS broadcasting_dependency_percentage -- Finding the percentage value of what the broadcast_revenue makes up of the club's total_revenue_club, and rounding the result to display it in 2 decimal places.
FROM -- Since one of the pivotal entity of club_name is being retrieved from club_dim, we mentioned that in FROM clause, and INNER JOINED all the other tables from where we retrieving info from, we could go the other way but we went this way.
    club_dim AS cd
JOIN -- INNER JOINING the revenue_info CTE(from where we retrieved the total_revenue of all club/club_ids) with club_dim(from where we retrieve the info of club_name of all clubs/club_ids), so that it only show the common club_ids common in both the tables in the result-set.
    revenue_info AS ri ON cd.club_id = ri.club_id
JOIN -- INNER JOINING the broadcast_revenue_info CTE(from where we retrieved the info of broadcast_revenue of each club/club_id) with the already mentioned junction of club_dim(from where we retrieve club_name info of clubs) and revenue_info(from where we retrieve total_revenue_club info of clubs).
    broadcast_revenue_info AS bri ON cd.club_id = bri.club_id
)
SELECT -- This is the main query where we will retrieve all the info retrieved in the previous 3rd CTE of broadcasting_ratio and will also declare another entity called broadcasting_revenue_dependency_ratio_status where we will use CASE statements to assign different statuses to each club based on what portion their broadcasting revenue makes up of the total revenue.
    club_id,
    club_name,
    broadcast_revenue,
    total_revenue_club,
    broadcasting_dependency_percentage,
    CASE
        WHEN broadcasting_dependency_percentage > 40 THEN 'High Dependecy'
        WHEN broadcasting_dependency_percentage > 35 THEN 'Moderate Dependency'
        ELSE 'Low Dependency'
    END AS broadcasting_revenue_dependency_ratio_status -- Using CASE statements to recognise the club's broadcasting_dependency_percentage and assign it a status of 'High Dependency' if broadcasting_dependency_percentage > 40%, 'Moderate dependency' if broadcasting_dependency_percentage > 35% or else for any broadcasting_dependency_percentage below 35% its gonna be 'Low Dependency'.
FROM -- Since we already did retrieved most of the entities of club_name, broadcast_revenue and total_revenue_club from the first 2 CTEs after INNER JOINING them with inside the 3rd CTE of broadcasting_ratio... we just need to mention as it is inside the main query's from statement since only entity left out to declare was broadcasting_revenue_dependency_ratio_status, which would be done on the basis of the value of broadcasting_dependency_percentage all of which has been already called out in the 3rd CTE of broadcasting_ratio.
    broadcasting_ratio AS br
ORDER BY -- Finally we will arrange the result in descending order(using DESC keyword) of their broadcasting_dependency_percentage, so that the clubs which are the most dependent on the broadcast revenue for their total revenue compared to the other clubs(top 10 performing UCL) be mentioned first in the list, and the least broadcast revenue dependent clubs for their total revenue be mentioned in the last.
    broadcasting_dependency_percentage DESC;

/* Problem 15 : Build a single master scorecard combining net operationg position, wage ratio, amortisation burden, interest burden, and broadcast dependency for every club, with an overall health label :-
   - There are multiple ways approaching this question with one of them being declaring the revenue_info CTE & expenditure_info CTE and use it in further more question related CTEs, but here we decide to do this in a systematic format where each CTEs solve one side of the problem completeley let it be operating position, wage ratio etc... all of each will be solved in individual CTEs which further carry inside of it further CTEs/subqueries focusing on solving the problem, though its a longer approach since it requires declaring CTEs like revenue_info or expenditure_info multiple times, but this helps in solving the problem systematically in an organised format.
   - In the 1st CTE we name it as operating_position_info where in in the from statement we will create a sub-query with 2 CTEs as revenue_info(retrieving the total_revenue of the clubs) & expenditure_info(retrieving the total_expenditure of the clubs) and in its main query wi will join both the CTEs using INNER JOIN and find out the result of net_operating_position which will be (total_revenue_club - total_expenditure_club), and we will be calling the same net_operating_position in the SELECT clause of the CTE operating_position_info alonglisde its corresponding club_id.
   - We will name the 2nd CTE as wage_ratio_info which will contain nested CTEs of revenue_info(retrieving the total_revenue of the clubs) & wage_info(retrieving the wage amount of the clubs), then in their main query we will retrieve the club_id-wise wage amount, total_revenue and find the wage_ratio(what percentage the wage makes up of total revenue of the club, to see how much revenue the wages sucks up for the club) for which we will need to INNER JOIN the ri & wi CTEs together on the common column of club_id so that we can retrieve the corresponding wage and total revenue of the club from their respective CTEs with an established junction/relation.
   - We will create our 3rd CTE of amortization_burden_info where we will find how much amortization/depriciation burdern is the club under w.r.t its total revenue, to see how fast is its tangible & intangible assets loosing their value compared to their revenue. For this we will go again with the nested CTE approach where insde the amortization_burden_info CTE we will create 2 new nested CTEs revenue_info(retrieving the total_revenue of the clubs) & amortization_info(retrieving the amoortization & depriciation expense amount corresponding to each club), and in the main query we will retrieve the club-wise amortization_depriciation_club, total_revenue and also the amortization_depriciation_ratio(the percentage the amortization and depriciation amount makes up of the total revenue of that club, to get an idea of how fast the club's assets is loosing its value w.r.t its revenue to know if the club is making any high risk spendings) for which we will need to INNER JOIN ri and abi on the common column of club_id.
   - We will then create the 4th CTE called interest_burden_info where we will find how much part does the interest cost to be paid by the club makes up of its total_revenue, for this we will create the two nested CTEs of revenue_info(retrieving the total_revenue of the clubs) & interest_burden_info(retrieves the interest cost of each club) and in its main query retrieve the club_id-wise interest_cost_club, total_revenue_club & their interest_cost_ratio(the percentage that the interest costs make up of the total_revenue of the club) then INNER JOIN both these 2 CTEs together on the common column of club_id so that we can retrieve the corresponding values of interest costs and total revenue of clubs from both CTEs.
   - We will create the 5th CTE as broadcasting_dependency_info where we will find out how much portion does the broadcasting_revenue makes up of the total_revenue of the club, for this we will create 2 nested CTEs of revenue_info(retrieving the total_revenue of the clubs) & broadcasting_info(retrieving the broadcast_revenue of each clubs), and in its main query we called out the club_id's their corresponding broadcast_revenue_club and total_revenue from both the CTEs and also find their corresponding broadcasting_revenue_ratio(the % that the broadcast_revenue of the club makes up of the total_revenue of the club), to retrieve which we will have to INNER JOIN the ri and bri CTE from where we retrieve the total_revenue and broadcast_revenue information respectiveley.
   - Now in the main query of the entire major query(containg the CTEs of noi, wri, abi, ibi & bdi) we will call out the club_id(which is common in all the CTEs) and their corresponding club_name(form club_dim table), net_operating_position(from noi CTE), wage_ratio(from wri CTE), amortization_depriciation_ratio(from abi CTE), interest_cost_ratio(from the ibi CTE) & broadcast_revenue_ratio(from bdi CTE)... to retrieve all this info corresponding to each of the club_id we need to ensure that we INNER JOIN all the tables & CTEs together on the common column of club_id(since they all have it in common) to retrieve all the corresponding info of all these clubs as called in the SELECT clause of the main query... since its INNER JOIN we used, it will retrieve all the clubs(club_ids) which we will be common in all the tables & CTEs.
   - We will also declare a new entity called overall_health which will ensure if the club is in overall good health or no based on their metrics into categories of 'Distressed'(for clubs having negetive operating position and having either of the following : more than 70% wage ratio/ more than 20% adr/ more than 4% icr/ more than 40% brr), 'Watch-list'(for clubs having negetive operating position and having either of the following : more than 60% wage ratio/ more than 15% adr/ more than 2% icr/ more than 35% brr) or else 'Healthy'(for anything other than than the previous mentioned conditions such as positive net_operating_position etc...).
   - Finally we will order the result-set of this query in descending order of net_operating_position, so that the clubs making the most profit out of net_operating_position(total_revenue - total_expenditure) be mentioned first, and the clubs making the most loss out of net_operating_position in the last.
*/
WITH operating_position_info AS ( -- This is our First CTE for which we went with the approach of nested-sub-queries(sub-queries nested into CTE of operation_position_result[these sub-queries further had CTE's declared inside them]), where we retrieved the info about clubs(club_id), their total_revenue_club(from club_revenue table, we retrieve this in a nested sub-query's nested CTE named revenue_info), their total_expenditure_club(from club_expenditure table, we retrieve this in a nested sub-query's nested CTE named expenditure_info), and their corresponding net_operating_position(total_revenue_club - total_expenditure_club, for which we need to INNER JOIN the revenue_info CTE with expenditure_info CTE, so that the club_id's total revenue information[from revenue_info CTE] and its corresponding total_expenditure info[from expenditure_info CTE] be known to query).
SELECT -- The nested Sub-query's main query which returns the main query results of nested CTEs inside the nested subquery returns(i.e clubs and their corresponding net_operating_position).
    club_id,
    net_operating_position
FROM
    ( -- This is the nested subquery which has further more nested CTEs of revenue_info and expenditure_info, which are used to calculate the net_operating_position of each club.
    WITH revenue_info AS ( -- This is the first nested CTE inside the nested subquery, where we retrieve the total_revenue_club of each club(club_id) from club_revenue table, by SUM of cr.amount_euros_millions GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS total_revenue_club
    FROM
        club_revenue
    GROUP BY
        club_id
    ),
    expenditure_info AS ( -- This is the second nested CTE inside the nested subquery, where we retrieve the total_expenditure_club of each club(club_id) from club_expenditure table, by SUM of ce.amount_euros_millions GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS total_expenditure_club
    FROM
        club_expenditure
    GROUP BY
        club_id
    )
    SELECT -- This is the main query of the nested subquery, where we find the net_operating_position(total_revenue_club - total_expenditure_club) of the clubs, for which INNER JOIN the revenue_info CTE(which gives us the total_revenue_club info of each club_id) with expenditure_info CTE(which gives us the total_expenditure_club info of each club_id) on the common column of club_id, Since its and INNER JOIN, only the club_id's which are common in both CTEs will be retrieved, which will be all since all the clubs explained in club_dim table will also be mentioned in the club_revenue(also used in revenue_info CTE) & the club_expenditure(also used in expenditure_info CTE) table
        ri.club_id, -- We had to mention the table reference here because both the tables/CTEs from where we are retrieveing values for our main query have the same column name of club_id which is ambigous, hence we have to mention the table reference of the column name to avoid ambiguity. We chose ri(revenue_info CTE) as the reference table for club_id since one of the pivotal entity of total_revenue_club which we retrieve is from revenue_info CTE, so we chose to go with that as the reference table for club_id. We could go the other way too by choosing expenditure_info CTE as the reference table for club_id since it provides us the other pivotal entity of total_expenditure_club, but we had to choose one, we chose this way.
        ROUND((total_revenue_club - total_expenditure_club), 2) AS net_operating_position -- This is where we calculate the net_operating_position of each club, by subtracting the total_expenditure_club from total_revenue_club, and then rounding it off to 2 decimal places using ROUND function.
    FROM -- Since one of the pivotal entity retrieved in the main query was total_revenue_club which we retrieve from revenue_info CTE, we mentioned it in the FROM clause, we could go the other way too, but we choose to go this way for the sake of simplicity.
        revenue_info AS ri
    JOIN -- We INNER JOIN the expenditure_info CTE with revenue_info CTE on the common column of club_id, so that we can get the total_revenue_club(from revenue_info CTE) and total_expenditure_club(from expenditure_info CTE) of each club_id corresponding to it, so that we can calculate the net_operating_position of each club_id.
        expenditure_info AS ei ON ri.club_id = ei.club_id
    )
),
wage_ratio_info AS ( -- This is our second CTE for which we went with the approach of nested CTEs unlike the first CTE's approach of nested sub-queries, where we retrieved the info about clubs(club_id), their total_revenue_club(from club_revenue table which we retrieve from a nested CTE named revenue_info), their wage_amount_club(from club_expenditure table which we retrieve from a nested CTE named wage_info), and their corresponding wage_ratio(wage_amount_club / total_revenue_club, for which we need to INNER JOIN the revenue_info CTE with wage_info CTE, so that the club_id's total revenue information[from revenue_info CTE] and its corresponding wage_amount info[from wage_info CTE] be known to query).
    WITH revenue_info AS ( -- This is our first nested CTE inside of our wage_ratio_info CTE(2nd main CTE), where we retrieve the total_revenue_club of each club(club_id) from club_revenue table, by SUM of cr.amount_euros_millions GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS total_revenue_club
    FROM
        club_revenue
    GROUP BY
        club_id
    ),
    wage_info AS ( -- This is our second nested CTE inside of our wage_ratio_info CTE(2nd main CTE), where we retrieve the wage_amount_club(total amount spent on wages) of each club(club_id) from club_expenditure table, by SUM of ce.amount_euros_millions WHERE expenditure_type = 'Wages & Salaries' GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS wage_amount_club
    FROM
        club_expenditure
    WHERE
        expenditure_type = 'Wages & Salaries'
    GROUP BY
        club_id
    )
    SELECT -- This is the Main query of our wage_ratio_info CTE, where we find the wage_ratio(wage_amount_club / total_revenue_club) of the clubs, for which we INNER JOIN the revenue_info CTE(which gives us the total_revenue_club info of each club_id) with wage_info CTE(which gives us the wage_amount_club info of each club_id) on the common column of club_id, Since its and INNER JOIN, only the club_id's which are common in both CTEs will be retrieved, which will be all since all the clubs explained in club_dim table will also be mentioned in the club_revenue(also used in revenue_info CTE) & the club_expenditure(also used in wage_info CTE) table.
        ri.club_id, -- We had to mention the table reference here because both the tables/CTEs from where we are retrieveing values for our main query have the same column name of club_id which is ambigous, hence we have to mention the table reference of the column name to avoid ambiguity. We chose ri(revenue_info CTE) as the reference table for club_id since one of the pivotal entity of total_revenue_club which we retrieve is from revenue_info CTE, so we chose to go with that as the reference table for club_id. We could go the other way too by choosing wage_info CTE as the reference table for club_id since it provides us the other pivotal entity of wage_amount_club, but we had to choose one, we chose this way.
        ROUND(((wage_amount_club / total_revenue_club) * 100), 2) AS wage_ratio -- This is where we calculate the wage_ratio of each club, by dividing the wage_amount_club by total_revenue_club, and then multiplying it by 100 to get the percentage value of how much the wage portion makes up of the club's entire revenue, and then rounding it off to 2 decimal places using ROUND function.
    FROM -- Since one of the pivotal entity retrieved in the main query was total_revenue_club which we retrieve from revenue_info CTE, we mentioned it in the FROM clause, we could go the other way too, but we choose to go this way for the sake of simplicity.
        revenue_info AS ri
    JOIN -- We INNER JOIN the wage_info CTE with revenue_info CTE on the common column of club_id, so that we can get the total_revenue_club(from revenue_info CTE) and wage_amount_club(from wage_info CTE) of each club_id corresponding to it, so that we can calculate the wage_ratio of each club_id.
        wage_info AS wi ON ri.club_id = wi.club_id
),
amortization_burden_info AS ( -- This is our third CTE for which we again went with the approach of nested CTEs , where we retrieved the info about clubs(club_id), their total_revenue_club(from club_revenue table which we retrieve from a nested CTE named revenue_info), their amortization_depriciation_amount_club(from club_expenditure table which we retrieve from a nested CTE named amortization_info), and their corresponding amortization_depriciation_ratio(amortization_depriciation_amount_club / total_revenue_club, for which we need to INNER JOIN the revenue_info CTE with amortization_info CTE, so that the club_id's total revenue information[from revenue_info CTE] and its corresponding amortization_depriciation_amount info[from amortization_info CTE] be known to query).
    WITH revenue_info AS ( -- This is our first nested CTE inside of our amortization_burden_info CTE(3rd main CTE), where we retrieve the total_revenue_club of each club(club_id) from club_revenue table, by SUM of cr.amount_euros_millions GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS total_revenue_club
    FROM
        club_revenue
    GROUP BY
        club_id
    ),
    amortization_info AS ( -- This is our second nested CTE inside of our amortization_burden_info CTE(3rd main CTE), where we retrieve the amortization_depriciation_amount_club(total amount spent on amortization & depriciation) of each club(club_id) from club_expenditure table, by SUM of ce.amount_euros_millions WHERE expenditure_type = 'Amortisation & Depreciation' GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS amortization_depriciation_club
    FROM
        club_expenditure
    WHERE
        expenditure_type = 'Amortisation & Depreciation'
    GROUP BY
        club_id
    )
    SELECT -- This is the Main query of our amortization_burden_info CTE, where we find the amortization_depriciation_ratio(amortization_depriciation_amount_club / total_revenue_club) of the clubs, for which we INNER JOIN the revenue_info CTE(which gives us the value of total_revenue_club info of each club_id) with amortization_info CTE(which gives us the value of amortization_depriciation_amount_club info of each club_id) on the common column of club_id, Since its an INNER JOIN only the club_id's which are common in both CTEs will be retrieved, which will be all since all the clubs explained in club_dim table will also be mentioned in the club_revenue(also used in revenue_info CTE) & the club_expenditure(also used in amortization_info CTE) table.
        ri.club_id,
        ROUND(((amortization_depriciation_club / total_revenue_club) * 100), 2) AS amortization_depriciation_ratio -- This is where we calculate the amortization_depriciation_ratio of each club, by dividing the amortization_depriciation_amount_club by total_revenue_club, and then multiplying it by 100 to get the percentage value of how much the amortization & depriciation portion makes up of the club's entire revenue, and then rounding it off to 2 decimal places using ROUND function.
    FROM
        revenue_info AS ri
    JOIN -- We INNER JOIN the amortization_info CTE with revenue_info CTE on the common column of club_id, so that we can get the total_revenue_club(from revenue_info CTE) and amortization_depriciation_club(from amortization_info CTE) of each club_id corresponding to it, so that we can calculate the amortization_depriciation_ratio of each club_id.
        amortization_info AS ai ON ri.club_id = ai.club_id
),
interest_burden_info AS ( -- This is our fourth CTE for which we again went with the approach of nested CTEs , where we retrieved the info about clubs(club_id), their total_revenue_club(from club_revenue table which we retrieve from a nested CTE named revenue_info), their interest_cost_amount_club(from club_expenditure table which we retrieve from a nested CTE named interest_info), and their corresponding interest_cost_ratio(interest_cost_amount_club / total_revenue_club, for which we need to INNER JOIN the revenue_info CTE with interest_info CTE, so that the club_id's total_revenue_club information[from revenue_info CTE] and its corresponding interest_cost_amount info[from interest_info CTE] be known to query).
    WITH revenue_info AS (-- This is our first nested CTE inside of our interest_burden CTE(4th main CTE), where we retrieve the total_revenue_club of each club(club_id) from club_revenue table, by SUM of cr.amount_euros_millions GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS total_revenue_club
    FROM
        club_revenue
    GROUP BY
        club_id
    ),
    interest_info AS ( -- This is our second nested CTE inside of our interest_burden_info CTE(4th main CTE), where we retrieve the interest_cost_amount_club(total amount spent on interest & debt servicing) of each club(club_id) from club_expenditure table, by SUM of ce.amount_euros_millions WHERE expenditure_type = 'Net Interest & Debt Servicing' GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS interest_cost_club
    FROM
        club_expenditure
    WHERE
        expenditure_type = 'Net Interest & Debt Servicing'
    GROUP BY
        club_id
    )
    SELECT -- This is the Main query of our interest_burden_info CTE, where we find the interest_cost_ratio(interest_cost_amount_club / total_revenue_club) of the clubs, for which we INNER JOIN the revenue_info CTE(which gives us the value of total_revenue_club info of each club_id) with interest_info CTE(which gives us the value of interest_cost_amount_club info of each club_id) on the common column of club_id, Since its an INNER JOIN only the club_id's which are common in both CTEs will be retrieved, which will be all since all the clubs explained in club_dim table will also be mentioned in the club_revenue(also used in revenue_info CTE) & the club_expenditure(also used in interest_info CTE) table.-
        ri.club_id, -- We had to mention the table reference here because both the tables/CTEs from where we are retrieveing values for our main query have the same column name of club_id which is ambigous, hence we have to mention the table reference of the column name to avoid ambiguity. We chose ri(revenue_info CTE) as the reference table for club_id since one of the pivotal entity of total_revenue_club which we retrieve is from revenue_info CTE, so we chose to go with that as the reference table for club_id. We could go the other way too by choosing interest_info CTE as the reference table for club_id since it provides us the other pivotal entity of interest_cost_club, but we had to choose one, we chose this way.
        ROUND(((interest_cost_club / total_revenue_club) * 100), 2) AS interest_cost_ratio -- This is where we calculate the amortization_depriciation_ratio of each club, by dividing the amortization_depriciation_amount_club by total_revenue_club, and then multiplying it by 100 to get the percentage value of how much the amortization & depriciation portion makes up of the club's entire revenue, and then rounding it off to 2 decimal places using ROUND function. 
    FROM -- Since most of the pivitol entity of total_revenue_club is retrieved from revenue_info CTE, we mentioned it in the FROM clause, we could go the other way too, but we choose to go this way for the sake of simplicity.
        revenue_info AS ri
    JOIN -- INNER JOINING the interest_info CTE(which contains the club-wise interest cost) with revenue_info CTE(which contains the club-wise total revenue) on the common column of club_id, so that we can get the total_revenue_club(from revenue_info CTE) and interest_cost_club(from interest_info CTE) of each club_id corresponding to it, so that we can calculate the interest_cost_ratio of each club_id.
        interest_info AS ii ON ri.club_id = ii.club_id
),
broadcasting_dependency_info AS ( -- This is our 4th CTE for which we again went with the approach of nested CTEs, where we retrieve the info about clubs(club_id), their total_revenue_club(from club_revenue table which we retrieve from a nested CTE named revenue_info), their broadcasting_revenue_club(from club_revenue table which we retrieve from a nested CTE named broadcasting_info), and their corresponding broadcasting_revenue_ratio(broadcasting_revenue_club / total_revenue_club, for which we need to INNER JOIN the revenue_info CTE with broadcasting_info CTE, so that the club_id's total_revenue_club information[from revenue_info CTE] and its corresponding broadcasting_revenue info[from broadcasting_info CTE] be known to query).
    WITH revenue_info AS ( -- This is our first nested CTE inside of our broadcasting_dependency_info CTE(5th main CTE), where we retrieve the total_revenue_club of each club(club_id) from club_revenue table, by SUM of cr.amount_euros_millions GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS total_revenue_club
    FROM
        club_revenue
    GROUP BY
        club_id
    ),
    broadcasting_info AS ( -- This is our second nested CTE inside of our broadcasting_dependency_info CTE(5th main CTE), where we retrieve the broadcasting_revenue_club(total amount earned on broadcast & reward prices) of each club(club_id) from club_revenue table, by SUM of cr.amount_euros_millions WHERE revenue_type = 'Broadcast & Reward Prices' GROUPED BY club_id.
    SELECT
        club_id,
        SUM(amount_euros_millions) AS broadcasting_revenue_club
    FROM
        club_revenue
    WHERE
        revenue_type = 'Broadcast & Reward Prices'
    GROUP BY
        club_id
    )
    SELECT -- This is the main query of our broadcasting_dependency_info CTE, where we find the broadcasting_revenue_ratio(broadcasting_revenue_club / total_revenue_club) multiplied with 100 to find its percentage to know what percentage or portion the broadcasting and reward prices make up of the total revenue of their clubs, for which we INNER JOIN the revenue_info CTE(which gives us the value of total_revenue_club info of each club_id) with broadcasting_info CTE(which gives us the value of broadcasting_revenue_club info of each club_id) on the common column of club_id, Since its an INNER JOIN only the club_id's which are common in both CTEs will be retrieved, which will be all since all the clubs explained in club_dim table will also be mentioned in the club_revenue table(also used in revenue_info & broadcasting_info CTEs).
        ri.club_id, -- We had to mention the table reference here because both the tables/CTEs from where we are retrieveing values for our main query have the same column name of club_id which is ambigous, hence we have to mention the table reference of the column name to avoid ambiguity. We chose ri(revenue_info CTE) as the reference table for club_id since one of the pivotal entity of total_revenue_club which we retrieve is from revenue_info CTE, so we chose to go with that as the reference table for club_id. We could go the other way too by choosing broadcasting_info CTE as the reference table for club_id since it provides us the other pivotal entity of broadcasting_revenue_club, but we had to choose one, we chose this way.
        ROUND(((broadcasting_revenue_club / total_revenue_club) * 100), 2) AS broadcasting_revenue_ratio 
    FROM -- Since most of the pivitol entity of total_revenue_club is retrieved from revenue_info CTE, we mentioned it in the FROM clause, we could go the other way too, but we choose to go this way for the sake of simplicity.
       revenue_info AS ri
    JOIN -- INNER JOINING the broadcasting_info CTE(which contains the club-wise broadcasting revenue info) with revenue_info CTE(which contains the club-wise total revenue info) on the common column of club_id, so that we can find the broadcasting_revenue_ratio((broadcasting_revenue_club / total_revenue_club) multiplied with 100 to get the percentage value of how much portion does the broadcasting revenue makes up of the total revenue of the club) of each club_id, since we used INNER JOIN  so only the club_id's which are common in both CTEs(ri & bi) will be retrieved, which will be all the clubs since all the clubs explained in club_dim table will also be mentioned in the club_revenue table(also used to retrieve info in revenue_info & broadcasting_info CTEs).
        broadcasting_info AS bi ON ri.club_id = bi.club_id
)
SELECT -- This is the main query of our entire script, where we retrieve the info about clubs(club_id, club_name[from club_dim table]), their net_operating_position(from operating_position_info CTE), their wage_ratio(from wage_ratio_info CTE), their amortization_depriciation_ratio(from amortization_burden_info CTE), their interest_cost_ratio(from interest_burden_info CTE), their broadcasting_revenue_ratio(from broadcasting_dependency_info CTE), and then we use a CASE statement to assign an overall_health label to each club based on the conditions provided in the question.
    cd.club_id,
    club_name,
    net_operating_position,
    wage_ratio,
    amortization_depriciation_ratio,
    interest_cost_ratio,
    broadcasting_revenue_ratio,
    CASE
        WHEN net_operating_position < 0 AND (wage_ratio > 70 OR amortization_depriciation_ratio > 20 OR interest_cost_ratio > 4 OR broadcasting_revenue_ratio > 40) THEN 'Distressed'
        WHEN net_operating_position < 0 AND (wage_ratio > 60 OR amortization_depriciation_ratio > 15 OR interest_cost_ratio > 1 OR broadcasting_revenue_ratio > 35) THEN 'Watch-List'
        WHEN net_operating_position < 0 AND (wage_ratio < 60 OR amortization_depriciation_ratio < 15 OR interest_cost_ratio < 2 OR broadcasting_revenue_ratio < 35) THEN 'Moderately-Healthy'
        ELSE 'Healthy'
    END AS overall_health -- This is where we use a CASE statement to assign an overall_health label to each club based on the conditions provided in the question, where we assign the label 'Distressed' if the club's net_operating_position is less than 0 and any of the other conditions(wage_ratio of the club is greater than 70% OR amortization_depriciation_ratio is more 20% OR interest_cost_ratio is more than 4% OR broadcasting_revenue_ratio is more than 40%) are met, we assign the label 'Watch-List' if the club's net_operating_position is less than 0 and any of the other conditions(wage_ratio of the club is greater than 60% OR amortization_depriciation_ratio is more 15% OR interest_cost_ratio is more than 1% OR broadcasting_revenue_ratio is more than 35%) are met, else we assign the label 'Healthy' to the club.
FROM -- Since the pivotal entity retrieved in the main query was club_id(ambigous/repeating in all the tables and CTEs declared above, so can be retrieved from any table) & club_name which we retrieve from club_dim table, we could have went the other way too, but we choose to go this way for the sake of simplicity.
    club_dim AS cd
JOIN -- We INNER JOIN the operating_position_info CTE(containing the club-wise net_operating_position info) with club_dim table(containing the club_name info) on the common column of club_id, so that we can get the club_name(from club_dim table) and net_operating_position(from operating_position_info CTE) of each club_id corresponding to it, so that we can use them in our main query.
    operating_position_info AS opi ON cd.club_id = opi.club_id
JOIN -- We INNER JOIN the wage_ratio_info CTE(containing the club-wise wage_ratio info) with club_dim table(containing the club_name info) on the common column of club_id, so that we can get the club_name(from club_dim table) and wage_ratio(from wage_ratio_info CTE) of each club_id corresponding to it, so that we can use them in our main query.
    wage_ratio_info AS wri ON cd.club_id = wri.club_id
JOIN -- We INNER JOIN the amortization_burden_info CTE(containing the club-wise amortization_depriciation_ratio info) with club_dim table(containing the club_name info) on the common column of club_id, so that we can get the club_name(from club_dim table) and amortization_depriciation_ratio(from amortization_burden_info CTE) of each club_id corresponding to it, so that we can use them in our main query.
    amortization_burden_info AS abi ON cd.club_id = abi.club_id
JOIN -- We INNER JOIN the interest_burden_info CTE(containing the club-wise interest_cost_ratio info) with club_dim table(containing the club_name info) on the common column of club_id, so that we can get the club_name(from club_dim table) and interest_cost_ratio(from interest_burden_info CTE) of each club_id corresponding to it, so that we can use them in our main query.
    interest_burden_info AS ibi ON cd.club_id = ibi.club_id
JOIN -- We INNER JOIN the broadcasting_dependency_info CTE(containing the club-wise broadcasting_revenue_ratio info) with club_dim table(containing the club_name info) on the common column of club_id, so that we can get the club_name(from club_dim table) and broadcasting_revenue_ratio(from broadcasting_dependency_info CTE) of each club_id corresponding to it, so that we can use them in our main query.
    broadcasting_dependency_info AS bdi ON cd.club_id = bdi.club_id
ORDER BY -- Finally ordering the result in descending order(using DESC keyword) of net_operating_position, so that clubs having the most net_operating_position/profit will appear at the top, while the clubs having the least net_operating_position/loss will appear at the bottom of the result set.
    net_operating_position DESC;