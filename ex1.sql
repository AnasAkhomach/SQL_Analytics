-- select * from website_pageviews_non_normalized;
-- where website_session_id = 20;
-- create table website_pageviews_normalized
select 
website_pageview_id,
created_at,
website_session_id,
pageview_url
from website_pageviews_non_normalized;

alter table website_pageviews_normalized add primary key (website_pageview_id);

-- create table website_sessions_normalized
select distinct
website_session_id,
session_created_at,
user_id,
is_repeat_session,
utm_source,
utm_campaign,
utm_content,
device_type,
http_referer
from website_pageviews_non_normalized;

alter table website_sessions_normalized add primary key (website_session_id);


/*
ALTER TABLE `mavenfuzzyfactorymini`.`website_pageviews_normalized` 
ADD INDEX `website_session_id_idx` (`website_session_id` ASC) VISIBLE;
;
ALTER TABLE `mavenfuzzyfactorymini`.`website_pageviews_normalized` 
ADD CONSTRAINT `website_session_id`
  FOREIGN KEY (`website_session_id`)
  REFERENCES `mavenfuzzyfactorymini`.`website_sessions_normalized` (`website_session_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
*/