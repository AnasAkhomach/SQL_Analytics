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