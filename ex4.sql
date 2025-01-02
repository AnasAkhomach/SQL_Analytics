select * from customer_orders;
select * from staff;

/*
CREATE TRIGGER my_trigger
AFTER INSERT ON my_table
FOR EACH ROW
	UPDATE other_table
		SET column_name_num_attr = column_name_num_attr - 1
	WHERE column_name_primary = NEW.column_name_primary;
    
INSERT INTO my_table VALUES
	('value_1', 2, 3.0);
*/
CREATE TRIGGER update_orders_served_by_staff
AFTER INSERT ON customer_orders
FOR EACH ROW
	UPDATE staff
		SET orders_served = orders_served + 1
	WHERE staff_id = NEW.staff_id;
    
INSERT INTO customer_orders VALUES
	(21, 1, 2.99),
    (22, 1, 4.99),
    (23, 2, 10.99);
