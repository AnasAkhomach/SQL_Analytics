	-- so the fist time the '/lander-1' was viewed was at 2012-06-19 00:35:54, with this pageview_id: 23504
    -- to compete this request we need to:
    -- STEP 1: find the first website_pageview_id for the relevant sessions
    
SELECT 
	website_pageview_id,
	created_at,
    pageview_url
FROM website_pageviews
WHERE created_at < '2012-06-28' AND pageview_url = '/lander-1'
ORDER BY created_at ASC
LIMIT 1;
    -- STEP 2: identify the landing page of each session tha came after the session that have the the pageview_id = 23504
    -- by definition the landing page is the first page visited in a session
DROP TEMPORARY TABLE IF EXISTS first_pv;
CREATE TEMPORARY TABLE first_pv
SELECT
website_sessions.website_session_id,
MIN(website_pageviews.website_pageview_id) AS landing_page_id
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id  
        AND website_sessions.created_at < '2012-06-28'
        AND website_pageviews.website_pageview_id > 23504
        AND website_pageviews.pageview_url IN ('/home', '/lander-1')
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
WHERE website_sessions.website_session_id IS NOT NULL
GROUP BY 1;
SELECT * FROM first_pv; -- QA
    -- STEP 3a: count the pageviews for each session.
DROP TEMPORARY TABLE IF EXISTS landing_page_url;
CREATE TEMPORARY TABLE landing_page_url
SELECT 
website_pageviews.website_session_id,
first_pv.landing_page_id,
website_pageviews.pageview_url
FROM first_pv
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pv.landing_page_id;
 SELECT * FROM landing_page_url;
    -- STEP 3b: limit the count to the sessions that have only 1 pageview

DROP TEMPORARY TABLE IF EXISTS bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
website_pageviews.website_session_id,
landing_page_url.pageview_url,
COUNT(website_pageviews.website_pageview_id) AS count_pv
FROM landing_page_url
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = landing_page_url.website_session_id
GROUP BY 1,2
HAVING count_pv = 1;
SELECT * FROM bounced_sessions; -- QA test
    -- the landing_page_id is basically a website_pageviw_id plus the condition (first page this session)
    -- STEP 4: summerize! bounce_rate = count(bonced_sessions) / count(total_sessions)