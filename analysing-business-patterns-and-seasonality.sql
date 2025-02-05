select
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    week(website_sessions.created_at) as wk,
	count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2013-01-01'
group by 1, 2, 3;

select
	hour(created_at) as hr,
    round(count(distinct case when day(created_at) = 0 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1) as mon,
    round(count(distinct case when day(created_at) = 1 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1) as tue,
    round(count(distinct case when day(created_at) = 2 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1) as wed,
    round(count(distinct case when day(created_at) = 3 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1)as thu,
    round(count(distinct case when day(created_at) = 4 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1) as fri,
    round(count(distinct case when day(created_at) = 5 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1) as sat,
    round(count(distinct case when day(created_at) = 6 then website_session_id else null end) / COUNT(DISTINCT DATE(created_at)), 1) as sun,
	count(website_session_id) as sessions
from website_sessions
where created_at > '2012-09-15' and created_at < '2012-11-15'
group by 1;

SELECT 
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS weekday,  -- Monday = 0, Sunday = 6 (for MySQL)
    round(COUNT(DISTINCT website_session_id) / COUNT(DISTINCT DATE(created_at)), 1) AS avg_sessions
FROM website_sessions
WHERE created_at >= '2012-09-15' AND created_at < '2012-11-15'
GROUP BY hr, weekday
ORDER BY hr, weekday;
