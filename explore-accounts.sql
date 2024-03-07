# View account data
SELECT *
    FROM accounts;

# View all accounts that are not United Technologies
SELECT *
FROM accounts
WHERE name != 'United Technologies';

# View website and person of contact for Exxon Mobil
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';

# Check company name that start with C
SELECT name
FROM accounts
WHERE name LIKE 'C%';

# Check company name that have 'one' in the name
SELECT name
FROM accounts
WHERE name LIKE '%one%';

# Check companies' name that ends with s
SELECT * #should be name
FROM accounts
WHERE name LIKE '%s';

# Check person of contact and sales representative id for Walmart, Target and Nordstrom
SELECT name,
		primary_poc,
		sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

# Finding company name and person of contact
SELECT *
FROM accounts
WHERE (name LIKE 'C%' or name LIKE 'W%')
			AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
			AND primary_poc NOT LIKE '%eana%');

# Check unit price of product for each order, along with company name and region
SELECT r.name as region,
		a.name as account_name,
		o.total_amt_usd / (o.total + 0.01) as unit_price
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id;

# How many accounts have more than 20 orders?
SELECT a.name,
		COUNT(*) as ord_total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) > 20
ORDER BY COUNT(*) DESC;

# Which account has the most orders?
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

# Which accounts spent less than 1,000 usd total across all orders?
SELECT a.name,
		SUM(o.total_amt_usd) as account_total_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY COUNT(a.name) DESC;

# Which account has spent the most with us?
SELECT a.name,
		SUM(o.total_amt_usd) as account_total_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY SUM(o.total_amt_usd) DESC
LIMIT 1;

# In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', o.occurred_at) as month_year,
		SUM(o.gloss_amt_usd) as total_gloss
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC;

# Classify accounts by lifetime value
SELECT a. name,
		SUM(o.total_amt_usd) as lifetime_value,
		CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN 'Top Level (Greater than 200,000)'
		WHEN SUM(o.total_amt_usd) > 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Second Level (Between 200,000 and 100,000)'
		WHEN SUM(o.total_amt_usd) <= 100000 THEN 'Low Level (Under 100,000)' END AS order_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY lifetime_value DESC;

# Classify accounts by lifetime value based on 2016 and 2017
SELECT a. name,
		SUM(o.total_amt_usd) as lifetime_value,
		CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN 'Top Level (Greater than 200,000)'
		WHEN SUM(o.total_amt_usd) > 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Second Level (Between 200,000 and 100,000)'
		WHEN SUM(o.total_amt_usd) <= 100000 THEN 'Low Level (Under 100,000)' END AS order_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE o.occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY 2 DESC;
