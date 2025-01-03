USE mavenfuzzyfactory;
-- SELECT * FROM website_pageviews LIMIT 2000;
SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1
ORDER BY 2 DESC;
-- ===========================================

DROP TEMPORARY TABLE if exists first_page_view;
CREATE TEMPORARY TABLE first_page_view
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;
SELECT
	first_page_view.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_page_view
	LEFT JOIN website_pageviews
		ON first_page_view.min_pv_id = website_pageviews.website_pageview_id;

-- 03 ====================================================================

SELECT 
	pageview_url,
	COUNT(DISTINCT website_pageview_id) as pvs
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC;
-- 05 ====================================================================
DROP TEMPORARY TABLE IF EXISTS first_page_view_by_session;
CREATE TEMPORARY TABLE first_page_view_by_session
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv_this_session_id
FROM website_pageviews 
WHERE created_at < '2012-06-12'
GROUP BY 1;

SELECT
	COUNT(first_page_view_by_session.website_session_id) AS sessions,
    website_pageviews.pageview_url
FROM first_page_view_by_session
	LEFT JOIN website_pageviews
		ON first_page_view_by_session.first_pv_this_session_id = website_pageviews.website_pageview_id
GROUP BY 2




