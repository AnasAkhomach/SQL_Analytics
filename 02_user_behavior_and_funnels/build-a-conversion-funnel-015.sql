drop temporary table if exists session_made_it_flags;
create temporary table session_made_it_flags
select
	website_session_id,
	max(products_page) as made_it_to_products,
    max(mrfuzzy_page) as made_it_to_mrfuzzy,
    max(cart_page) as made_it_to_cart,
    max(shipping_page) as made_it_to_shipping,
    max(billing_page) as made_it_to_billing,
    max(thank_you_page) as made_it_to_thank_you
from(
select
	website_sessions.website_session_id,
    website_pageviews.created_at as pv_created_at,
    -- case when website_pageviews.pageview_url = '/lander-1' then 1 else 0 end as landing_page,
    case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_page,
    case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page,
    case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
    case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_page,
    case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you_page
from website_sessions
	left join website_pageviews
		on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2012-08-05' and '2012-09-05'
	and website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
) as pv_level
    -- the urls we have are: '/lander-1', '/product', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing' and '/thank-you-for-your-order'
group by 1;

select * from session_made_it_flags; -- QA

drop temporary table if exists final_output_part_2;
create temporary table final_output_part_2
select
	count(distinct website_session_id) as sessions,
	count(distinct case when made_it_to_products = 1 then website_session_id else null end) as to_product,
    count(distinct case when made_it_to_mrfuzzy = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when made_it_to_cart = 1 then website_session_id else null end) as to_cart,
    count(distinct case when made_it_to_shipping = 1 then website_session_id else null end) as to_shipping,
	count(distinct case when made_it_to_billing = 1 then website_session_id else null end) as to_billing,
	count(distinct case when made_it_to_thank_you = 1 then website_session_id else null end) as to_thank_you    
from session_made_it_flags;

select * from final_output_part_2; 	-- QA Test 

select
	to_product / sessions as product_CTR,
    to_mrfuzzy / to_product as mrfuzzy_CTR,
    to_cart / to_mrfuzzy as cart_CTR,
    to_shipping / to_cart as shipping_CTR,
    to_billing / to_shipping as billing_CTR,
    to_thank_you / to_billing as thank_you_CTR
from final_output_part_2



