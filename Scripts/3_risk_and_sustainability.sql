/* Problem 7 : Calculate the wage-to-revenue ratio for each club and flag clubs exceeding UEFA's recommended 70% threshold :-
   - We create the first CTE named total_club_revenue where we retrieve the club_id and their corresponding total_revenue(SUM of all amount_euros_millions from all revenue streams) from the club_revenue table, grouping by club_id so that we get the aggregated total revenue for each individual club in the database.
   - We create the second CTE named wage_ratio_info where we INNER JOIN the club_expenditure table with club_dim table to retrieve club names, and further INNER JOIN with the total_club_revenue CTE to access total revenue information, all on the common column of club_id, and we filter the results using WHERE clause to only include expenditure_type of 'Wages & Salaries' records.
   - In the wage_ratio_info CTE we calculate a new entity called wage_ratio_percentage which determines what percentage the wage expenditure amount makes up of the club's total revenue using the formula ((amount_euros_millions / total_revenue_millions) * 100), rounded to 2 decimal places.
   - In the main query we retrieve all information from wage_ratio_info CTE and create a new entity called wage_treshhold_compliancy_status using CASE statements which flags each club as 'Compliant' if wage_ratio_percentage is less than or equal to 70%, or 'Non-Compliant' if it exceeds 70% (UEFA's recommended threshold).
   - Finally we ORDER BY the result in descending order of total_revenue_millions so that the clubs with the highest revenues appear at the top, allowing us to see how wage compliance varies across different club financial scales and identifying which high-revenue clubs are violating UEFA's wage threshold requirements.
*/
WITH total_club_revenue AS ( -- In this CTE we will retrieve the club info(club_id) and their corresponding total revenue i.e the SUM of amount_euros_millions of all the revenue_streams from the club_revenue table.
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_revenue_millions -- will retrieve the SUM of all the amount_euros_millions of revenue corresponding to that club_id from the club_revenue table.
FROM
    club_revenue AS cr
GROUP BY -- this groups the result on the basis of each groups present in the club_id column.
    club_id
),
wage_ratio_info AS ( -- This CTE will retrieve the club info(id from club_expenditure & name from club_dim) and corresponding to that it will find its expenditure figures of 'Wages & Salaries' from the club_expenditure table, also the total revenue(total_revenue_millions) of the club will be shown corresponding to each club/row(containing the id, name, wage amoount in millions) and it will find the ratio of how much this expenditure amount of 'wage & salaries' expenditure_type makes up of the entire revenue of the club combined. To retrieve this information from 3 different tables/CTEs, we will INNER JOIN these tables with each other so that only the clubs common in all three tables will be displayed... i.e in our case all the clubs since all clubs detailed in club_dim has been mentioned in club_expenditure and total_club_revenue CTE(which contains the clubs mentioned in club_revenue table).
SELECT
    cd.club_id, -- we needed to mention the table reference here since club_id is an ambigous column present in multiple tables, though since we are joining the tables together it will not mean that we are retrieving the club_ids only from club_dim table , rather its from all the tables since its an inner join which will include all the club_ids which are common in all tables Joined together, which here is all the tables.
    cd.club_name,
    expenditure_type,
    amount_euros_millions,
    total_revenue_millions,
    ROUND((amount_euros_millions / total_revenue_millions * 100), 2) AS wage_ratio_percentage -- this will find out the percentage ratio that the amount of 'wage & salaries' expenditure_type of the club makes up of the total revenue of the club(total_revenue_millions), here the ROUND([formula], 2) will ensure that the percentage resulted by the formula ([wage amount / total revenue] * 100) will be displayed in 2 decimal places.
FROM -- Retrieving the information from club_expenditure table first since this is the table which holds the majority of the information being pulled out in the SELECT clause(expenditure_type & amount_euros_millions), though its optional and can be done like this with other tables too since we are JOINING the other tables aswell, but we're writing it down this way for the sake of simplicity...
    club_expenditure AS ce
JOIN -- Here we INNER JOINED the club_dim table with the club_ependiture table on the common column of club_id in both tables. This will enable the retrival of club_name corresponding to each club_id mentioned in club_expenditure & total_club_revenue CTE.
    club_dim AS cd ON ce.club_id = cd.club_id
JOIN -- Here we INNER JOINED the previously created CTE of total_club_revenue on the common column of club_id in both tables which will enable the retrival of club's total revenue(total_revenue_millions) corresponding to its name and expenditure info.
    total_club_revenue AS tcr ON ce.club_id = tcr.club_id
WHERE -- making sure the expenditure amount retrieving is only for the expenditure_type of 'Wages_&_salaries', so corresponding to each row in the result set it carries one expenditure type which is being compared with the total revenue of the same club and its wage amount's ratio/percentage is being shown with total revenue of the club.
    expenditure_type = 'Wages & Salaries'
)
SELECT -- In the main query we will retrieve all the info called out in the previous CTE of wage_ratio and alongside that we will create a new entity which tells if the club's wage_ratio_percentage is optimized according to UEFA's wage Threshold or no, we will do this using CASE statements where we will set it in such a way that it says 'Compliant' if wage is making up below 70% of the total club's revenue OR else its 'Non-Compliant'.
    club_id,
    club_name,
    expenditure_type,
    amount_euros_millions,
    total_revenue_millions,
    wage_ratio_percentage,
    CASE -- Using CASE statements we are creating the entity of 'wage_treshhold_compliancy_status' which tells if the wage_percent_ratio of the club is compliant with the UEFA's Wage Thresholds of 70%... so the clubs having wage_percent_ratio below 70% will be considered as 'Compliant' and the ones surpassing it willbe flagged as 'Non-compliant'.
        WHEN wage_ratio_percentage <= 70 THEN 'Compliant'
        ELSE 'Non-Compliant'
    END AS wage_treshhold_compliancy_status
