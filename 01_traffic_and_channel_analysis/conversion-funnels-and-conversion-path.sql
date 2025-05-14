	-- BUISNESS CONTEXT
		-- we will be building a mini conversion funnel, from '/lander-1' to '/cart'
        -- objectif: we want to know how many people reach each step, and the dropoff rates
	
    
    -- STEP 1: selesct all the pageviews for relevant sessions
    -- STEP 2: identify each relevant pageview as the spesific funnel step
    -- STEP 3: session-level conversion funnel view
    -- STEP 4: agregate the data to acces funnel performance
drop temporary table if exists session_level_made_it_flags;
create temporary table session_level_made_it_flags    
select
	website_session_id,
    max(products_page) as product_made_it,
    max(mrfuzzy_page) as mr_fuzzy_made_it,
    max(cart_page) as cart_made_it

from(
select
website_sessions.website_session_id,
website_pageviews.created_at as pv_created_at,
website_pageviews.pageview_url,
	case when pageview_url = '/products' then 1 else 0 end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
	and website_pageviews.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
) as pv_level
group by website_session_id;

select * from session_level_made_it_flags; 		-- QA Test 

create temporary table final_output_part_1
select
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_products,
    count(distinct case when mr_fuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_made_it then website_session_id else null end) as to_cart
from session_level_made_it_flags;

select
	sessions,
	to_products / sessions as products_CTR,
    to_mrfuzzy / to_products as mrfuzzy_CTR,
    to_cart / to_mrfuzzy as cart_CTR
from final_output_part_1