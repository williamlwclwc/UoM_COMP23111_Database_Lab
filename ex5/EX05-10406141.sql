-- [header]
-- COMP23111 Fundamentals of Databases
-- Exercise <05>
-- by <Wenchang Liu>, ID <10406141>, login name <p87934wl>
-- [opening]
start /opt/info/courses/COMP23111/create-Orinoco-tables-complete.sql
start /opt/info/courses/COMP23111/populate-Orinoco-tables-complete.sql

SET ECHO ON
-- causes the SQL statements themselves to be spooled
SPOOL EX05-10406141.log
-- sends everything to <EX05-10406141.log>
set lin 120
col title for A20
col createdBy for A20
col is_distributed_as for A20
col albumTitle for A20
col songTitle for A20

-- [body]

--(1)
select * from contractinfo;
create or replace trigger setDuration
before insert or update on contractinfo
for each row
begin
    :new.duration := :new.date_to - :new.date_from;
end;
/
insert into contractinfo(hascontract, date_from, date_to, duration)
values('JZ', '21-JUN-13', '16-JUL-14', null);
select * from contractinfo;
update contractinfo
set date_to = '16-JUL-15'
where date_from = '21-JUN-13';
select * from contractinfo;

--(2)
create or replace procedure checkTemporal
(name in contractinfo.hascontract%type, dateFrom in date, dateTo in date)
is
    cnt number;
begin
    if dateFrom > dateTo then
        raise_application_error(-20001, 'date_from should be earlier than date_to');
    end if;
    select count(hascontract) into cnt from
 	(select * from contractinfo where hascontract = name 
 	and ((dateFrom between date_from and date_to) 
     or (dateTo between date_from and date_to)));
 	if cnt > 0 then
 		raise_application_error(-20002, 'conflict with prior contracts');
 	end if;
end;
/
-- dateTo prior to dateFrom
execute checkTemporal('JZ', '11-OCT-16', '20-OCT-14');
-- new contract's valid date lies between old one's valid date
execute checkTemporal('JZ', '1-JAN-05', '13-OCT-06');
-- working just fine
execute checkTemporal('JZ', '13-OCT-18', '10-OCT-20');

--(3)
create or replace view AlbumDistribution
(
    album, 
    title, 
    createdby,
    is_distributed_as
)
as(
    select album_id, title, createdBy, 
	case 
        when album_id like'%t' then 't' 
	    when album_id like '%c' then 'c'
	    when album_id like '%v' then 'v'
	end
    from (select * from album)
);
select * from AlbumDistribution;

--(4)
set serveroutput on;
create or replace procedure printSequence
 (albumType in varchar, albumTitle in album.title%type)
is
albumName album.title%type;
fetchedAlbumTitle album.title%type;
fetchedSongTitle finishedtrack.released_title%type;
fetchedSequence number;
cursor cursor1(albumName in album.title%type) is
	select distinct album.title as albumTitle,
           finishedtrack.released_title as songTitle,
           hastrack.sequence as sNum
	from hastrack 
	join finishedtrack on hastrack.originatesfrom = finishedtrack.originatesFrom 
	join album on hastrack.album_id = album.album_id
	where album.title = albumName
    order by(hastrack.sequence);

begin
-- Get the title of the album
 	select title into albumName from AlbumDistribution  
 	where is_distributed_as = albumType and title like '%'||albumTitle||'%';
 	open cursor1(albumName);
        loop
            fetch cursor1 into fetchedAlbumTitle, fetchedSongTitle, fetchedSequence;
            exit when cursor1%NOTFOUND;
            dbms_output.put_line(fetchedSequence || ', ' || fetchedSongTitle || ' > ' || fetchedAlbumTitle);
        end loop;
 	close cursor1;
end;
/

-- valid
select distinct album.title as albumTitle, finishedtrack.released_title as songTitle
from hastrack 
join finishedtrack on hastrack.originatesfrom = finishedtrack.originatesFrom 
join album on hastrack.album_id = album.album_id
where album.title = 'My Feet';
execute printSequence('c', 'ee');

--invalid
execute printSequence('c', 'invalidTest');

-- [close]
SPOOL OFF

start /opt/info/courses/COMP23111/drop-Orinoco-tables-complete.sql
start /opt/info/courses/COMP23111/drop-Orinoco-tables-complete.sql
-- [footer]
--
-- End of Exercise <05> by <Wenchang Liu>