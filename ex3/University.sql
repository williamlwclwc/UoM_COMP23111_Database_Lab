start /opt/info/courses/COMP23111/create-University-tables.sql
start /opt/info/courses/COMP23111/populate-University-tables.sql

-- (a)

-- Find names of students(no duplicate) take CS
select distinct name from student
inner join takes on student.id = takes.id
where takes.course_id like 'CS%';

-- Find id & name of students not taken any course before spring 2009
select distinct student.id, name from student
left join takes on student.id = takes.id
where takes.year is null or not takes.year < 2009;

-- For each department, find the maximum salary of instructors in that department
select dept_name, id, name, salary from instructor i
where salary = (select max(salary) from instructor where dept_name = i.dept_name)
order by i.dept_name; 

-- Find the lowest, across all departments, of the per-department maximum salary 
-- computed by the preceding query.
select dept_name, salary 
from instructor
where salary = (select min(salary) from (select dept_name, id, name, salary from instructor i
where salary = (select max(salary) from instructor where dept_name = i.dept_name)));

-- (b)

-- i. Create a new CS-001 course in computer science, titled Weekly Seminar, with 10 credits.
insert into course
values ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 10);

-- ii. Create a new CS-002 course in computer science, titled Monthly Seminar, with 0 credits.
-- insert into course
-- values ('CS-002', 'Monthly Seminar', 'Comp. Sci.', 0);
-- iii. Explanation: Violated the constraint that courses should have credits, if change credits
-- to some number that is bigger than 0 than we can creat the course.

-- iv. Create a section of the CS-001 course in Fall 2009, with section id of 1.
insert into section (course_id, sec_id, semester, year)
values ('CS-001', 1, 'Fall', 2009);
-- v. Explanation: Because we do not know those information, so we set them as null

-- vi. Enrol every student in the CS department in the section you created in the previous statement.
insert into takes (id, course_id, sec_id, semester, year)
(select student.id, section.course_id, section.sec_id, section.semester, section.year from student, section
where student.dept_name = 'Comp. Sci.' and section.course_id = 'CS-001');

-- vii. Delete all enrolments in the above section where the student’s name is Zhang.
delete from (select * from takes inner join student on takes.id = student.id
where takes.id = student.id 
and student.name = 'Zhang'
and takes.course_id = 'CS-001'); 

-- viii. Delete all takes tuples corresponding to any section & course with substring'database' of the title
delete from (select * from takes 
where takes.course_id in (select section.course_id from section
inner join course on section.course_id = course.course_id
where takes.course_id = course.course_id and lower(course.title) like '%database%'));

-- ix. Delete the course CS-001.
delete from course
where course.course_id = 'CS-001';
-- x. Explanation: when course 'CS-001' was deleted, the data in its related table was also automatically
-- deleted, this is because takes, section and course linked together with 'course_id'.

start /opt/info/courses/COMP23111/drop-University-tables.sql