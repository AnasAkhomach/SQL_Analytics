use onlinelearningschool;

select * from course_ratings;

select * from course_ratings_summaries;

select * from courses;

create table course_ratings_normalized
select distinct
	rating_id,
	course_id,
    star_rating
from course_ratings
where course_id = 1;

 