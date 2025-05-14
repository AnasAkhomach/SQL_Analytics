	-- STEP 0: finding the launch day of the new '/lander' 
    
select
*
from website_pageviews
where created_at is not null -- created_at < '2012-06-28' 
	and pageview_url = '/lander-1'
order by created_at asc
limit 1;

	-- the fisrt appearence of '/lander-1': website_pageview_id = '23504' 
    -- STEP 1: finding the fist website_pageview_id for the relevant sessions
drop table if exists first_test_pv;
create temporary table first_test_pv
select 
website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id,
count(website_pageviews.website_pageview_id) as count_pv
from website_pageviews
	inner join website_sessions
		on website_sessions.website_session_id = website_pageviews.website_session_id
        and website_sessions.created_at < '2012-07-28'
        and website_pageviews.website_pageview_id > '23504'
        and utm_source = 'gsearch'
        and utm_campaign = 'nonbrand'
	group by 1;

select * from first_test_pv;  	-- QA Test, we have a table with a column that contain the id of the fisrtpage in each session
    -- STEP 2: identify the landing page for each session
drop temporary table if exists test_session_with_lp;
create temporary table test_session_with_lp
select
first_test_pv.website_session_id,
first_test_pv.min_pv_id,
website_pageviews.pageview_url as landing_page,
first_test_pv.count_pv as pv_after_landing
from first_test_pv
	left join website_pageviews
		on website_pageviews.website_pageview_id = first_test_pv.min_pv_id
        and website_pageviews.pageview_url in ('/home', '/lander-1')
;

select * from test_session_with_lp; 	-- QA Test: this table contain more info "4576 row"

    -- STEP 3: counting pageviews for each session, to identify "bounce"
create temporary table test_bounced_sessions
select
	test_session_with_lp.website_session_id,
    test_session_with_lp.landing_page,
    count(website_pageviews.website_pageview_id) as pv_count
from test_session_with_lp
	left join website_pageviews
		on website_pageviews.website_session_id = test_session_with_lp.website_session_id
group by 1,2
having pv_count = 1
;
select * from test_bounced_sessions; 	-- QA Test: we have now a table with only the bounced sessions "2551 row"
    -- STEP 4: summarizing total sessions and bounced sessions, by LP
select
	test_session_with_lp.landing_page,
    count(distinct test_session_with_lp.website_session_id) as total_sessions,
    count(test_bounced_sessions.website_session_id) as bounced_sessions,
    count(test_bounced_sessions.website_session_id) / count(distinct test_session_with_lp.website_session_id) * 100 as bounce_rate
from test_session_with_lp
	left join test_bounced_sessions
		on test_bounced_sessions.website_session_id = test_session_with_lp.website_session_id
group by 1

    
/*
select 
website_pageviews.website_session_id,
website_pageviews.website_pageview_id,
website_pageviews.created_at,
website_pageviews.pageview_url
from website_pageviews
	inner join website_sessions
		on website_sessions.website_session_id = website_pageviews.website_session_id
        and website_sessions.created_at < '2012-07-28'
        and website_pageviews.website_pageview_id > '23504'
        and utm_source = 'gsearch'
        and utm_campaign = 'nonbrand'
;
*/