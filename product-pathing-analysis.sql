select distinct
	pageview_url
from website_pageviews
where created_at between '2013-02-01' and '2013-03-01';
	-- we are looking for the /products page, we are loking for sessions that goes to /the-original-mr-fuzzy or /the-forever-love-bear

select
	website_session_id,
	pageview_url
from website_pageviews
where created_at between '2013-02-01' and '2013-03-01'
	and pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear');
	-- just to get a good idea we will see how many sessions ended up in each product page

select
	count(website_session_id) as sessions,
	pageview_url
from website_pageviews
where created_at between '2013-02-01' and '2013-03-01'
	and pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear')
group by 2;
	-- now we join to the orders table to see which sessions ended up with an order
    
select
	website_pageviews.pageview_url,
	count(website_pageviews.website_session_id) as sessions,
    count(orders.order_id) as orders,
    count(orders.order_id) / count(website_pageviews.website_session_id)  as viewed_product_to_order_rate
from website_pageviews
	left join orders
		on orders.website_session_id = website_pageviews.website_session_id
where website_pageviews.created_at between '2013-02-01' and '2013-03-01'
	and website_pageviews.pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear')
group by 1;
	-- interstingly the new product converge better 
-- let us look at sessions which hit the /products and see where they went next , also the time period is between 2012-10-06 and 2013-04-06 divided into 2 periods (pre and post product launch)
-- STEP 1: find relevant '/products' pageviews with website_session_id
create temporary table products_pageviews
select
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.pageview_url,
    website_sessions.created_at,
    case when website_sessions.created_at < '2013-01-06' then 'A. Pre_Product_2'
		 when website_sessions.created_at > '2013-01-06' then 'B. Post_Product_2'
         else 'check logic'
         end time_period
from website_sessions
	left join website_pageviews
		on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-10-06'
	and website_sessions.created_at < '2013-04-01'
    and website_pageviews.pageview_url = '/products';
    
select * from products_pageviews; 	-- QA Test
-- STEP 2: find the next pageview_id that occurs AFTER the product pageview

create temporary table sessions_with_next_pv
select
	products_pageviews.website_session_id,
    -- products_pageviews.created_at,
    products_pageviews.time_period,
    -- website_pageviews.pageview_url
    min(website_pageviews.website_pageview_id) as min_next_pv
from products_pageviews
	left join website_pageviews
		on website_pageviews.website_session_id = products_pageviews.website_session_id
        and website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
group by 1,2;

select * from sessions_with_next_pv; 	-- QA Test

-- STEP 3: find the pageview_url associated with any applicable next pageview_id
create temporary table sessions_with_next_pv_url
select
	sessions_with_next_pv.website_session_id,
    sessions_with_next_pv.time_period,
    website_pageviews.pageview_url as next_pv_url
from sessions_with_next_pv
	left join website_pageviews
		on website_pageviews.website_pageview_id = sessions_with_next_pv.min_next_pv;
        
select * from sessions_with_next_pv_url; 	-- QA Test
-- STEP 4: summarize the data and analyse the PRE vs the POST periods

select
	time_period,
    count(distinct website_session_id) as sessions,
    count(distinct case when next_pv_url is not null then website_session_id else null end) as not_bounced,
    count(distinct case when next_pv_url = '/the-original-mr-fuzzy' then website_session_id else null end) as to_mr_fuzzy,
    count(distinct case when next_pv_url = '/the-forever-love-bear' then website_session_id else null end) as to_love_bear 
from sessions_with_next_pv_url
group by 1;


