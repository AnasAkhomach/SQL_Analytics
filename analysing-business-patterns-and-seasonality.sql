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
group by 1; -- this is not the required query, the result is not correct

SELECT 
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS weekday,  -- Monday = 0, Sunday = 6 (for MySQL)
    round(COUNT(DISTINCT website_session_id) / COUNT(DISTINCT DATE(created_at)), 1) AS avg_sessions
FROM website_sessions
WHERE created_at >= '2012-09-15' AND created_at < '2012-11-15'
GROUP BY hr, weekday
ORDER BY hr, weekday; -- this is not the required format, the result is somehow correct


SELECT
    hr,
    ROUND(mon / 8, 1) AS mon_avg, 
    ROUND(tue / 8, 1) AS tue_avg, 
    ROUND(wed / 8, 1) AS wed_avg, 
    ROUND(thu / 8, 1) AS thu_avg, 
    ROUND(fri / 8, 1) AS fri_avg, 
    ROUND(sat / 8, 1) AS sat_avg, 
    ROUND(sun / 8, 1) AS sun_avg
FROM (
    SELECT 
        HOUR(created_at) AS hr,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN website_session_id ELSE NULL END) AS mon,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 1 THEN website_session_id ELSE NULL END) AS tue,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 2 THEN website_session_id ELSE NULL END) AS wed,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 3 THEN website_session_id ELSE NULL END) AS thu,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 4 THEN website_session_id ELSE NULL END) AS fri,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 5 THEN website_session_id ELSE NULL END) AS sat,
        COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 6 THEN website_session_id ELSE NULL END) AS sun
    FROM website_sessions
    WHERE created_at >= '2012-09-15' AND created_at < '2012-11-15'
    GROUP BY hr
) sub_query
GROUP BY hr
ORDER BY hr;

