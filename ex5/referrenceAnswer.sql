-- Q1
CREATE OR REPLACE TRIGGER set_duration
BEFORE INSERT OR UPDATE ON ContractInfo 
FOR EACH ROW

BEGIN

	:new.duration := :new.date_to - :new.DATE_FROM;

END;
/

SELECT * FROM contractinfo;
UPDATE contractinfo SET DATE_FROM = '10-OCT-11' WHERE hascontract = 'Goldfrat';
SELECT * FROM contractinfo;
INSERT INTO contractinfo VALUES('Goldfrat', '10-AUG-05', '19-AUG-07', null);
SELECT * FROM contractinfo;

-- Q2
SET serveroutput ON;
CREATE OR REPLACE PROCEDURE check_valid_date
 (artistic_name IN ContractInfo.hasContract%type, new_date_from IN DATE, new_date_to IN DATE)

IS 
 num NUMBER;

BEGIN
 	IF new_date_from > new_date_to THEN
 		Raise_Application_Error(-20342, 'date_to prior to date_from');
 	END IF;

 	SELECT count(*) into num FROM
 	(SELECT * FROM ContractInfo WHERE hasContract = artistic_name 
 	and (new_date_from BETWEEN date_from AND date_to OR new_date_to BETWEEN 
 		date_from AND date_to));
 	IF num > 0 THEN
 		Raise_Application_Error(-20343, 'Invalid date of contract');
 	END IF;
 	dbms_output.put_line('Valid date');
 END;
 /
 -- show error

-- date_to prior to date_from
EXECUTE check_valid_date('Goldfrat', '10-OCT-15', '09-OCT-15');

-- new contract's valid date lies between old one's valid date
EXECUTE check_valid_date('Goldfrat', '10-OCT-12', '09-OCT-15');

-- properly working
EXECUTE check_valid_date('Goldfrat', '10-OCT-16', '09-OCT-18');




-- Q3
SET LINESIZE 32000
SET lin 120
col title for A20
CREATE OR REPLACE VIEW AlbumDistribution (title, createdBy, is_distributed_as) AS 
SELECT title, createdBy, 
	CASE WHEN album_ID like'%t' THEN 't' 
	WHEN album_ID like '%c' THEN 'c'
	WHEN album_ID like '%v' THEN 'v'
	END
FROM (SELECT * FROM Album);
SELECT * FROM AlbumDistribution;


-- Q4
SET serveroutput ON;
CREATE OR REPLACE PROCEDURE show_sequence
 (album_type IN VARCHAR, album_title IN album.title%type)

IS 
album_name album.title%type;
fetched_album_title album.title%type;
fetched_song_title finishedtrack.released_title%type;
CURSOR test_cur(album_name IN album.title%type) IS
	select album.title as albumTitle,finishedtrack.released_title as songTitle
	from hastrack 
	join finishedtrack on hastrack.originatesfrom = finishedtrack.originatesFrom 
	join album on hastrack.album_id = album.album_ID
	WHERE album.title = album_name;

BEGIN
-- Obtain the title of the album
 	SELECT title INTO album_name FROM AlbumDistribution  
 	WHERE is_distributed_as = album_type and title like '%'||album_title||'%';
 	-- dbms_output.put_line(album_name);


 	OPEN test_cur(album_name);
 	LOOP
 		FETCH test_cur INTO fetched_album_title, fetched_song_title;
 		EXIT WHEN test_cur%NOTFOUND;
 		dbms_output.put_line('sequence, ' || fetched_song_title || ' > ' || fetched_album_title);
 	END LOOP;

 	CLOSE test_cur;
 END;
 /
 show error

-- valid
col albumtitle for A20
col songtitle for A20
select album.title as albumTitle,finishedtrack.released_title as songTitle
from hastrack 
join finishedtrack on hastrack.originatesfrom = finishedtrack.originatesFrom 
join album on hastrack.album_id = album.album_ID
where album.title = 'Debut';

EXECUTE show_sequence('c', 'eb');


--invalid
EXECUTE show_sequence('c', 'invalid');





	