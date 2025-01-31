/*
MID COURSE PROJECT QUESTIONS 
	 	
	Question 7: For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to orders. 
    You can use the same time period you analyzed last time (Jun 19-Jul 28). 

	Question 8: I'd love for you to quantify the impact of our billing test, as well. 
    Please analyze the lift generated from the test (Sep 10-Nov 10), in terms of revenue per billing page session, and then pull the number of billing
    page sessions 25:17 for the past month to understand monthly impact. 

*/

-- Question 1: Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase
-- the growth there? 

select
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as mo,
	count(distinct website_sessions.website_session_id) as sessions,
	count(distinct orders.order_id) as orders
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27'
group by 1, 2;

-- Question 2: Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately.
-- I am wondering if brand is picking up at all. If so, this is a good story to tell. 
select
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as mo,
	count(distinct website_sessions.website_session_id) as sessions,
	count(distinct orders.order_id) as orders,
    count(distinct case when website_sessions.utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as nonbrand_campaign,
    count(distinct case when website_sessions.utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_campaign
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27'
group by 1, 2;

-- Question 3: While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our
-- analytical muscles a little and show the board we really know our traffic sources.

select
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as mo,
	-- count(distinct website_sessions.website_session_id) as sessions,
	-- count(distinct orders.order_id) as orders,
    count(distinct case when website_sessions.device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop_sessions,
	count(distinct case when website_sessions.device_type = 'desktop' then orders.order_id else null end) as desktop_orders,
    count(distinct case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end) as moblie_sessions,
    count(distinct case when website_sessions.device_type = 'mobile' then orders.order_id else null end) as moblie_orders

from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27'
    and website_sessions.utm_campaign = 'nonbrand'
group by 1, 2;

-- Question 4: I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch.
-- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels? 

select
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as mo,
	-- count(distinct website_sessions.website_session_id) as sessions,
	-- count(distinct orders.order_id) as orders,
    count(distinct case when website_sessions.utm_source = 'gsearch' then website_sessions.website_session_id else null end) as gsearch_paid_session,
    count(distinct case when website_sessions.utm_source = 'bsearch' then website_sessions.website_session_id else null end) as bsearch_paid_session,
    count(distinct case when website_sessions.utm_source is null and website_sessions.http_referer is not null 
                        then website_sessions.website_session_id else null end) as organic_search_session,
                        
	count(distinct case when website_sessions.utm_source is null and website_sessions.http_referer is null 
                        then website_sessions.website_session_id else null end) as direct_type_in_session
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27'
group by 1, 2;

-- Question 5: I'd like to tell the story of our website performance improvements over the course of the first 8 months. 
-- Could you pull session to order conversion rates, by month? 
-- create temporary table sessions_and_orders_by_month
select
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as mo,
	count(distinct website_sessions.website_session_id) as sessions,
	count(distinct orders.order_id) as orders
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27'
group by 1, 2;

select
	yr, mo, sessions, orders,
    (orders / sessions)  * 100 as conversion_rate
from sessions_and_orders_by_month;

-- Question 6: For the gsearch lander test, please estimate the revenue that test earned us 
-- (Hint: Look at the increase in CVR from the test (Jun 19-Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value) 
