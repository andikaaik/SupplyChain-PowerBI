--Data Preparation

create schema if not exists dataset;

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'grocery_inventory_and_sales_dataset';

select count(distinct "Warehouse_Location")
from dataset.grocery_inventory_and_sales_dataset;

SELECT COUNT(*) FROM dataset.grocery_inventory_and_sales_dataset;

SELECT COUNT(DISTINCT "Product_ID")
FROM dataset.grocery_inventory_and_sales_dataset;

SELECT COUNT(DISTINCT "Supplier_ID")
FROM dataset.grocery_inventory_and_sales_dataset;

SELECT DISTINCT "Warehouse_Location"
FROM dataset.grocery_inventory_and_sales_dataset;

SELECT *
FROM dataset.grocery_inventory_and_sales_dataset
LIMIT 5;


--Membuat dim & fact

create table dataset.dim_supplier (
supplier_key SERIAL primary key,
supplier_id varchar(50) unique,
supplier_name varchar(225)
);

insert into dataset.dim_supplier(
supplier_id, supplier_name
)
select distinct
TRIM("Supplier_ID"),
TRIM("Supplier_Name")
from dataset.grocery_inventory_and_sales_dataset
where "Supplier_ID" is not null;

create table dataset.dim_product(
product_key SERIAL primary key,
product_id varchar(50),
product_name varchar(225),
category varchar (100)
);

insert into dataset.dim_product(
product_id, product_name, category
)
select distinct
TRIM("Product_ID"),
TRIM("Product_Name"),
TRIM("Catagory")
from dataset.grocery_inventory_and_sales_dataset
where "Product_ID" is not null;

create table dataset.dim_location (
warehouse_key SERIAL primary key,
warehouse_location varchar(225) unique
);

insert into dataset.dim_location (
warehouse_location
)
select distinct
TRIM("Warehouse_Location") from dataset.grocery_inventory_and_sales_dataset;

CREATE TABLE dataset.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT
);

INSERT INTO dataset.dim_date (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS date_key,
    d AS full_date,
    EXTRACT(DAY FROM d)::INT AS day,
    EXTRACT(MONTH FROM d)::INT AS month,
    TRIM(TO_CHAR(d, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM d)::INT AS quarter,
    EXTRACT(YEAR FROM d)::INT AS year
FROM generate_series(
    (
        SELECT MIN(
            LEAST(
                TO_DATE("Date_Received", 'MM/DD/YYYY'),
                TO_DATE("Last_Order_Date", 'MM/DD/YYYY'),
                TO_DATE("Expiration_Date", 'MM/DD/YYYY')
            )
        )
        FROM dataset.grocery_inventory_and_sales_dataset
    ),
    (
        SELECT MAX(
            GREATEST(
                TO_DATE("Date_Received", 'MM/DD/YYYY'),
                TO_DATE("Last_Order_Date", 'MM/DD/YYYY'),
                TO_DATE("Expiration_Date", 'MM/DD/YYYY')
            )
        )
        FROM dataset.grocery_inventory_and_sales_dataset
    ),
    INTERVAL '1 day'
) AS dates(d);

--buat fact
CREATE TABLE dataset.fact_inventory (
    inventory_key SERIAL PRIMARY KEY,
    product_key INT NOT NULL,
    supplier_key INT NOT NULL,
    location_key INT NOT NULL,
    date_received_key INT,
    last_order_date_key INT,
    expiration_date_key INT,
    stock_quantity INT,
    reorder_level INT,
    sales_volume INT,


    inventory_turnover_rate NUMERIC,
    reorder_quantity INT,
    unit_price NUMERIC(18,2),
    status VARCHAR(50)
);

INSERT INTO dataset.fact_inventory (
    product_key,
    supplier_key,
    location_key,
    date_received_key,
    last_order_date_key,
    expiration_date_key,
    stock_quantity,
    reorder_level,
    sales_volume,
    inventory_turnover_rate,
    reorder_quantity,
    unit_price,
    status
)
SELECT
    p.product_key,
    s.supplier_key,
    l.warehouse_key,
    TO_CHAR(
        TO_DATE(r."Date_Received", 'MM/DD/YYYY'),
        'YYYYMMDD'
    )::INT AS date_received_key,
    TO_CHAR(
        TO_DATE(r."Last_Order_Date", 'MM/DD/YYYY'),
        'YYYYMMDD'
    )::INT AS last_order_date_key,
    TO_CHAR(
        TO_DATE(r."Expiration_Date", 'MM/DD/YYYY'),
        'YYYYMMDD'
    )::INT AS expiration_date_key,
    r."Stock_Quantity",
    r."Reorder_Level",
    r."Sales_Volume",
    r."Inventory_Turnover_Rate",
    r."Reorder_Quantity",
    REPLACE(r."Unit_Price", '$', '')::NUMERIC(18,2) AS unit_price,
    r."Status"
FROM dataset.grocery_inventory_and_sales_dataset AS r
JOIN dataset.dim_product AS p
    ON TRIM(r."Product_ID") = TRIM(p.product_id)
JOIN dataset.dim_supplier AS s
    ON TRIM(r."Supplier_ID") = TRIM(s.supplier_id)
JOIN dataset.dim_location AS l
    ON TRIM(r."Warehouse_Location") = TRIM(l.warehouse_location);

SELECT
    COUNT(*) AS total_empty_category
FROM dataset.dim_product
WHERE category IS NULL
   OR TRIM(category) = '';

SELECT *
FROM dataset.dim_product
WHERE category IS NULL
   OR TRIM(category) = '';

SELECT *
FROM dataset.dim_product
WHERE LOWER(product_name) LIKE '%Cabbage%';

UPDATE dataset.dim_product
SET category = 'Uncategorized'
WHERE LOWER(product_name) = 'cabage'
  AND (category IS NULL OR TRIM(category) = '');

SELECT *
FROM dataset.dim_product
WHERE product_key = 307;

UPDATE dataset.dim_product
SET category = 'Fruits & Vegetables'
WHERE product_key = 307;


--export hasil data dim dan fact
SELECT
    f.inventory_key,
    p.product_id,
    p.product_name,
    p.category,
    s.supplier_id,
    s.supplier_name,
    l.warehouse_location,
    d.full_date AS date_received,
    f.stock_quantity,
    f.reorder_level,
    f.sales_volume,
    f.inventory_turnover_rate,
    f.reorder_quantity,
    f.unit_price,
    f.status
FROM dataset.fact_inventory f
JOIN dataset.dim_product p
    ON f.product_key = p.product_key
JOIN dataset.dim_supplier s
    ON f.supplier_key = s.supplier_key
JOIN dataset.dim_location l
    ON f.location_key = l.warehouse_key
JOIN dataset.dim_date d
    ON f.date_received_key = d.date_key;