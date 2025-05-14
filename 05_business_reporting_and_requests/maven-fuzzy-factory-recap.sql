/*
Site Traffic Breakdown (Cindy Sharp)
Date: April 12, 2012
Task: Analyze website sessions up to April 12, 2012, and break down traffic sources by utm_source, utm_campaign, and http_referer.
*/
USE mavenfuzzyfactory;

SELECT
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY
    utm_source,
    utm_campaign,
    http_referer
ORDER BY
    sessions DESC;
/*
Gsearch Nonbrand Conversion Rate (Tom Parmesan)
Date: April 14, 2012
Task: Calculate the conversion rate (CVR) for gsearch nonbrand traffic to determine if sessions drive orders.
*/

SELECT  
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,  
    COUNT(DISTINCT orders.order_id) AS orders,  
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100 AS conversion_rate  
FROM website_sessions  
LEFT JOIN orders  
    ON orders.website_session_id = website_sessions.website_session_id  
WHERE website_sessions.created_at <= '2012-04-14'  
    AND utm_source = 'gsearch'  
    AND utm_campaign = 'nonbrand';  
    
/*
search Nonbrand Weekly Volume Trends (Tom Parmesan)
Date: May 10, 2012
Task: Analyze weekly session volume trends for gsearch nonbrand traffic to assess bid adjustments.
*/
USE mavenfuzzyfactory;

SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
    YEARWEEK(created_at)
ORDER BY
    week_start_date;

/*
Device-Level Conversion Rates (Tom Parmesan)
Date: May 11, 2012
Task: Compare desktop vs. mobile conversion rates for gsearch nonbrand traffic.
*/
SELECT
    website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100 AS conversion_rate
FROM website_sessions
LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
    website_sessions.device_type;
    
/*
Gsearch Device-Level Weekly Trends (Tom Parmesan)
Date: June 9, 2012
Task: Analyze weekly desktop/mobile session trends after bidding adjustments.
*/

SELECT 
    YEARWEEK(created_at) AS year_week,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id END) AS mob_sessions
FROM website_sessions 
WHERE 
    created_at < '2012-06-09' 
    AND created_at > '2012-04-15' 
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
    YEARWEEK(created_at)
ORDER BY 
    week_start_date;

/*
Top Website Pages (Morgan Rockwell)
Date: June 9, 2012
Task: Identify most-viewed website pages by session volume.
*/

SELECT
    pageview_url,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY
    pageview_url
ORDER BY
    sessions DESC;

/*
Top Entry Pages (Morgan Rockwell)
Date: June 12, 2012
Task: Identify entry pages (first page viewed in sessions) ranked by entry volume.
*/

-- Step 1: Identify first pageview per session
CREATE TEMPORARY TABLE first_pageviews
SELECT
    website_session_id,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

-- Step 2: Count entry pages
SELECT
    website_pageviews.pageview_url AS landing_page,
    COUNT(first_pageviews.website_session_id) AS entry_volume
FROM first_pageviews
LEFT JOIN website_pageviews
    ON first_pageviews.first_pageview_id = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url
ORDER BY entry_volume DESC;

/*
Bounce Rate Analysis for Homepage
Date: June 14, 2012
From: Morgan Rockwell (Website Manager)
Objective: Calculate bounce rates for homepage sessions (sessions, bounced sessions, bounce rate).
*/

-- Step 1: Identify first pageview for each session
CREATE TEMPORARY TABLE first_pageviews
SELECT
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_sessions
LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-06-14'
GROUP BY website_sessions.website_session_id;

-- Step 2: Map first pageview to its URL (landing page)
CREATE TEMPORARY TABLE sessions_with_landing_page
SELECT
    fp.website_session_id,
    wp.pageview_url AS landing_page
FROM first_pageviews fp
LEFT JOIN website_pageviews wp
    ON fp.first_pv_id = wp.website_pageview_id;

-- Step 3: Filter for homepage and count total sessions/bounced sessions
SELECT
    landing_page,
    COUNT(swlp.website_session_id) AS total_sessions,
    COUNT(CASE WHEN wp_count = 1 THEN swlp.website_session_id ELSE NULL END) AS bounced_sessions,
    (COUNT(CASE WHEN wp_count = 1 THEN swlp.website_session_id ELSE NULL END) / COUNT(swlp.website_session_id)) * 100 AS bounce_rate
FROM (
    SELECT
        swlp.website_session_id,
        swlp.landing_page,
        COUNT(wp.website_pageview_id) AS wp_count
    FROM sessions_with_landing_page swlp
    LEFT JOIN website_pageviews wp
        ON swlp.website_session_id = wp.website_session_id
    WHERE swlp.landing_page = '/home'
    GROUP BY swlp.website_session_id, swlp.landing_page
) AS session_counts
GROUP BY landing_page;
/*
Landing Page Test Analysis (Home vs. Lander-1)
Date: July 28, 2012
From: Morgan Rockwell
Objective: Compare bounce rates for /home and /lander-1 after a 50/50 test.
*/
USE mavenfuzzyfactory;

-- Step 1: Find the launch date of '/lander-1'
SELECT 
    MIN(created_at) AS lander_launch_date,
    MIN(website_pageview_id) AS first_lander_pv_id
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- Step 2: Identify sessions and their first pageview after lander-1 launch
CREATE TEMPORARY TABLE first_test_pv
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_pageviews
INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at < '2012-07-28'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
WHERE website_pageviews.website_pageview_id >= 23504
GROUP BY website_sessions.website_session_id;

