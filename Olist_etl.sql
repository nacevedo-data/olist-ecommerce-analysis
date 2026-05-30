# Star Schema

# dim_cliente ─┐
# dim_producto─┤
# dim_fecha  ──┼── fact_orders
# dim_geo    ──┤
# dim_pago   ──┘
---------------------------------------------------------------------------
# Creacion de la base de datos
---------------------------------------------------------------------------
create database olist_dw;
use olist_dw;
---------------------------------------------------------------------------
# creacion de la tabla staging y carga de datos
---------------------------------------------------------------------------
CREATE TABLE stg_olist_full (
product_category_name VARCHAR(100),
product_category_name_english VARCHAR(100),
order_id VARCHAR(100),
order_item_id VARCHAR(100),
product_id VARCHAR(100),
seller_id VARCHAR(100),	
shipping_limit_date	VARCHAR(100), 
price VARCHAR(100),
freight_value VARCHAR(100),
customer_id	VARCHAR(100),
order_status VARCHAR(100),
order_purchase_timestamp VARCHAR(100),
order_approved_at VARCHAR(100),
order_delivered_carrier_date VARCHAR(100),
order_delivered_customer_date VARCHAR(100),
order_estimated_delivery_date VARCHAR(100),
product_name_lenght VARCHAR(100),
product_description_lenght VARCHAR(100),
product_photos_qty VARCHAR(100),
product_weight_g VARCHAR(100),
product_length_cm VARCHAR(100),
product_height_cm VARCHAR(100),
product_width_cm VARCHAR(100),
revenue VARCHAR(100),
freight	VARCHAR(100), total VARCHAR(100),
review_id VARCHAR(100),
review_score VARCHAR(100),
review_comment_title VARCHAR(100),
review_comment_message VARCHAR(100),
review_creation_date VARCHAR(100),
review_answer_timestamp	VARCHAR(100),
payment_sequential	VARCHAR(100),
payment_type	VARCHAR(100),
payment_installments	VARCHAR(100),
payment_value	VARCHAR(100),
customer_unique_id	VARCHAR(100),
customer_zip_code_prefix	VARCHAR(100),
customer_city	VARCHAR(100),
customer_state VARCHAR(100)
);

SET GLOBAL local_infile = 1; # Activa el LOAD DATA LOCAL INFILE

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/df_full_olist.csv'
INTO TABLE stg_olist_full
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_category_name,	product_category_name_english,	order_id,	order_item_id,	product_id,	seller_id,	shipping_limit_date,	price,	freight_value,
customer_id,	order_status,	order_purchase_timestamp,	order_approved_at,	order_delivered_carrier_date,	order_delivered_customer_date,	order_estimated_delivery_date,
product_name_lenght,	product_description_lenght,	product_photos_qty,	product_weight_g,	product_length_cm,	product_height_cm,	product_width_cm,	revenue,	freight,	total,
review_id,	review_score,	review_comment_title,	review_comment_message,	review_creation_date,	review_answer_timestamp,	payment_sequential,	payment_type,	
payment_installments,	payment_value,	customer_unique_id,	customer_zip_code_prefix,	customer_city,	customer_state
);

