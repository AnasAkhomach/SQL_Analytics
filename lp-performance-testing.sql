	-- Calculate the bounce rate
	-- STEP 1: count of sesseions with landing page (now that i look at this, this is stupid, basically each session must land on a page)
		-- STEP 1.1: query the sessions within the desired date, to get the session_id
			-- something to notice the number of records returned when counting the sessions from the website_pageviews 
            -- is way bigger than the number of records from the website_sessions
            -- that abvious bur i was stupid for not noticing that a single session can have many page views
        -- STEP 1.2: use the MIN(paggeview_id) of these pageviews based on session_id in both tables (session_id:1 --> M:pageview_id)
        -- STEP 1.3: use MIN(pageview_id) == landingpage_id that means the url(MIN(pageview_id)) == landingpage_url		-- we have here a pageview_id that can refer to a session_id
        -- STEP 1.4: group by session_id and count how many pageviews we have for each session_id
        -- STEP 1.5: filter the sessions to only the ones that have on one count of pageviews
create temporary table sessions_with_landingpage_id
select
	website_sessions.website_session_id,
    website_sessions.created_at,
    min(website_pageviews.website_pageview_id) as landingpage_id
from website_sessions
	left join website_pageviews
		on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-06-14'
group by 1;

select * from sessions_with_landingpage_id;		-- card(sessions_with_landingpage_id) = card(website_sessions) = 11048 < card(website_pageviews) = 22209

create temporary table sessions_with_landingpage_id_and_landingpage_url
select
	sessions_with_landingpage_id.website_session_id,
    sessions_with_landingpage_id.landingpage_id,
	website_pageviews.pageview_url
from sessions_with_landingpage_id
	left join website_pageviews
		on website_pageviews.website_session_id = sessions_with_landingpage_id.website_session_id;
        
select * from sessions_with_landingpage_id_and_landingpage_url; 	-- card(sessions_with_landingpage_id_and_landingpage_url) = card(website_pageviews) = 22209
-- nooop

    
    
