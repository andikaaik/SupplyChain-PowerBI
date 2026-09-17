--Dashboard Inventory Overview

-- Card Chart
SELECT
    COUNT(DISTINCT "Product_ID") AS total_product,
    SUM("Stock_Quantity") AS total_stock,
    SUM(
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value
FROM dataset.grocery_inventory_and_sales_dataset;

-- Low Stock
SELECT
    COUNT(DISTINCT "Product_ID") AS low_stock_product
FROM dataset.grocery_inventory_and_sales_dataset
WHERE "Stock_Quantity" < "Reorder_Level";

-- Total stock by Catagory
SELECT
    "Catagory",
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Catagory"
ORDER BY total_stock DESC;

--Low Inventory Value by Warehouse
SELECT
    "Warehouse_Location",
    SUM(
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Warehouse_Location"
ORDER BY inventory_value desc;

--stock total by supplier
SELECT
    "Supplier_Name",
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Supplier_Name"
ORDER BY total_stock DESC;

-- stock by date
SELECT
    "Date_Received"::date AS date_received,
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Date_Received"::date
ORDER BY date_received;

--warning stock
SELECT
    "Product_Name",
    "Reorder_Level",
    "Stock_Quantity"
FROM dataset.grocery_inventory_and_sales_dataset
WHERE "Stock_Quantity" < "Reorder_Level"
ORDER BY "Stock_Quantity" DESC;

--Dashboard Product Analysis

--Card chart
SELECT
    COUNT(DISTINCT "Product_ID") AS total_product,
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset;

--invenotry value
select
"Product_Name" as produk,
    SUM(
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value
FROM dataset.grocery_inventory_and_sales_dataset
group by "Product_Name" order by inventory_value desc limit 20;

--Lowest Stock
SELECT
    "Product_Name",
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Product_Name"
ORDER BY total_stock ASC
LIMIT 10;

--highest
SELECT
    "Product_Name",
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Product_Name"
ORDER BY total_stock DESC
LIMIT 10;

--Expiry status
SELECT
    CASE
        WHEN "Expiration_Date"::date < "Last_Order_Date"::date
            THEN 'Expired on Arrival'
        WHEN "Expiration_Date"::date - "Last_Order_Date"::date <= 30
            THEN '≤30 Days'
        WHEN "Expiration_Date"::date - "Last_Order_Date"::date <= 60
            THEN '31-60 Days'
        WHEN "Expiration_Date"::date - "Last_Order_Date"::date <= 90
            THEN '61-90 Days'
        ELSE '>90 Days'
    END AS shelf_life_status,
    COUNT(*) AS total_product
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY
    CASE
        WHEN "Expiration_Date"::date < "Last_Order_Date"::date
            THEN 'Expired on Arrival'
        WHEN "Expiration_Date"::date - "Last_Order_Date"::date <= 30
            THEN '≤30 Days'
        WHEN "Expiration_Date"::date - "Last_Order_Date"::date <= 60
            THEN '31-60 Days'
        WHEN "Expiration_Date"::date - "Last_Order_Date"::date <= 90
            THEN '61-90 Days'
        ELSE '>90 Days'
    END
ORDER BY total_product DESC;

--Product summary
SELECT
    "Product_Name",
    "Catagory",
    "Stock_Quantity",
    (
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value,
    "Inventory_Turnover_Rate",
    "Last_Order_Date"::date AS last_order_date,
    "Expiration_Date"::date AS expiration_date,
    (
        "Expiration_Date"::date -
        "Last_Order_Date"::date
    ) AS shelf_life_days
FROM dataset.grocery_inventory_and_sales_dataset
ORDER BY shelf_life_days asc;

--Dahboard Warehouse Analysis

--Card
SELECT
    COUNT(DISTINCT "Warehouse_Location") AS total_warehouse,
    SUM("Stock_Quantity") AS total_stock,
    SUM(
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value
FROM dataset.grocery_inventory_and_sales_dataset;

--highest stock
SELECT
    "Warehouse_Location",
    SUM("Stock_Quantity") AS total_stock
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Warehouse_Location"
ORDER BY total_stock DESC
LIMIT 10;

--highest value
SELECT
    "Warehouse_Location",
    SUM(
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Warehouse_Location"
ORDER BY inventory_value DESC
LIMIT 10;

--stock distribution

WITH warehouse_stock AS (
    SELECT
        location_key,
        SUM(stock_quantity) AS total_stock
    FROM dataset.fact_inventory
    GROUP BY location_key
),
quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY total_stock) AS q1,
        PERCENTILE_CONT(0.50)
            WITHIN GROUP (ORDER BY total_stock) AS median,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY total_stock) AS q3
    FROM warehouse_stock
)
SELECT *
FROM quartiles;

WITH warehouse_stock AS (
    SELECT
        location_key,
        SUM(stock_quantity) AS total_stock
    FROM dataset.fact_inventory
    GROUP BY location_key
),
quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY total_stock) AS q1,
        PERCENTILE_CONT(0.50)
            WITHIN GROUP (ORDER BY total_stock) AS median,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY total_stock) AS q3
    FROM warehouse_stock
),
warehouse_category AS (
    SELECT
        ws.location_key,
        ws.total_stock,
        q.q1,
        q.median,
        q.q3,
        CASE
            WHEN ws.total_stock < q.q1
                THEN 'Low'
            WHEN ws.total_stock <= q.q3
                THEN 'Medium'
            ELSE 'High'
        END AS stock_level
    FROM warehouse_stock ws
    CROSS JOIN quartiles q
)
SELECT
    stock_level,
    COUNT(*) AS total_warehouse,
    SUM(total_stock) AS total_stock
