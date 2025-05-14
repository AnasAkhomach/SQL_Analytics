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
    
DROP TEMPORARY TABLE IF EXISTS first_pv; -- he named tha table 'first_test_pv'
CREATE TEMPORARY TABLE first_pv
SELECT
website_sessions.website_session_id,
MIN(website_pageviews.website_pageview_id) AS landing_page_id 
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id  
        AND website_sessions.created_at < '2012-06-28'
        AND website_pageviews.website_pageview_id > 23504
        -- AND website_pageviews.pageview_url IN ('/home', '/lander-1')
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
WHERE website_sessions.website_session_id IS NOT NULL
GROUP BY 1;

SELECT * FROM first_pv; -- QA
    -- STEP 3a: count the pageviews for each session.
    
DROP TEMPORARY TABLE IF EXISTS nonbrand_test_w_lp;	-- renamed 'landing_page_url' to nonbrand_test_w_lp
CREATE TEMPORARY TABLE nonbrand_test_w_lp
SELECT 
	-- website_pageviews.website_session_id,	-- this was not the correct column 'website_pageviews.website_session_id'
first_pv.website_session_id,
	-- first_pv.landing_page_id,
website_pageviews.pageview_url AS l_p_correction_version
FROM first_pv
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pv.landing_page_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');
     
 SELECT * FROM nonbrand_test_w_lp;
    -- STEP 3b: limit the count to the sessions that have only 1 pageview

DROP TEMPORARY TABLE IF EXISTS nonbrand_test_baounced;	-- renamed this 'bounced_sessions' to nonbrand_test_baounced 
CREATE TEMPORARY TABLE nonbrand_test_baounced
SELECT 
	-- website_pageviews.website_session_id,	-- this is what i couldn't get wright
	-- landing_page_url.pageview_url,			-- this is what i couldn't get wright
nonbrand_test_w_lp.website_session_id,
nonbrand_test_w_lp.l_p_correction_version,
COUNT(website_pageviews.website_pageview_id) AS count_pv
FROM nonbrand_test_w_lp
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = nonbrand_test_w_lp.website_session_id
GROUP BY 1,2
HAVING count_pv = 1;
SELECT * FROM nonbrand_test_baounced; -- QA test

    -- the landing_page_id is basically a website_pageviw_id plus the condition (first page this session)
    -- STEP 4: summerize! bounce_rate = count(bonced_sessions) / count(total_sessions)

SELECT 
	nonbrand_test_w_lp.l_p_correction_version,
	COUNT(DISTINCT nonbrand_test_w_lp.website_session_id) AS t_sessions,
    COUNT(DISTINCT nonbrand_test_baounced.website_session_id) AS bounced_sessions,
    (COUNT(DISTINCT nonbrand_test_baounced.website_session_id) / COUNT(DISTINCT nonbrand_test_w_lp.website_session_id)) * 100 AS bounce_rate
FROM nonbrand_test_w_lp
	LEFT JOIN nonbrand_test_baounced
		ON nonbrand_test_baounced.website_session_id = nonbrand_test_w_lp.website_session_id	
GROUP BY 1