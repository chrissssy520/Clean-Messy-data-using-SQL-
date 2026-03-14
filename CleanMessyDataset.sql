-- ==========================================================
-- DATA CLEANING PROJECT: Messy Retail Dataset
-- Author: Christian Kho Aler
-- Description: Standardizing casing, fixing mixed dates, 
--              handling NULLs, and removing duplicates.
-- ==========================================================

-- 1. CLEANING PRODUCTS TABLE
----------------------------------------------------------

-- 

-- Fix casing, spaces, and ensure price is numeric
UPDATE products
SET 
    category = TRIM(LOWER(category)),
    brand = TRIM(UPPER(brand)),
    product_name = TRIM(LOWER(product_name)),
    price = CAST(price AS DECIMAL(10,2));

-- Handle missing product names (Placeholder instead of NULL)
UPDATE products
SET product_name = 'unknown product'
WHERE product_name IS NULL OR product_name = '';

-- Remove Duplicate Products using Temp Table (MySQL Safe Way)
CREATE TEMPORARY TABLE keep_product_ids AS
SELECT MIN(product_id) as product_id
FROM products
GROUP BY product_name, brand, price; -- Group by traits to find actual uniques

DELETE FROM products
WHERE product_id NOT IN (SELECT product_id FROM keep_product_ids);

DROP TEMPORARY TABLE keep_product_ids;


-- 2. CLEANING TRANSACTIONS TABLE
----------------------------------------------------------

-- Fix basic casing and trim spaces for all string columns
UPDATE transactions
SET 
    customer_name = TRIM(LOWER(customer_name)),
    customer_city = TRIM(customer_city),
    gender = TRIM(UPPER(gender)),
    payment_method = TRIM(UPPER(payment_method));

-- Standardize Gender values (Categorical Mapping)
UPDATE transactions
SET gender = CASE 
    WHEN gender IN ('M', 'MALE', 'MAN') THEN 'Male'
    WHEN gender IN ('F', 'FEMALE', 'WOMAN', 'WOMEN') THEN 'Female'
    ELSE 'Unknown' 
END;

-- Standardize Payment Method (Proper Casing/Logic)
UPDATE transactions
SET payment_method = CASE 
    WHEN payment_method LIKE '%CREDIT%' OR payment_method = 'CC' THEN 'Credit Card'
    WHEN payment_method LIKE '%CASH%' THEN 'Cash'
    WHEN payment_method LIKE '%BITCOIN%' OR payment_method LIKE '%CRYPTO%' THEN 'Cryptocurrency'
    WHEN payment_method LIKE '%WALLET%' OR payment_method = 'GCASH' THEN 'Digital Wallet'
    ELSE payment_method 
END;

-- Fix Mixed Date Formats (The "Boss Level" Logic)
-- 
UPDATE transactions 
SET transaction_date = CASE 
    WHEN transaction_date LIKE '____/%/%' THEN STR_TO_DATE(transaction_date, '%Y/%m/%d')
    WHEN transaction_date LIKE '%/%/____' THEN STR_TO_DATE(transaction_date, '%m/%d/%Y')
    WHEN transaction_date LIKE '____-__-__' THEN STR_TO_DATE(transaction_date, '%Y-%m-%d')
    WHEN transaction_date LIKE '__-__-____' THEN STR_TO_DATE(transaction_date, '%d-%m-%Y')
    ELSE transaction_date 
END;

-- Handle NULL quantity or total_amount (Remove incomplete records)
DELETE FROM transactions
WHERE quantity IS NULL OR total_amount IS NULL OR total_amount = 0;

-- Remove Duplicate Transactions using Temp Table
CREATE TEMPORARY TABLE keep_trans_ids AS
SELECT MIN(transaction_id) as transaction_id
FROM transactions
GROUP BY customer_name, product_id, transaction_date, total_amount;

DELETE FROM transactions
WHERE transaction_id NOT IN (SELECT transaction_id FROM keep_trans_ids);

DROP TEMPORARY TABLE keep_trans_ids;

-- Final Check
SELECT * FROM products LIMIT 10;
SELECT * FROM transactions LIMIT 10;