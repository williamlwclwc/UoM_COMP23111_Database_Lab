-- [header]
-- COMP23111 Fundamentals of Databases
-- Exercise <04>
-- by <Wenchang Liu>, ID <10406141>, login name <p87934wl>
-- [opening]

start /opt/info/courses/COMP23111/create-Eclectic-Ecommerce-tables.sql
start /opt/info/courses/COMP23111/populate-Eclectic-Ecommerce-tables.sql

SET ECHO ON
-- causes the SQL statements themselves to be spooled
SPOOL EX04-10406141.log
-- sends everything to <EX04-10406141.log>
set lin 120
col picture for A25
-- [body]

--(a)
create or replace view customer_with_carts
(
    firstname,
    lastname
)
as (
    select distinct firstname, lastname 
    from customerinfo, ordercartinfo, lineitems
    where customerinfo.loginname = ordercartinfo.customerid
    and ordercartinfo.ordercartid = lineitems.ordercartid
    and lineitems.qtyordered > 0
);
select * from customer_with_carts;

--(b)
create or replace view need_record
(
    code,
    itemnum,
    categoryid,
    quantityinstock
)
as(
    select distinct code, itemtype.itemnum, belongsto, qtyinstock 
    from itemtype, inventoryitem
    where itemtype.itemnum = inventoryitem.itemnum
    and inventoryitem.qtyinstock < 25
);
select * from need_record;

--(c)
create or replace view order_price
(
    loginname,
    firstname,
    lastname,
    ordercartid,
    price
)
as(
    select loginname, firstname, lastname, ordercartinfo.ordercartid, sum(orderprice * qtyordered)
    from customerinfo, ordercartinfo, lineitems
    where customerinfo.loginname = ordercartinfo.customerid
    and ordercartinfo.ordercartid = lineitems.ordercartid
    group by ordercartinfo.ordercartid, loginname, firstname, lastname
);
select * from order_price;

--(d)
create or replace view order_total
(
    loginname,
    firstname,
    lastname,
    total
)
as(
    select loginname, firstname, lastname, sum(orderprice * qtyordered)
    from customerinfo, ordercartinfo, lineitems
    where customerinfo.loginname = ordercartinfo.customerid
    and ordercartinfo.ordercartid = lineitems.ordercartid
    group by customerid, loginname, firstname, lastname
);
select * from order_total;

--(e)
create or replace view carts_num
(
    customerid,
    cartnum
)
as(
    select loginname, count(ordercartid) as cart_num
    from customerinfo
    left join ordercartinfo on customerinfo.loginname = ordercartinfo.customerid
    group by loginname
);
select customerid,
    case
        when cartnum < 3 
        then 'BR-1 satisfied'
        else 'BR-1 violated' 
    end as outcome
from carts_num;

--(f)
--Q2：
select itemnum, itemsize, itemcolor, count(itemnum) as cnt_item
from inventoryitem
group by itemcolor, itemsize, itemnum;
--Q1:
select itemnum, itemsize, itemcolor,
    case
        when cnt_item < 2
        then 'BR-2 satisfied'
        else 'BR-2 violated' 
    end as outcome
from (select itemnum, itemsize, itemcolor, count(itemnum) as cnt_item
from inventoryitem
group by itemcolor, itemsize, itemnum);
--Final:
select itemnum, itemcolor, itemsize, outcome
from (select itemnum, itemsize, itemcolor,
    case
        when cnt_item < 2
        then 'BR-2 satisfied'
        else 'BR-2 violated' 
    end as outcome
from (select itemnum, itemsize, itemcolor, count(itemnum) as cnt_item
from inventoryitem
group by itemcolor, itemsize, itemnum))
where outcome = 'BR-2 violated';

--(g)
create or replace trigger PriceIsTooHigh
before insert or update of price on itemtype
for each row
declare minimum float(126);
PRAGMA AUTONOMOUS_TRANSACTION;
begin
    select 4*min(price) into minimum from itemtype;
    if :new.price > minimum then
    raise_application_error(-20005, 'price of the item is too high');
    end if;
end;
/
--test for insert
select * from itemtype;
insert into itemtype(itemnum, name, picture, price, belongsto)
values('C4', 'invalid insert', null, 50, 'UN');
select * from itemtype;
select * from itemtype;
--test for update
update itemtype
set price = 50.99
where itemnum = 'A1';
select * from itemtype;
-- [close]
SPOOL OFF

drop view customer_with_carts;
drop view need_record;
drop view order_price;
drop view order_total;
drop view carts_num;
drop trigger PriceIsTooHigh;

start /opt/info/courses/COMP23111/drop-Eclectic-Ecommerce-tables.sql
-- [footer]
--
-- End of Exercise <04> by <Wenchang Liu>