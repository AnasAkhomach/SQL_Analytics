SET SQL_SAFE_UPDATES = 0;

-- ============================================
-- File: update_created_at_by_2_years.sql
-- Description: This script updates the 'created_at' columns by adding 2 years.
--              - For the website_pageviews table, updates are run in 3 batches.
--              - For products, orders, and order_items, a single update is run.
-- NOTE: Make sure to back up your data before running these updates.
-- ============================================

/* ============================================
   0. Update website_sessions
   ============================================ */

UPDATE website_sessions
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR);

/* ============================================
   1. Update website_pageviews in 3 batches
   ============================================ */

-- Batch 1: Update rows where website_pageview_id mod 3 equals 0
UPDATE website_pageviews
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR)
WHERE MOD(website_pageview_id, 3) = 0;

-- Batch 2: Update rows where website_pageview_id mod 3 equals 1
UPDATE website_pageviews
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR)
WHERE MOD(website_pageview_id, 3) = 1;

-- Batch 3: Update rows where website_pageview_id mod 3 equals 2
UPDATE website_pageviews
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR)
WHERE MOD(website_pageview_id, 3) = 2;


/* ============================================
   2. Update products table (single batch)
   ============================================ */

UPDATE products
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR);


/* ============================================
   3. Update orders table (single batch)
   ============================================ */

UPDATE orders
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR);


/* ============================================
   4. Update order_items table (single batch)
   ============================================ */

UPDATE order_items
SET created_at = DATE_ADD(created_at, INTERVAL 2 YEAR);


SET SQL_SAFE_UPDATES = 1;
