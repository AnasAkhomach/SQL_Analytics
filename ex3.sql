/*
delimiter //

create procedure my_procedure_name()
begin
	select * from inventory;
end //

delimiter ;
*/
use sloppyjoes;
select * from staff;
select * from customer_orders;
 
 CALL sp_staffOrdersServed;
 
DELIMITER //
CREATE PROCEDURE sp_staffOrdersServed()
BEGIN
select staff_id, count(order_id) as num_orders from customer_orders group by staff_id;
END //
DELIMITER ;