FROM warehouse_category
GROUP BY stock_level
ORDER BY
    CASE stock_level
        WHEN 'Low' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High' THEN 3
    END;

--product summary
SELECT
    "Warehouse_Location",
    SUM("Stock_Quantity") AS total_stock,
    SUM(
        "Stock_Quantity" *
        REPLACE(REPLACE("Unit_Price", '$', ''), ',', '')::numeric
    ) AS inventory_value
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Warehouse_Location"
ORDER BY inventory_value DESC;

--Dashboard Replenishment

--need replenishment
SELECT
    COUNT(DISTINCT "Product_ID") AS need_replenishment
FROM dataset.grocery_inventory_and_sales_dataset
WHERE "Stock_Quantity" < "Reorder_Level";

--oos product
SELECT
    COUNT(DISTINCT "Product_ID") AS oos_product
FROM dataset.grocery_inventory_and_sales_dataset
WHERE "Stock_Quantity" = 0;

--total reorder
SELECT
    SUM("Reorder_Quantity") AS total_reorder_quantity
FROM dataset.grocery_inventory_and_sales_dataset
WHERE "Stock_Quantity" < "Reorder_Level";

--stock alert distribution
SELECT
    CASE
        WHEN "Stock_Quantity" = 0
            THEN 'OOS'
        WHEN "Stock_Quantity" < "Reorder_Level"
            THEN 'Need Replenishment'
        ELSE 'Normal'
    END AS stock_alert_status,
    COUNT(*) AS total_record
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY
    CASE
        WHEN "Stock_Quantity" = 0
            THEN 'OOS'
        WHEN "Stock_Quantity" < "Reorder_Level"
            THEN 'Need Replenishment'
        ELSE 'Normal'
    END
ORDER BY total_record DESC;

--product reorder
SELECT
    "Product_Name",
    SUM("Reorder_Level") AS total_reorder_level
FROM dataset.grocery_inventory_and_sales_dataset
GROUP BY "Product_Name"
ORDER BY total_reorder_level DESC
LIMIT 10;

-- replenishment tabel
SELECT
    "Product_Name",
    "Warehouse_Location",
    "Stock_Quantity",
    "Reorder_Level",
    "Reorder_Quantity",
    CASE
        WHEN "Stock_Quantity" = 0
            THEN 'OOS'
        WHEN "Stock_Quantity" < "Reorder_Level"
            THEN 'Need Replenishment'
        ELSE 'Normal'
    END AS stock_alert_status
FROM dataset.grocery_inventory_and_sales_dataset
WHERE "Stock_Quantity" < "Reorder_Level"
ORDER BY "Stock_Quantity" ASC;




