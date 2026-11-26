USE retail1_db;
-- Task 3: Rank products by sales within each category
-- and display the top three products.

WITH ProductRanking AS (
    SELECT p.product_id,
           p.product_name,
           c.category_name,
           SUM(oi.quantity * oi.unit_price) AS total_sales,
           ROW_NUMBER() OVER (
               PARTITION BY c.category_id
               ORDER BY SUM(oi.quantity * oi.unit_price) DESC,
                        p.product_id
           ) AS sales_rank
    FROM products p
    INNER JOIN categories c
        ON p.category_id = c.category_id
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id, p.product_name,
             c.category_id, c.category_name
)
SELECT *
FROM ProductRanking
WHERE sales_rank <= 3
ORDER BY category_name, sales_rank;

-- Task 4: Compare monthly product sales using LEAD and LAG.

WITH MonthlySales AS (
    SELECT p.product_id,
           p.product_name,
           DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id, p.product_name,
             DATE_FORMAT(o.order_date, '%Y-%m')
),
SalesComparison AS (
    SELECT *,
           LAG(total_sales) OVER (
               PARTITION BY product_id
		-- PARTITION BY groups the sales records product-wise.
               ORDER BY sales_month
           ) AS previous_month_sales,
           LEAD(total_sales) OVER (
               PARTITION BY product_id
               ORDER BY sales_month
           ) AS next_month_sales
    FROM MonthlySales
)
SELECT *,
       total_sales - previous_month_sales AS sales_change
FROM SalesComparison
ORDER BY product_id, sales_month;

-- cte = common table expression