-- VERIFICACION DE CARGA --
SELECT COUNT(*) 
FROM stg_olist_full;
#  Se cargaron 113209 filas
---------------------------------------------------------------------------
# Creacion de las dimensiones y carga de los datos
---------------------------------------------------------------------------
CREATE TABLE dim_cliente (
    customer_unique_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

INSERT INTO dim_cliente
SELECT customer_unique_id, # tomamos solo la primera ocurrencia de cada customer_unique_id
       MIN(customer_id), 
       MIN(customer_city),  
       MIN(customer_state) 
FROM stg_olist_full
GROUP BY customer_unique_id;

-- Verificacion de carga --
SELECT COUNT(*) FROM dim_cliente;
# Se insertaron 91480 filas (clientes unicos)

CREATE TABLE dim_producto (      
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(50),
    product_category_name  VARCHAR(50)
);

INSERT INTO dim_producto 
SELECT product_id, 
       MIN(product_category_name_english), 
       MIN(product_category_name)
FROM stg_olist_full
GROUP BY product_id
;

SELECT COUNT(*) FROM dim_producto; 
# Se insertaron 31481 filas (productos unicos)

CREATE TABLE dim_geo (      
    customer_zip_code_prefix VARCHAR(50) PRIMARY KEY,
    customer_city VARCHAR(100),
    customer_state  VARCHAR(50)
    
);

INSERT INTO dim_geo
SELECT customer_zip_code_prefix, 
       MIN(customer_city), 
       MIN(customer_state)
FROM stg_olist_full
GROUP BY customer_zip_code_prefix;

SELECT COUNT(*) from dim_geo;
# Se insertaron 14825 filas (Codigos postales unicos)

CREATE TABLE dim_pago (      
    payment_type VARCHAR(100) PRIMARY KEY,
    payment_installments  INT
);

ALTER TABLE dim_pago DROP COLUMN payment_installments;

INSERT INTO dim_pago
SELECT DISTINCT payment_type
FROM stg_olist_full;

SELECT COUNT(*) FROM dim_pago;
# Se insertaron 4 filas (metodos de pago unicos)

CREATE TABLE dim_fecha (
    date_id DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    quarter INT,
    day_of_week VARCHAR(20)
);

INSERT INTO dim_fecha
SELECT DISTINCT
    DATE(order_purchase_timestamp) AS date_id,
    YEAR(order_purchase_timestamp) AS year,
    MONTH(order_purchase_timestamp) AS month,
    DAY(order_purchase_timestamp) AS day,
    QUARTER(order_purchase_timestamp) AS quarter,
    DAYNAME(order_purchase_timestamp) AS day_of_week
FROM stg_olist_full
WHERE order_purchase_timestamp IS NOT NULL AND order_purchase_timestamp != '';

SELECT COUNT(*) FROM dim_fecha;
# Se insertaron 611 filas (días únicos con órdenes en el período 2016-2018)

# TABLA DE HECHOS: INGENIERÍA DE PEDIDOS (fact_orders)
CREATE TABLE fact_orders (
    order_id VARCHAR(50),
    order_item_id INT,
    customer_unique_id VARCHAR(50),
    product_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(50),
    payment_type VARCHAR(100),
    order_purchase_date_key DATE,

    -- Métricas
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    revenue DECIMAL(10,2),
    freight DECIMAL(10,2),
    total DECIMAL(10,2),
    review_score INT,

    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (customer_unique_id) REFERENCES dim_cliente(customer_unique_id),
    FOREIGN KEY (product_id) REFERENCES dim_producto(product_id),
    FOREIGN KEY (customer_zip_code_prefix) REFERENCES dim_geo(customer_zip_code_prefix),
    FOREIGN KEY (payment_type) REFERENCES dim_pago(payment_type),
    FOREIGN KEY (order_purchase_date_key) REFERENCES dim_fecha(date_id)
)
;

ALTER TABLE fact_orders ADD COLUMN payment_installments INT;

INSERT IGNORE INTO fact_orders
SELECT 
    order_id,
    order_item_id,
    customer_unique_id,
    product_id,
    customer_zip_code_prefix,
    payment_type,
    DATE(order_purchase_timestamp) AS order_purchase_date_key,
    price,
    freight_value,
    revenue,
    freight,
    total,
    review_score,
    payment_installments
FROM stg_olist_full;

SELECT COUNT(*) FROM fact_orders;
# Se insertaron 107819 filas
---------------------------------------------------------------------------
# El ETL está completo.
# Resumen de lo construido:

# ✅ dim_cliente — 91.480 clientes únicos
# ✅ dim_producto — 31.481 productos únicos
# ✅ dim_geo — 14.825 códigos postales
# ✅ dim_pago — 4 métodos de pago
# ✅ dim_fecha — 611 días únicos
# ✅ fact_orders — 107.819 órdenes
---------------------------------------------------------------------------
# Verificacion final
---------------------------------------------------------------------------

SELECT 
    p.product_category_name_english,
    SUM(f.revenue) AS revenue_total
FROM fact_orders f
JOIN dim_producto p ON f.product_id = p.product_id
GROUP BY p.product_category_name_english
ORDER BY revenue_total DESC
LIMIT 10;

# product_category_name_english  revenue_total
# health_beauty	                 1224543.61
# watches_gifts	                 1159219.92
# bed_bath_table	             1013430.82
# sports_leisure	             948960.45
# computers_accessories	         884760.96
# furniture_decor	             705997.44
# housewares	                 611635.68
# cool_stuff	                 603221.05
# auto	                         571453.35
# garden_tools	                 467301.19

---------------------------------------------------------------------------
-- Descarga de los archivos CSV --
---------------------------------------------------------------------------
-- dim_cliente
SELECT 'customer_unique_id', 'customer_id', 'customer_city', 'customer_state'
UNION ALL SELECT * FROM dim_cliente
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_cliente.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- dim_producto
SELECT 'product_id', 'product_category_name_english', 'product_category_name'
UNION ALL SELECT * FROM dim_producto
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_producto.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- dim_geo
SELECT 'customer_zip_code_prefix', 'customer_city', 'customer_state'
UNION ALL SELECT * FROM dim_geo
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_geo.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- dim_pago
SELECT 'payment_type'
UNION ALL SELECT * FROM dim_pago
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_pago.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- dim_fecha
SELECT 'date_id', 'year', 'month', 'day', 'quarter', 'day_of_week'
UNION ALL SELECT * FROM dim_fecha
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_fecha.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

-- fact_orders
SELECT 'order_id', 'order_item_id', 'customer_unique_id', 'product_id', 'customer_zip_code_prefix', 'payment_type', 'order_purchase_date_key', 'price', 'freight_value', 'revenue', 'freight', 'total', 'review_score', 'payment_installments'
UNION ALL SELECT * FROM fact_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_orders.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';