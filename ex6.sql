
select * from orders;
select * from products;
select * from order_items;
select * from order_item_refunds;
select * from website_sessions limit 2000;
select * from website_pageviews limit 2000;

select
	website_sessions.utm_content,
    count(distinct website_sessions.website_session_id),
    count(distinct orders.order_id)
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by 1
order by 2 desc;

select
/*
	utm_source,
    utm_campaign,
    http_referer,
*/
    count(website_sessions.website_session_id) as sessions,
    count(order_id) as orders,
    (count(order_id) / count(website_sessions.website_session_id)) * 100 as cvr
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-04-14'
	and utm_source = 'gsearch'
    and utm_campaign = 'nonbrand'
group by utm_source, utm_source, http_referer;
-- 08 ===================================================================

select 
count(distinct diwebsite_session_id) as sessions,
created_at,
year(created_at) as years,
month(created_at) as months,
week(created_at) as weeks,
day(created_at) as days
from website_sessions
where website_session_id between  10000 and 60000
group by 5;

select 
    primary_product_id,
    items_purchased,
    created_at,
    count(order_id)
from orders
where order_id between 31000 and 32000
group by items_purchased;

select 
	-- order_id,
    primary_product_id,
    -- items_purchased,
    -- count(case when primary_product_id = 1 then order_id else null end) as count_of_product_1,
    -- count(case when primary_product_id = 2 then order_id else null end) as count_of_product_2,
    -- count(case when primary_product_id = 3 then order_id else null end) as count_of_product_3,
    -- count(case when primary_product_id = 4 then order_id else null end) as count_of_product_4
    -- count(order_id)
    count(case when items_purchased = 1 then order_id else null end) as count_of_product_1,
    count(case when items_purchased = 2 then order_id else null end) as count_of_product_2
from orders
where order_id between 30000 and 32000
group by 1;

-- this query cant be more wrong!!
/*
select 
	-- created_at,
    min(week(created_at)),
    -- utm_source,
    -- utm_campaign,
    count(case when utm_content = 'gsearch' and utm_campaign = 'nonbrand' then website_session_id else null end) as sessions
from website_sessions
where created_at between '2012-04-15' and '2012-05-10'
group by week(created_at)
*/
-- this is the solution!
SELECT
	-- YEAR(created_at) AS yr,  -- i don't quit understand why he did not add months
    -- WEEK(created_at) AS wk,   -- he commened this line when hw created the min clomn, and the result os the same enen when i did not incude the year in the group by
    MIN(DATE(created_at)) AS week_started_at,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions 
WHERE created_at < '2012-05-12' -- the solution start with the where condition, this is the precaution!!
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at); -- what i understand here is he want the number of sessions for every week in each year!    
			-- since we are limiting the search result to only the dates < 12-05-2012 i thin we can drop the year column!
 -- 10 =====================================================================
 
 SELECT 
	website_sessions.device_type,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders, 
    (COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id)) * 100 AS CVR
 FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
 WHERE website_sessions.created_at < '2012-05-11' -- WTF! the error was related the date string, instead of 2012-05-11 i wrote 2010-05-11
	 AND utm_source = 'gsearch'
	 AND utm_campaign = 'nonbrand'
GROUP BY 1;
-- 12 ==============================================================

SELECT
	-- WEEK(created_at) AS wk,
    -- YEAR(created_at) AS yr,
    MIN(DATE(created_at)) AS week_start_year,
    COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions, -- just in case remmenber to always use count distinct!!
    COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions
FROM website_sessions
-- WHERE created_at  BETWEEN '2012-04-15' AND '2012-06-09'
WHERE created_at < '2012-06-09' AND created_at > '2012-04-15'
GROUP BY WEEK(created_at) ,YEAR(created_at);









