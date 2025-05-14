	-- STEP 1: finding the first website_pageview_id for the relevant sessions! (date)
    -- STEP 2: identifying the landing_page of each session (easy!)
    -- STEP 3: counting the pageviews for each session, to identify "bounce" (Why?)
    -- STEP 4: summarizing by week (bounce rate, sessions to each lander)
    
create temporary table s_with_first_pv_and_pv_count
select
	website_sessions.website_session_id,
	min(website_pageviews.website_pageview_id) as first_pv,
    count(website_pageviews.website_pageview_id) as pv_count
From website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-06-01'
	and website_sessions.created_at < '2012-08-31'
    and website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
group by 1
;
select * from s_with_first_pv_and_pv_count; 	-- QA Test : "11624 row"

create temporary table s_with_pv_count_landing_page_created_at
select
	s_with_first_pv_and_pv_count.website_session_id,
    s_with_first_pv_and_pv_count.first_pv,
    s_with_first_pv_and_pv_count.pv_count,
    website_pageviews.pageview_url as landing_page,
    website_pageviews.created_at as session_created_at
from s_with_first_pv_and_pv_count
	left join website_pageviews
		on website_pageviews.website_session_id = s_with_first_pv_and_pv_count.website_session_id
;
select * from s_with_pv_count_landing_page_created_at; 	-- QA Test : "24935 row" 

select
	min(date(session_created_at)) as week_stat_date,
    -- count(distinct website_session_id) as total_sessions,
    -- count(distinct case when pv_count = 1 then website_session_id else null end) as bounced_sessions,
    (count(distinct case when pv_count = 1 then website_session_id else null end) / count(distinct website_session_id)) * 100 as bounce_rate, 
    count(distinct case when landing_page = '/home' then website_session_id else null end) as home_sessions,
    count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_1_sessions
from s_with_pv_count_landing_page_created_at
group by yearweek(session_created_at)