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
    -- AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
    AND website_sessions.created_at < '2012-06-14'
GROUP BY 1;

SELECT  * FROM first_pageviews_demo; -- QA testing, what is returned is the first page viewed by session (each session!)
-- STEP 1: find the first websit_pageview_id for relevant sessions >>> [DONE]
-- now we need to bring in the landing page to each session
-- we have alredy find the id of the first page visited each session, now we fetch it's URL
DROP TEMPORARY TABLE IF EXISTS sessions_w_lp_url;
CREATE TEMPORARY TABLE sessions_w_lp_url
SELECT 
    first_pageviews_demo.website_session_id, -- Include session ID here
    first_pageviews_demo.min_pv_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pv_id;
        
SELECT  * FROM sessions_w_lp_url; 
-- QA testing, this table returns the result of the previous query plus the URL column
-- STEP 2: Identify the landing page for each session >>> [DONE]
-- next, we make a table to include a count of pageviews per session
-- the previous table has unique sessions, we need to count for each session the nomber of page viewed
-- so we need to join the previous table with the website_sessions on what? <<website_sessions_id>> and group by it

DROP TEMPORARY TABLE IF EXISTS bounced_sessions_only;
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
    sessions_w_lp_url.website_session_id,
    sessions_w_lp_url.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pv
FROM sessions_w_lp_url
LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id = sessions_w_lp_url.website_session_id
GROUP BY 1, 2
-- STEP 3: Counting pageviews for each session, to identify "bounce". >>> (done)
-- then we filter the resutl to the session that only have on page view
HAVING COUNT(website_pageviews.website_pageview_id) = 1;
-- STEP 3: Counting pageviews for each session, to identify "bounce". >>> [DONE]

SELECT  * FROM bounced_sessions_only; -- QA testing

SELECT
	sessions_w_lp_url.landing_page,
    sessions_w_lp_url.website_session_id,
    bounced_sessions_only.website_session_id AS bounced_website_session
FROM sessions_w_lp_url
	LEFT JOIN bounced_sessions_only
		ON sessions_w_lp_url.website_session_id = bounced_sessions_only.website_session_id
ORDER BY sessions_w_lp_url.website_session_id;

 -- final output
	-- we need to count the records and add abounced column 
    -- we need to group by landing page
SELECT
	sessions_w_lp_url.landing_page,
    COUNT(sessions_w_lp_url.website_session_id) AS sessions_count,
    COUNT(bounced_sessions_only.website_session_id) AS bounced_session,
    (COUNT(bounced_sessions_only.website_session_id) / COUNT(sessions_w_lp_url.website_session_id)) * 100 AS bounce_rate
FROM sessions_w_lp_url
	LEFT JOIN bounced_sessions_only
		ON sessions_w_lp_url.website_session_id = bounced_sessions_only.website_session_id
GROUP BY 1
ORDER BY 4 DESC;