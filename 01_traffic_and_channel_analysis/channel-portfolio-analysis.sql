select
	min(date(created_at)),
	-- yearweek(created_at) as yrwk,
    count(case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions,
    count(case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions
from website_sessions
where created_at > '2012-08-22' 
	and created_at <'2012-11-29'
	and utm_campaign = 'nonbrand'
group by yearweek(created_at);

select
	utm_source,
	count(website_session_id) as sessions,
    count(case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
    count(case when device_type = 'mobile' then website_session_id else null end) / count(website_session_id) as pct_mobile
from website_sessions
where created_at > '2012-08-22'
	and created_at < '2012-11-30'
    and utm_campaign = 'nonbrand'
group by 1;

select
	website_sessions.device_type,
    website_sessions.utm_source,
    count( distinct website_sessions.website_session_id) as sessions,
    count( distinct orders.order_id) as orders,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at > '2012-08-22'
	and website_sessions.created_at < '2012-09-19'
    and utm_campaign = 'nonbrand'
group by 1, 2;

select
	--              yearweek(created_at) as yrwk,
	min(date(created_at)) as wk,
    count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as gsearch_desk_session,
    count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as gsearch_mob_session,
    count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as bsearch_desk_session,
    count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as bsearch_mob_session
from website_sessions
where created_at > '2012-11-04' 
	and created_at < '2012-12-22'
    and utm_campaign = 'nonbrand'
group by yearweek(created_at)
    