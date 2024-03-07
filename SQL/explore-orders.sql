# Explore all orders
SELECT *
FROM orders;

# View company and time of order for each order
SELECT id, account_id, occurred_at
FROM orders;

# View 10 most recent orders
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at DESC
LIMIT 10;

# View Top 5 most expensive orders
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

# View Top 20 least expensive orders
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

# View most recent orders from account n4251
SELECT *
FROM orders
WHERE account_id = 4251
ORDER BY occurred_at DESC
LIMIT 1000;

# View orders where the order of gloss paper is higher than 1000$
SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000;

# See quantity of non-standard paper that was ordered on each order
SELECT account_id,
		occurred_at,
		standard_qty,
		gloss_qty,
		poster_qty,
		gloss_qty + poster_qty as nonstandard_qty
FROM orders;

# Check percentage of revenue from gloss paper on 10 orders
SELECT id,
		account_id,
		standard_amt_usd,
		gloss_amt_usd,
		poster_amt_usd,
		(poster_amt_usd * 100) / (standard_amt_usd + gloss_amt_usd + poster_amt_usd) as poster_rev_prctg
FROM orders
LIMIT 10;

# See which customers are up for a new order
# 'Current Date' is Jan 2017, let's check for orders of 6 to 9 months prior
SELECT *
FROM orders
WHERE occurred_at >= '2016-04-01' AND occurred_at <= '2016-10-01'
ORDER BY occurred_at;

# See orders made in 1Q of 2016
SELECT *
FROM orders
WHERE occurred_at BETWEEN '2016-04-01' AND '2016-10-01'
ORDER BY occurred_at;

# Selecting orders where some type of paper was omitted
SELECT account_id,
		occurred_at,
		standard_qty,
		gloss_qty,
		poster_qty
FROM orders
WHERE standard_qty = 0 OR gloss_qty = 0 OR poster_qty = 0

# Selecting orders where some type of paper was omitted after 2016
SELECT account_id,
		occurred_at,
		standard_qty,
		gloss_qty,
		poster_qty
FROM orders
WHERE (standard_qty = 0 OR gloss_qty = 0 OR poster_qty = 0)
		AND occurred_at >= '2016-10-01';

# Select only company name and time of order
SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

# See all account, date and total of number of order and income made in each 2015 order
SELECT a.name as account_name,
		o.total as order_total,
		o.total_amt_usd as total_amt_usd,
		o.occurred_at as date
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY o.occurred_at DESC;

# Check number of orders made in December 2026
SELECT COUNT(*) as order_count
FROM orders
WHERE occurred_at >= '2016-12-01'
	AND occurred_at < '2017-01-01';

# Check price per unit for all orders
SELECT (SUM(standard_amt_usd) / SUM(standard_qty)) as price_per_unit
FROM orders;

# Check min and max of each paper quantity ever ordered
SELECT MIN(standard_qty) as standard_min,
		MAX(standard_qty) as standard_max,
		MIN(gloss_qty) as gloss_min,
		MAX(gloss_qty) as gloss_max,
		MIN(poster_qty) as poster_min,
		MAX(poster_qty) as poster_max
FROM orders;

# See average of each type of paper and
SELECT AVG(standard_qty) as std_q,
		AVG(poster_qty) as pst_q,
		AVG(gloss_qty) as gls_q,
		AVG(standard_amt_usd) as std_usd,
		AVG(poster_amt_usd) as pst_usd,
		AVG(gloss_amt_usd) as gls_usd
FROM orders;

# Check total quantity of paper ever ordered per company
SELECT account_id,
		SUM(standard_qty) as std_sum,
		SUM(gloss_qty) as gls_sum,
		SUM(poster_qty) as pst_qty
FROM orders
GROUP BY account_id
ORDER BY account_id;

# Check total quantity of ordered paper per day of the week
SELECT DATE_PART('dow', occurred_at) as day_of_week,
		SUM(total) as total_qty
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

# Which month did Parch & Posey have the greatest sales in terms of total dollars?
SELECT DATE_PART('month', occurred_at) as month,
		SUM(total_amt_usd) as total_usd
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

# Check yearly income trend
SELECT DATE_PART('year', occurred_at) as year,
		SUM(total_amt_usd) as total_usd
FROM orders
GROUP BY 1
ORDER BY 1;

# Classify each order by Large or Small
SELECT account_id,
		total_amt_usd,
		CASE WHEN total_amt_usd > 3000 THEN 'Large'
		ELSE 'Small' END AS order_level
FROM orders

# Count number of orders where total product is over and under 500
SELECT CASE WHEN total > 500 THEN 'Over 500'
		ELSE '500 or under' END AS total_group,
		COUNT(*) AS order_count
FROM orders
GROUP BY 1;

# Count number of orders according ordered product
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
		WHEN total > 1000 AND total < 2000 THEN 'Between 1000 and 2000'
		WHEN total <= 1000 THEN 'Less than 1000' END AS order_level,
		COUNT(*) AS order_count
FROM orders
GROUP BY 1;

# What is the lifetime average amount spent, including only the companies that spent more per order, on average,
# than the average of all orders.
WITH t1 AS (SELECT AVG(o.total_amt_usd) AS avg_all
			FROM accounts a
			JOIN orders o
			ON a.id = o.account_id),
	t2 AS (SELECT o.account_id,
		   		AVG(o.total_amt_usd) AS avg_amt
			FROM orders o
		   GROUP BY 1
		   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))


SELECT AVG(avg_amt)
FROM t2

