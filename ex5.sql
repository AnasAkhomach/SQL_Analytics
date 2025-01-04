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
GROUP BY 2;
-- 07 ======================================================================

-- I will try to comlete this without watching the video lesson
-- BUSINESS CONTEXT: we want to see landing page peformence for a certain time period.
-- STEP 1: find the first websit_pageview_id for relevant sessions.
-- STEP 2: Identify the landing page for each session.
-- STEP 3: Counting pageviews for each session, to identify "bounce".
-- STEP 4: Summarizing total sessions and bounce sessions by LP

-- STEP 1: find the first websit_pageview_id for relevant sessions.
-- finding the minimum wbsite pageview id assosiated with each session we care about
-- Create a temporary table using the same query!
DROP TEMPORARY TABLE IF EXISTS first_pageviews_demo;
CREATE TEMPORARY TABLE first_pageviews_demo
SELECT
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM website_pageviews
LEFT JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1;

SELECT  * FROM first_pageviews_demo; -- QA testing

-- now we need to bring in the landing page to each session 
DROP TEMPORARY TABLE IF EXISTS sessions_w_lp_demo;
CREATE TEMPORARY TABLE sessions_w_lp_demo
SELECT 
    first_pageviews_demo.website_session_id, -- Include session ID here
    first_pageviews_demo.min_pv_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pv_id;
        
SELECT  * FROM sessions_w_lp_demo; -- QA testing

-- next, we make a table to include a count of pageviews per session

DROP TEMPORARY TABLE IF EXISTS bounced_sessions_only;
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
    sessions_w_lp_demo.website_session_id,
    sessions_w_lp_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pv
FROM sessions_w_lp_demo
LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id = sessions_w_lp_demo.website_session_id
GROUP BY 1, 2
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

SELECT  * FROM bounced_sessions_only; -- QA testing

SELECT
	sessions_w_lp_demo.landing_page,
    sessions_w_lp_demo.website_session_id,
    bounced_sessions_only.website_session_id AS bounced_website_session
FROM sessions_w_lp_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_lp_demo.website_session_id = bounced_sessions_only.website_session_id
ORDER BY sessions_w_lp_demo.website_session_id;

 -- final output
	-- we need to count the records and add abounced column 
    -- we need to group by landing page
SELECT
	sessions_w_lp_demo.landing_page,
    COUNT(sessions_w_lp_demo.website_session_id) AS sessions_count,
    COUNT(bounced_sessions_only.website_session_id) AS bounced_session,
    (COUNT(bounced_sessions_only.website_session_id) / COUNT(sessions_w_lp_demo.website_session_id)) * 100 AS bounce_rate
FROM sessions_w_lp_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_lp_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY 1
ORDER BY 4 DESC;
-- 08 =========================================================================


