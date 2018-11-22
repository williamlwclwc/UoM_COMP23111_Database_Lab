start /opt/info/courses/COMP23111/create-Accident-tables.sql
start /opt/info/courses/COMP23111/populate-Accident-tables.sql

-- i. Find the number of accidents in which the cars belonging to Jane Rowling were involved.
select count(person.name) 
from accident, person, participated
where accident.report_number = participated.report_number
and participated.driver_id = person.driver_id 
and person.name = 'Jane Rowling'; 

-- ii. Update the amount of damage for the car with license number KUY 629 
-- in the accident with report number 7897423 to 2500.
update participated
set damage_amount = 2500
where report_number = 7897423
and license = 'KUY 629';

-- iii. List the name of the persons that participated in accidents along with the total damage
-- caused (descend) but only include those whose total damage is above 3000.
with total_damage as 
(select name, person.driver_id, sum(damage_amount) 
from person, participated
where person.driver_id = participated.driver_id
group by person.driver_id, name
having sum(damage_amount) > 3000)
select name from total_damage
order by name desc;

-- iv. Create a view that returns the locations where accidents have occurred along with 
-- the average amount of damage in that location. Call this view average_damage_per_location.
create view average_damage_per_location
(
    location,
    average_damage
)
as (select location, avg(damage_amount) from accident, participated
where accident.report_number = participated.report_number
group by accident.location);

-- v. Use the average_damage_per_location location you have just created to find 
-- the location that has the highest average damage.
select location
from average_damage_per_location
where average_damage = (select max(average_damage)
from average_damage_per_location);

drop view average_damage_per_location;

start /opt/info/courses/COMP23111/drop-Accident-tables.sql
