select
	year(created_at) as yr,
    month(created_at) as mo,
    count(order_id) as sales,
    sum(price_usd) as total_revenue,
    sum(price_usd - cogs_usd) as total_margin
from orders
where created_at < '2013-01-04'
group by 1, 2;

select
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id) / count(website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd) / count(website_sessions.website_session_id) as revenue_per_session,
    count(case when orders.primary_product_id = 1 then orders.order_id else null end) as product_1_orders,
    count(case when orders.primary_product_id = 2 then orders.order_id else null end) as product_2_orders
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-04-01' and website_sessions.created_at < '2013-04-05'
group by 1, 2;