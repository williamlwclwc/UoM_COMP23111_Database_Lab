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
    and lineitems.qtyordered > 0)
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
    select distinct lineitems.code, lineitems.itemnum, belongsto, qtyinstock 
    from lineitems, itemtype, inventoryitem
    where lineitems.itemnum = inventoryitem.itemnum
    and lineitems.code = inventoryitem.code
    and lineitems.itemnum = itemtype.itemnum
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
    select customerid, count(ordercartid)
    from ordercartinfo
    group by customerid 
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
select itemnum, itemcolor, itemsize
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

-- [close]
SPOOL OFF

/opt/info/courses/COMP23111/drop-Eclectic-Ecommerce-tables.sql
-- [footer]
--
-- End of Exercise <04> by <Wenchang Liu>