-- Step 3: Map sessions to their landing page (home or lander-1)
CREATE TEMPORARY TABLE sessions_with_landing_page
SELECT 
    fp.website_session_id,
    wp.pageview_url AS landing_page
FROM first_test_pv fp
LEFT JOIN website_pageviews wp
    ON fp.first_pv_id = wp.website_pageview_id
WHERE wp.pageview_url IN ('/home', '/lander-1');

-- Step 4: Calculate bounce rates
SELECT 
    swlp.landing_page,
    COUNT(DISTINCT swlp.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN pv_count = 1 THEN bs.website_session_id END) AS bounced_sessions,
    (COUNT(DISTINCT CASE WHEN pv_count = 1 THEN bs.website_session_id END) / COUNT(DISTINCT swlp.website_session_id)) * 100 AS bounce_rate
FROM sessions_with_landing_page swlp
LEFT JOIN (
    SELECT
        website_session_id,
        COUNT(website_pageview_id) AS pv_count
    FROM website_pageviews
    GROUP BY website_session_id
) AS bs ON swlp.website_session_id = bs.website_session_id
GROUP BY swlp.landing_page;
/*
Landing Page Trend Analysis
Date: August 31, 2012
From: Morgan Rockwell
Objective: Analyze weekly trends for /home and /lander-1 traffic and overall bounce rate.
*/

USE mavenfuzzyfactory;

-- Step 1: Identify sessions with first pageview and total pageviews
CREATE TEMPORARY TABLE sessions_with_pv_data
SELECT
    ws.website_session_id,
    MIN(wp.website_pageview_id) AS first_pv_id,
    COUNT(wp.website_pageview_id) AS pv_count
FROM website_sessions ws
LEFT JOIN website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2012-06-01' AND '2012-08-31'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY ws.website_session_id;

-- Step 2: Aggregate weekly trends
SELECT
    MIN(DATE(session_created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id END) AS lander_sessions,
    (COUNT(DISTINCT CASE WHEN pv_count = 1 THEN website_session_id END) / COUNT(DISTINCT website_session_id)) * 100 AS bounce_rate
FROM sessions_with_landing_page
GROUP BY YEARWEEK(session_created_at)
ORDER BY week_start_date;

/*
Conversion Funnel Analysis
Date: September 5, 2012
From: Morgan Rockwell
Objective: Analyze user drop-offs from /lander-1 to the thank-you page.
*/
USE mavenfuzzyfactory;

-- Step 1: Flag funnel steps for each session
CREATE TEMPORARY TABLE session_made_it_flags
SELECT
    website_session_id,
    MAX(lander_page) AS made_it_to_lander,
    MAX(products_page) AS made_it_to_products,
    MAX(mrfuzzy_page) AS made_it_to_mrfuzzy,
    MAX(cart_page) AS made_it_to_cart,
    MAX(shipping_page) AS made_it_to_shipping,
    MAX(billing_page) AS made_it_to_billing,
    MAX(thank_you_page) AS made_it_to_thank_you
FROM (
    SELECT
        ws.website_session_id,
        CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
        CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
        CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
        CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
        CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
        CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
        CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
    FROM website_sessions ws
    LEFT JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
) AS pageview_level
GROUP BY 1;

-- Step 2: Calculate conversion rates
SELECT
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN made_it_to_products = 1 THEN website_session_id END) AS to_products,
    COUNT(DISTINCT CASE WHEN made_it_to_mrfuzzy = 1 THEN website_session_id END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN made_it_to_cart = 1 THEN website_session_id END) AS to_cart,
    COUNT(DISTINCT CASE WHEN made_it_to_thank_you = 1 THEN website_session_id END) AS to_thank_you,
    COUNT(DISTINCT CASE WHEN made_it_to_products = 1 THEN website_session_id END) / 
    COUNT(DISTINCT CASE WHEN made_it_to_lander = 1 THEN website_session_id END) * 100 AS lander_to_product_ctr
FROM session_made_it_flags;

/*
Billing Page Test Analysis
Date: November 10, 2012
From: Morgan Rockwell
Objective: Compare conversion rates of /billing vs. /billing-2.
*/

USE mavenfuzzyfactory;

-- Step 1: Identify test start
SELECT 
    MIN(created_at) AS billing2_launch_date,
    MIN(website_pageview_id) AS first_billing2_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';

-- Step 2: Calculate conversion rates
SELECT
    billing_version_seen,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    (COUNT(DISTINCT o.order_id) / COUNT(DISTINCT wp.website_session_id)) * 100 AS billing_to_order_rate
FROM (
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_billing_pv_id,
        pageview_url AS billing_version_seen
    FROM website_pageviews
    WHERE 
        website_pageview_id >= 53590
        AND created_at < '2012-11-10'
        AND pageview_url IN ('/billing', '/billing-2')
    GROUP BY website_session_id
) AS billing_sessions
LEFT JOIN website_pageviews wp
    ON billing_sessions.first_billing_pv_id = wp.website_pageview_id
LEFT JOIN orders o
    ON billing_sessions.website_session_id = o.website_session_id
GROUP BY billing_version_seen;