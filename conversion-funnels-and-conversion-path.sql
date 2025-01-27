	-- BUISNESS CONTEXT
		-- we will be building a mini conversion funnel, from '/lander-1' to '/cart'
        -- objectif: we want to know how many people reach each step, and the dropoff rates
	
    
    -- STEP 1: selesct all the pageviews for relevant sessions
    -- STEP 2: identify each relevant pageview as the spesific funnel step
    -- STEP 3: session-level conversion funnel view
    -- STEP 4: agregate the data to acces funnel performance
    
select
website_sessions.website_session_id,
website_pageviews.created_at as pv_created_at,
website_pageviews.pageview_url,
	case when pageview_url = '/products' then 1 else 0 end as prouduct_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
	and website_pageviews.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')