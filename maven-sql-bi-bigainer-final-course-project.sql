use mavenmovies;
/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 
select 
	staff.first_name,
    staff.last_name,
    address.address,
    address.district,
    city.city,
    country.country    
from store
	left join staff
		on store.store_id = staff.store_id
	left join address
		on store.address_id = address.address_id
	left join city
		on address.city_id = city.city_id
	left join country
		on city.country_id = country.country_id;
-- select * from country
	
/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/
select 
	inventory.store_id,
    inventory.inventory_id,
    film.title,
    film.rating,
    film.rental_rate,
    film.replacement_cost
from 
	inventory
    left join film
		on film.film_id = inventory.film_id ;
/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/
select 
	inventory.store_id,
    film.rating,
    count(inventory_id) as inventory_items
from inventory
    left join film
		on film.film_id = inventory.film_id
group by 1,2;
/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 
select
	store_id,
    category.name,
    count(inventory_id),
    avg(replacement_cost),
    sum(replacement_cost)
from inventory
	left join film on inventory.film_id = film.film_id
	left join film_category on film_category.film_id = film.film_id 
    left join category on category.category_id = film_category.category_id
group by 1,2
    
/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/

/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/
    
/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/

/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/