FROM -- We will retrieve this entire info from wage_ratio_info CTE which was previously created, which holds all the info of the club's id, name, wage figures, club's total_revenue and wage_ratio_percentage.
    wage_ratio_info AS wri
ORDER BY -- Finally we will order the result in descending order of their total_revenue_millions, making sure the clubs with the most total revenues be displayed at the top with their info of id, name, wage figures, total revenue and wage_ratio_percentage.
    total_revenue_millions DESC;

/* Problem 8 : Calculate the amortisation burden (Amortisation & Depreciation as % of revenue) for each club to assess squad investment sustainability :-
   - We create the first CTE named revenue_info where we retrieve the club_id and their corresponding total_revenue(SUM of all amount_euros_millions from all revenue streams) from the club_revenue table, grouping by club_id so that we get the aggregated total revenue for each individual club.
   - We create the second CTE named amortization_depriciation_info where we INNER JOIN the club_expenditure table with club_dim table to retrieve club names, and further INNER JOIN with the revenue_info CTE to access total revenue information, all on the common column of club_id, and we filter the results using WHERE clause to only include expenditure_type of 'Amortisation & Depreciation' records.
   - In the amortization_depriciation_info CTE we calculate a new entity called amortization_depriciation_percentage which determines what percentage the amortization & depreciation expenditure amount makes up of the club's total revenue using the formula ((amount_euros_millions / total_revenue) * 100), rounded to 2 decimal places, where higher percentages indicate greater squad investment burden.
   - In the main query we retrieve all information from amortization_depriciation_info CTE and create a new entity called resource_efficiency_status using CASE statements which assigns each club a status based on their amortization percentage: 'High-Risk Operators' if above 20%, 'Balanced Competitors' if between 15-20%, and 'Efficient Operators' if 15% or below.
   - Finally we ORDER BY the result in descending order of amortization_depriciation_percentage so that clubs with the highest amortization burden (representing aggressive squad investment and potentially unsustainable spending) appear at the top, while efficient operators with lower amortization burdens appear at the bottom, helping identify which clubs have sustainable investment strategies.
*/
WITH revenue_info AS ( -- This CTE will give out the information regarding the total revenue of the club from the club_revenue table, where for each club_id in club_revenue table, it will find the SUM of the amount(cr.amount_euros_millions) for all the revenue streams of the club, when the result is grouped on the basis of club(club_id).
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_revenue -- will find the SUM of all the revenue amount(cr.amount_euros_millions) of all revenue sources of the club combined, which will be attained after grouping it on the basis of club_id.
FROM -- we gathering the these revenue info of the club from the club_revenue table.
    club_revenue AS cr
GROUP BY -- will make sure to group the result on the basis of the categories inside of the clib_id column i.e for each club_id, their relative SUM of amount(amount_euros_millions) of all revenue_streams will be calculated.
    club_id
),
amortization_depriciation_info AS ( -- This is our 2nd CTE where we will display the expenditure information of the expenditure_type of 'Amortisation & Depreciation' with its amount sent on that expenditure compare it with the total_revenue of the club whose info we will get from the previous CTE of revenue_info(ri) after INNER JOINING it with the club_expenditure table also creating an entity named 'amortization_depriciation_percentage' which is the ratio of how much % the amortization & depriciation makes up of the total revenue of the club, and also we need to INNER JOIN the club_dim table to retrieve the club_id's club_name from there... ince we arre using INNER JOIN here , it will not matter what the left table is r what reference table is mentioned in the ambigous column(club_id), the column's(club_id's) data will be retrieved which are common in all the tables... ce, ri & cd... which is all the clubs since all the clubs in club_dim exist in both ce and ri/cd.
SELECT
    ce.club_id, -- Since club_id is an ambigous column, we need to mention the table reference alongside it for which we mentioned the club_expenditure table's reference, but that dosent mean it will pull out the club_ids only from ce table, rather since we used inner join on the basis of common column of club_id, so the club_ids which are common in all of the INNER JOINED tables of ce(club_expenditure), cd(club_dim) and ri(revenue_info) CTE will be displayed, that being all the clubs since all the clubs explained in club_dim are being used in ce and cr tables(hence also there in ri CTE)
    cd.club_name, -- Here the table reference wasnt necessary, but for simplicity of reading we added the reference what were we get the info of that being from club_dim table.
    expenditure_type,
    amount_euros_millions, -- from the club_expenditure table.
    total_revenue,
    ROUND(((amount_euros_millions / total_revenue) * 100), 2) AS amortization_depriciation_percentage -- this entity calculates what percentage the amortization & depriciation amount of the club makes up of the total_revenue of the club, the ROUND([formula], 2) ensures the percentage figues that are resulted are rounded & outputted in 2 decimal places.
FROM -- We retrieving the main expenditure information from club_expenditure, and it dosent matter if its the left table, since we used inner join all those clubs will be included here which are common in all three tables, which is all the clubs, since all the club mentioned in the club_dim is being explained in club_expenditure and revenue info CTE/club_revenue table aswel.
    club_expenditure AS ce
JOIN -- We INNER JOIN the table of club_dim with ce, so we can retrieve information like club_name for all the common clubs between the INNER JOINED tables and CTEs.
    club_dim AS cd ON ce.club_id = cd.club_id
JOIN -- We INNER JOIN the CTE of ri with ce to retrieve their revenue information of total_revenue corresponding to the common tables(which is all the clubs), alongside their names and expenditure info
    revenue_info AS ri ON ce.club_id = ri.club_id
WHERE -- Filtering out the result to show the expenditure_type and the expenditure amount of only the 'Amortisation & Depreciation' expense. and find its ratio to the total revenue of its club.
    expenditure_type = 'Amortisation & Depreciation'
)
SELECT -- In the main query we will call out all the info called out in the previous CTE of amortization_depriciation_info(adi) and along with that we will introduse a new entity called 'resource_efficiency_status' which will assign status to the clubs based on how their amortization & depriciation ratio with the total revenue of their clubs are using CASE statements, with clubs having a ratio b/w 10-15% being 'efficient operators', b/w 15-20% being 'Balanced operators' & above 20% being 'high-risk operators'.
    club_id,
    club_name,
    expenditure_type,
    amount_euros_millions AS expenditure_amount,
    total_revenue,
    amortization_depriciation_percentage,
    CASE
        WHEN amortization_depriciation_percentage > 20 THEN 'High-Risk Operators'
        WHEN amortization_depriciation_percentage > 15 THEN 'Balanced Competitors'
        ELSE 'Efficient Operators'
    END AS resource_efficiency_status -- Weare using CASE statements to assign status to clubs, where clubs having a ratio b/w 10-15% being 'efficient operators', b/w 15-20% being 'Balanced operators' & above 20% being 'high-risk operators'.
FROM -- We retrieved this information from the 2nd CTE of adi, which was already optimised using JOINS to show the club_name and the revenue info alongside the expenditure info.
    amortization_depriciation_info AS adi
ORDER BY -- Finally we ORDER the result-set in descending order on the basis of 'amortization_depriciation_percentage' using DESC statement, basically so that the clubs with the most ammortization_depriciation_percentage come out at top, showing the most high risk clubs at the top , while relativeley efficient clubs ar bottom.
    amortization_depriciation_percentage DESC;

/* Problem 9 : Calculate the interest burden(Net Interest & Debt Servicing as % of revenue) of clubs to assess debt exposure risk :-
   - We create the first CTE named revenue_info where we retrieve the club_id and their corresponding total_revenue(SUM of all amount_euros_millions from all revenue streams) from the club_revenue table, grouping by club_id so that we get the aggregated total revenue for each individual club in the database.
   - We create the second CTE named finance_info where we INNER JOIN the club_expenditure table with club_dim table to retrieve club names, and further INNER JOIN with the revenue_info CTE to access total revenue information, all on the common column of club_id, and we filter the results using WHERE clause to only include expenditure_type of 'Net Interest & Debt Servicing' records.
   - In the finance_info CTE we calculate a new entity called finance_cost_percentage which determines what percentage the net interest and debt servicing expenditure amount makes up of the club's total revenue using the formula ((amount_euros_millions / total_revenue) * 100), rounded to 2 decimal places, where higher percentages indicate greater debt burden.
   - In the main query we retrieve all information from finance_info CTE and create a new entity called financial_costs_ratio_status using CASE statements which assigns each club a financial health status based on their finance_cost_percentage: 'High-Risk Spending' if above 4%, 'Balanced Spending' if between 1-4%, and 'Efficient Spending' if 1% or below.
   - Finally we ORDER BY the result in descending order of finance_cost_percentage so that clubs with the highest debt servicing burden (representing greater financial risk and leverage exposure) appear at the top, while clubs with efficient debt management appear at the bottom, enabling us to identify which clubs have dangerous debt levels that could threaten their long-term financial sustainability and competitive ability.
*/
WITH revenue_info AS ( -- In this CTE we will find out the total revenue of the clubs from the club_revenue table so that we can compare this total revenue of the club with the expenditure amount of 'net interest & debt servicing' of the club found in the 2nd CTE of finance_info... so for which over here we will find the SUM of the amount(cr.amount_euros_millions) for all the revenue streams of the club, when the result is grouped on the basis of club(club_id).
SELECT
    club_id,
    SUM(amount_euros_millions) AS total_revenue -- Since in the club_revenue table, the distribution of revenue sources of various clubs is shown for its various revenue sources, the SUM of amount_euros_millions will give the total revenue(including the amounts of all the revenue_streams) of that particular club(since the CTE is grouped on the basis of club_id).
FROM -- we will be retrieving the total_revenue info of the clubs from the table of club_revenue.
    club_revenue
GROUP BY -- Grouping the results on the basis of club_id, so that the aggregated result of the query being SUM of amounts(cr.amount_euros_millions) of all revenue streams of that club corresponding to that club(club_id).
    club_id
),
finance_info AS ( -- This is our 2nd CTE where we will find out the expenditure amount of 'Net Interest & Debt Servicing' of the club along with its name(from club_dim) and also compare it with the total revenue of the club(found in revenue_info CTE), to retrieve all these info from different tables/CTEs we need to INNER JOIN all the tables together on the common column of club_id, since its INNER JOIN it will retrieve only those clubs/club_ids which are common in all the joined tables(which being all of them, since a club defined in club_dim is also explained in club_expenditure and also club_revenue/revenue_info CTE).
SELECT
    ce.club_id, -- Since club_id is an ambigous column, we need to mention the table reference alongside it for which we mentioned the club_expenditure table's reference, but that dosent mean it will pull out the club_ids only from ce table, rather since we used inner join on the basis of common column of club_id, so the club_ids which are common in all of the INNER JOINED tables of ce(club_expenditure), cd(club_dim) and ri(revenue_info) CTE will be displayed, that being all the clubs since all the clubs explained in club_dim are being used in ce and cr tables(hence also there in ri CTE).
    cd.club_name, -- Here the table reference wasnt necessary, but for simplicity of reading we added the reference what were we get the info of that being from club_dim table.
    expenditure_type,
    amount_euros_millions AS expenditure_amount,
    total_revenue,
    ROUND(((amount_euros_millions / total_revenue) * 100), 2) AS finance_cost_percentage -- This will find the percentage that the expenditure amount of Net Interest & Debt Servicing' is gonna make up of the club's total_revenue using the formula ((expenditure_amount / total_revenue) * 100), and the ROUND([formula], 2) will find out the result of percentage in 2 decimal places.
FROM -- Since mostly we are retreiving expenditure info, we will retrieve that from club_expenditure table, we can do it any other way too ensuring we are putting other tables in the FROM clause and the current tables in join statements, since this operates as a package of joined tables rather than one table from FROM statement. Here the ce being the LEFT table wont have much significance like it would have had if this was LEFT JOIN, becauuse in INNER JOIN ony the coommon values from the common columns of the three tables will be included.
    club_expenditure AS ce
JOIN -- We are INNER JOINING the table of club_dim with club_expenditure table(from where we retrieved the expenditure info) so that we can retrieve the club_names of all the clubs mentioned common in three inner joined tables(i.e all the clubs).
    club_dim AS cd ON ce.club_id = cd.club_id
JOIN -- We are INNER JOINING the CTE of revenue_info on the pre joined stack of ce & cd(which has the club's expenditure info and name of club) so that we can retrieve the total revenue of all the clubs which are common in all three inner joined tables(i.e all the clubs).
    revenue_info AS ri ON ce.club_id = ri.club_id
WHERE -- Filtering out the result-set to only show the expenditure_type of 'Net Interest & Debt Servicing' , so that in the CTE's and main query's result-set we can show it corresponding to the total_revenue of their respective clubs(club_id) and their club_names.
    expenditure_type = 'Net Interest & Debt Servicing'
)
SELECT -- In the main query we will ensure to call out all the info from the 2nd CTE and create a new entity 'financial_costs_ratio_status' which assigns the status to each club based on their finance_cost_percentage value using CASE statements.
    club_id,
    club_name,
    expenditure_type,
    expenditure_amount,
    total_revenue,
    finance_cost_percentage,
    CASE
        WHEN finance_cost_percentage > 4 THEN 'High-Risk Spending'
        WHEN finance_cost_percentage > 1 THEN 'Balanced Spending'
        ELSE 'Efficient Spending'
    END AS financial_costs_ratio_status -- Here we used CASE statements to assign status to each clubs on the basis of its value of finance_cost_percentage(i.e how much percentage its finance costs make up of its total revenue), if finance_cost_percentage > 5% then 'High-risk Spending',5% > finance_cost_percentage > 1% then 'Balanced Spending', finance_cost_percentage < 1% then 'Efficient Spending'.
FROM -- We are retrieving this info from the second CTE of finance_info, since it already combines the info of clubs with club's name(from the details in cd table) with its expenditure info(from ce table) and amount of 'Net Interest & Debt Servicing' compared alongside its club's total_revenue(from ri CTE) by INNER JOINING all tables together.
    finance_info AS fi
ORDER BY -- Finally we arrange the results in descending order og the finance_cost_percentage, i.e the clubs with the most finance_cost_percentage(worst performing clubs financial cost : total revenue wise) being displayed at the top and the clubs with the lowest finance_cost_percentage(best performing financial cost : total revenue wise) being displayed at the bottom.
    finance_cost_percentage DESC;