# 🧹 Data Cleaning SQL Project: Messy Retail Dataset
**by Christian Kho Aler**

A SQL data cleaning project that takes a deliberately messy Philippine retail grocery dataset and transforms it into a clean, analysis-ready state. This project demonstrates real-world data cleaning techniques using MySQL including casing standardization, NULL handling, duplicate removal, mixed date format fixing, and categorical mapping.

---

## 📁 Dataset

Two messy tables were cleaned in this project:

### `products` (26 rows — includes duplicates)
| Column | Type | Issues Found |
|--------|------|-------------|
| product_id | INT | Duplicate IDs |
| product_name | VARCHAR | Mixed casing, extra spaces, NULL values |
| category | VARCHAR | Inconsistent casing (e.g. `instant noodles`, `BEVERAGES`) |
| brand | VARCHAR | Inconsistent casing (e.g. `argentina`, `NESTLE`) |
| price | DECIMAL / VARCHAR | One value stored as text (`"one hundred thirty five"`) |

### `transactions` (208 rows — includes duplicates and NULLs)
| Column | Type | Issues Found |
|--------|------|-------------|
| transaction_id | INT | Duplicate rows |
| customer_name | VARCHAR | Mixed casing, extra spaces |
| gender | VARCHAR | Inconsistent values (`M`, `MALE`, `male`, `F`, `FEMALE`) |
| customer_city | VARCHAR | Extra whitespace |
| payment_method | VARCHAR | Inconsistent values (`GCASH`, `gcash`, `cash`, `CASH`) |
| quantity | INT | NULL values |
| total_amount | DECIMAL | NULL and zero values |
| transaction_date | DATE | Mixed formats (`YYYY-MM-DD`, `MM/DD/YYYY`, `DD-MM-YYYY`, `YYYY/MM/DD`) |

---

## 🔧 Cleaning Steps

### Products Table
1. **Fix casing and spaces** — Standardized `category` to lowercase, `brand` to uppercase, `product_name` to lowercase, trimmed all extra spaces
2. **Fix wrong data type** — Converted price stored as text to `DECIMAL(10,2)` using `CAST`
3. **Handle NULL product names** — Replaced NULL and empty values with `'unknown product'`
4. **Remove duplicate products** — Used temp table approach (MySQL-safe) grouping by `product_name`, `brand`, and `price` to identify true unique records

### Transactions Table
5. **Fix casing and spaces** — Standardized `customer_name` to lowercase, trimmed `customer_city`, uppercased `gender` and `payment_method` as a pre-processing step
6. **Standardize gender values** — Mapped `M`, `MALE`, `MAN` → `Male` and `F`, `FEMALE`, `WOMAN`, `WOMEN` → `Female` using `CASE WHEN`
7. **Standardize payment methods** — Mapped messy values to clean categories using `LIKE` pattern matching (`Credit Card`, `Cash`, `Digital Wallet`, `Cryptocurrency`)
8. **Fix mixed date formats** — Handled 4 different date formats using `CASE WHEN` + `STR_TO_DATE()` pattern matching
9. **Remove NULL/zero records** — Deleted incomplete transactions where `quantity` or `total_amount` is NULL or zero
10. **Remove duplicate transactions** — Used temp table approach grouping by `customer_name`, `product_id`, `transaction_date`, `total_amount`

---

## 🛠️ SQL Concepts Used

| Concept | Usage |
|--------|-------|
| `UPDATE SET` | Standardizing casing, trimming spaces, fixing types |
| `TRIM()` | Removing leading and trailing whitespace |
| `LOWER()` / `UPPER()` | Standardizing text casing |
| `CAST()` | Converting wrong data types |
| `CASE WHEN` | Categorical mapping for gender and payment method |
| `LIKE` | Pattern matching for payment method standardization |
| `STR_TO_DATE()` | Parsing and converting mixed date formats |
| `IS NULL` | Detecting missing values |
| `DELETE` | Removing NULL records and duplicates |
| `CREATE TEMPORARY TABLE` | MySQL-safe duplicate removal workaround |
| `GROUP BY` + `MIN()` | Identifying which rows to keep during deduplication |
| `NOT IN` | Filtering out rows not in the keep list |

---

## 💡 Key Design Decisions

- **Temp table for duplicate removal** — MySQL does not allow deleting from a table while selecting from it in the same subquery (`Error 1093`). Using a `TEMPORARY TABLE` to store the IDs to keep is the correct MySQL-safe workaround.
- **Group by traits, not just ID** — For products, duplicates were identified by grouping on `product_name`, `brand`, and `price` — not just `product_id` — to catch true logical duplicates even if IDs differ.
- **DELETE over UPDATE for NULLs** — Incomplete transaction records with NULL `quantity` or `total_amount` were deleted rather than filled with estimates, since fabricating transaction data would compromise analysis accuracy.
- **LIKE pattern matching for payment methods** — Used `LIKE '%CREDIT%'` instead of exact matching to catch variations like `credit card`, `CREDIT CARD`, `Credit Card` in one rule.
- **Pre-uppercase before CASE WHEN on gender** — Applied `TRIM(UPPER(gender))` first, then ran the `CASE WHEN` mapping — so the mapping only needs to handle uppercase variations, reducing the number of conditions needed.

---

## 🚀 How to Use

1. Import `messy_products.csv` first
2. Import `messy_transactions.csv` second
3. Run `data_cleaning.sql` in MySQL Workbench or any MySQL client
4. Verify results with the final `SELECT` checks at the bottom of the script

```sql
-- Final verification
SELECT * FROM products LIMIT 10;
SELECT * FROM transactions LIMIT 10;
```

---

## 📌 Tools Used
- **MySQL** — Query language and data cleaning
- **MySQL Workbench** — SQL editor and database management

---

## 👤 Author
**Christian Kho Aler**
Aspiring Data Analyst
