select
	min(date(created_at)),
	-- yearweek(created_at) as yrwk,
    count(case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions,
    count(case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions
from website_sessions
where created_at between '2012-08-22' and '2012-11-29'
	and utm_campaign = 'nonbrand'
group by yearweek(created_at) 