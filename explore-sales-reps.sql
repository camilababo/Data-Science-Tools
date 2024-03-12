# Check region, sales rep name for each account name
SELECT r.name as region,
		s.name as sales_rep_name,
		a.name as account_name
FROM sales_reps s
JOIN region r
ON 	s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;

# Check all sales reps and respective company within the 'Midwest' region
SELECT r.name as region_name,
		s.name as sales_rep_name,
		a.name as account_name
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name;

# Check how many sales reps there are for region
SELECT r.name,
		COUNT(s.name) as total_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY total_reps;

# How many of the sales reps have more than 5 accounts that they manage?
SELECT s.name,
		COUNT(*) as num_account
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(*) > 5
ORDER BY num_account;

# Check top performing sales reps by number of orders
SELECT s.name,
		COUNT(*),
		CASE WHEN COUNT(*) >= '200' THEN 'Top'
		ELSE 'Not' END AS sales_rep_class
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY COUNT(*) DESC;

# Check top performing sales reps by number of orders and income
SELECT s.name,
		COUNT(*) as total_sales,
		SUM(o.total_amt_usd) as total_sales_usd,
		CASE WHEN COUNT(*) >= '200' OR SUM(o.total_amt_usd) >= '750000' THEN 'Top'
		WHEN COUNT(*) >= '150' AND COUNT(*) < '200' OR SUM(o.total_amt_usd) >= '500000' THEN 'Middle'
		WHEN COUNT(*) < '150' OR SUM(o.total_amt_usd) < '500000' THEN 'Not' END AS sales_rep_class
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY total_sales_usd DESC;

# Check top performing sales reps name for each region
WITH sales_rep_reg AS (
			SELECT s.name as sales_rep_name,
					r.name as region,
					SUM(total_amt_usd) as total_sales
			FROM sales_reps s
				JOIN region r
				ON s.region_id = r.id
				JOIN accounts a
				ON s.id = a.sales_rep_id
				JOIN orders o
				ON a.id = o.account_id
			GROUP BY 1,2
			ORDER BY 3 DESC),
		region_max AS (
				SELECT region,
						MAX(total_sales) AS top_reg_sales
				FROM sales_rep_reg
				GROUP BY 1)

SELECT sales_rep_reg.sales_rep_name,
		sales_rep_reg.region,
		total_sales
FROM region_max
JOIN sales_rep_reg
ON region_max.region = sales_rep_reg.region AND region_max.top_reg_sales = sales_rep_reg.total_sales;

# Create first and last name colums
SELECT *,
		LEFT(name, POSITION(' ' IN name) -1) as first_name,
		RIGHT(name, (LENGTH(name) - POSITION(' ' IN name))) AS last_name
FROM sales_reps;

