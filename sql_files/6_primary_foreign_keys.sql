-- 06_primary_foreign_keys.sql
-- 
-- Purpose: Add primary keys and foreign key constraints after validating data quality.

-- I've put PKs va FKs in the CREATE TABLE step

ALTER TABLE customers
ADD CONSTRAINT pk_customers
PRIMARY KEY (customer_id);


-- foreign keys

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY(customer_id)
REFERENCES customers(customer_id);

-- checking primary and foreign keys
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema='public'
ORDER BY tc.table_name, tc.constraint_type;