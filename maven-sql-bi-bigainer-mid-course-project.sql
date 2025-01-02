use mavenmovies;

/*
1.	We will need a list of all staff members, including their first and last names, 
email addresses, and the store identification number where they work. 
*/ 

select 
	first_name,
    last_name,
    email,
    store_id
from staff ;

/*
2.	We will need separate counts of inventory items held at each of your two stores. 
*/ 
select
	count(inventory_id) as inventory_items_count,
    store_id
from inventory
group by store_id ;

/*
3.	We will need a count of active customers for each of your stores. Separately, please. 
*/

select 
	store_id,
    count( case when customer.active = 1 then 1 else null end) as active
from customer
group by store_id ;	

/*
4.	In order to assess the liability of a data breach, we will need you to provide a count 
of all customer email addresses stored in the database. 
*/

select distinct count(email) from customer ;

/*
5.	We are interested in how diverse your film offering is as a means of understanding how likely 
you are to keep customers engaged in the future. Please provide a count of unique film titles 
you have in inventory at each store and then provide a count of the unique categories of films you provide. 
*/
select distinct
	store_id,
    count(case when store_id = 1 then 1 else null end) as count_of_unique_titles_in_store_1,
    count(case when store_id = 2 then 1 else null end) as count_of_unique_titles_in_store_2
from inventory
group by store_id;
select distinct count(category_id) from category ;

/*
6.	We would like to understand the replacement cost of your films. 
Please provide the replacement cost for the film that is least expensive to replace, 
the most expensive to replace, and the average of all films you carry. ``	
*/
select distinct	
	min(replacement_cost) as cheapest,
    max(replacement_cost) as most_expensive,
    avg(replacement_cost) as avg_replacement_cost
from film ;

/*
7.	We are interested in having you put payment monitoring systems and maximum payment 
processing restrictions in place in order to minimize the future risk of fraud by your staff. 
Please provide the average payment you process, as well as the maximum payment you have processed.
*/
select
	avg(amount) as avg_payment,
    avg(case when staff_id = 1 then amount else null end) as avg_staff_1,
    avg(case when staff_id = 2 then amount else null end) as avg_staff_2,
    max(amount) as max_processed_amount
from payment ;

/*
8.	We would like to better understand what your customer base looks like. 
Please provide a list of all customer identification values, with a count of rentals 
they have made all-time, with your highest volume customers at the top of the list.
*/
select customer_id,
count(rental_id) as number_of_rentals
from rental
group by customer_id
order by count(rental_id) desc


