select
	year(created_at) as yr,
    month(created_at) as mo,
    count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as nonbrand,
    count(distinct case when utm_campaign = 'brand' then website_session_id else null end) as brand,
    count(distinct case when utm_campaign = 'brand' then website_session_id else null end) * 100 / count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as p1,
    count(distinct case when utm_campaign is null then website_session_id else null end) as direct,
    count(distinct case when utm_campaign is null then website_session_id else null end) * 100 / count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as p2,
    count(distinct case when utm_campaign is null and http_referer is null then website_session_id else null end) as organic,
    count(distinct case when utm_campaign is null and http_referer is null then website_session_id else null end) * 100 / count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as p3
from website_sessions
where created_at < '2012-12-23'
group by 1, 2;

