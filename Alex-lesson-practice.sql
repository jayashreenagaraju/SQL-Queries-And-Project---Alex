select * from employee_demographics;
select * from employee_salary;
select * from parks_departments;


-- Groupby
select gender,round(avg(age)) as average_age,max(age),min(age),count(age)
from employee_demographics
group by gender;

select occupation,salary
from employee_salary
group by occupation,salary;

-- Order By
select * from employee_demographics
order by gender,age desc;

-- Where vs Having
select gender, avg(age)
from employee_demographics
group by gender
having avg(age) > 40;

-- wildcards
select occupation, avg(salary)
from employee_salary
where occupation  like '%manager%'
group by occupation 
having avg(salary) > 45000;

-- limit
 select * from employee_demographics
 order by age desc
 limit 4,1;

-- Joins
-- Inner joins
select dem.employee_id, occupation, salary
from employee_demographics as dem
join employee_salary as sal
on dem.employee_id=sal.employee_id;

-- Left Outer joins
select *
from employee_demographics as dem
left join employee_salary as sal
on dem.employee_id=sal.employee_id;

-- Right Outer joins
select *
from employee_demographics as dem
right join employee_salary as sal
on dem.employee_id=sal.employee_id;

-- multiple joins
select * 
from employee_demographics as dem
join employee_salary as sal
on dem.employee_id=sal.employee_id
join parks_departments as pa_dep
on sal.dept_id = pa_dep.department_id;

-- self join
select * 
from employee_salary emp1 
join employee_salary emp2
on emp1.employee_id +1=emp2.employee_id;

-- Union(Automatically gives distinct value)
select first_name,last_name
from employee_demographics
union
select first_name,last_name
from employee_salary;

select first_name,last_name, 'old man' as label 
from employee_demographics
where age > 40 and gender = 'Male'
union 
select first_name,last_name ,'old lady' as label 
from employee_demographics
where age > 40 and gender = 'Female'
union
select first_name,last_name, 'Highly paid employee' as label
from employee_salary
where salary >70000 
order by first_name,last_name;

-- String Functions
select  length('Jayashree');

select first_name,length(first_name)
from employee_demographics
order by 2;

select first_name, upper(first_name)
from employee_demographics;

select trim('   sky ');
-- Substrings
select first_name,
left(first_name,4),
right(first_name,4),
substring(first_name,3,2),
birth_date,
substring(birth_date,6,2) as birth_month
from employee_demographics;

-- replace
select first_name,replace (first_name, 'a','z')
from employee_demographics;

-- locate
select first_name,locate('An',first_name) 
from employee_demographics;

-- concat
select first_name,last_name, concat(first_name, ' ' ,last_name) as full_name
from employee_demographics;

-- case statements
select first_name, last_name, age,
case
	when age <= 30 then 'young'
    when age between 31 and 50 then 'middle age'
    when age >= 50 then 'old'
end as age_group
from employee_demographics;


-- pay Increase and Bonus
-- salary < 50000 = 5%
-- salary > 50000 = 7%
-- Department -> Finance = 10% bonus

select first_name,last_name, salary,
case
	when salary < 50000 then salary * 1.05 
    when salary > 50000 then salary * 1.07
end as new_salary,
case
	when dept_id = 6 then salary * .10
end as bonus
from employee_salary;

select * from parks_departments; 
select * from employee_salary; 

-- Subqueries in where clause

select * 
from employee_demographics
where employee_id in 
				(select employee_id   -- only one column name which is mentioned in where statement
				from employee_salary 
                where dept_id=1);

-- subqueries in select statement
select first_name, last_name , salary,
(select avg(salary) from employee_salary) 
from employee_salary;

-- window functios

select dem.first_name,dem.last_name,gender,
sum(salary) over(partition by gender order by dem.employee_id) as rolling_or_cumiliative_total 
from employee_demographics as dem
join employee_salary as sal 
on dem.employee_id = sal.employee_id;

select dem.employee_id,dem.first_name,dem.last_name,gender,salary,
row_number()over(partition by gender order by salary desc) as row_num,
rank() over(partition by gender order by salary desc) as rank_num  ,      -- based on order by if it has duplicate value then it repeats the rank and skip the next num positionally 
dense_rank() over(partition by gender order by salary desc) as dense_rank_num  -- based on order by if it has duplicate value then it repeats the dense_rank and gives the next number numerically. it doesnot skip the next number in the rank.
from employee_demographics as dem
join employee_salary as sal 
on dem.employee_id = sal.employee_id;

-- CTEs - common table expressions

with cte_example as
(select gender, avg(salary) as avg_salary, max(salary) as max_salary,min(salary) as min_salary, count(salary) as count_sal 
from employee_demographics dem
join employee_salary sal
on dem. employee_id = sal.employee_id
group by gender)
select round(avg(avg_salary),2) from cte_example;

-- It replaces name if we write within cte line
with cte_example(Gender, Avg_sal,Max_sal,Min_sal,Count_sal) as
(select gender, avg(salary) as avg_salary, max(salary) as max_salary,min(salary) as min_salary, count(salary) as count_sal 
from employee_demographics dem
join employee_salary sal
on dem. employee_id = sal.employee_id
group by gender)
select * from cte_example;


-- cte with multiple cte

with cte_example1 as
(select employee_id,gender,birth_date
 from employee_demographics
 where birth_date >  '1985-01-01'),
 cte_example2 as
 (select employee_id,salary 
 from employee_salary
 where salary > 50000)
select * 
from cte_example1 as cte1
join cte_example2 as cte2
on cte1.employee_id = cte2.employee_id;

-- Temporary Tables

create temporary table salary_over_70k
select * from employee_salary
where salary > 70000;
select * from salary_over_70k;

-- Stored Procedures
-- we can crete a stored proceducre by clicking create a stored procedure and 
-- in the middle of begin and end we can write the query we want it then clickk apply then refresh schema and then click on lightning button to see the created procedure results. 
-- and also we can  write  on our own. and also we can pass the parameter and call the procedure.

--  Also we can  write  on our own and call the procedure.
Delimiter $$
create procedure large_salaries()
begin
	select * from employee_salary
    where salary >= 50000;
    select * from employee_salary 
    where salary >= 10000;
end $$
Delimiter ;

call large_salaries();

-- now calling the procedure by also passing parameter

Delimiter $$
create procedure large_salaries1(employee_id_parameter Int) -- need to pass parameter which one we want to call and we need to write datatype
begin
	select salary 
    from employee_salary
    where employee_id = employee_id_parameter;  -- here we need to write parameter
end $$
Delimiter ;

call large_salaries1(1);

-- Triggers and Events

-- Triggers
Delimiter $$
create trigger employee_insert         -- creating trigger name called employee_insert
	After Insert on employee_salary    -- we can write after or before . we need to write the table name 
    for each row                        -- need to mention for each row because if the new employee added in the salary table we need to update in demographics table also
begin
	insert into employee_demographics(employee_id,first_name,last_name)   -- inserting new values into demographics table
    values (new.employee_id, new.first_name, new.last_name);              -- here we can write new or old based  on the requirements
end $$
delimiter ;

-- after running  the above code we will get triggers in the employee salary section. But we cannot do anything so we will test it by inserting values to salary table
Insert into employee_salary (employee_id,first_name,last_name,occupation,salary,dept_id)
values(13,'Jean-Ralphio','Saperstein','Entertainment_720_CEo',1000000,Null);

-- After this we can run employee_salary table and demographics table. it automatically generates the values in demographics table.
select * from employee_salary;
select * from employee_demographics; -- it automatically triggers new entry in the demographics table.

-- Events  - it is similar to triggers but event takes place only when it is schedule

Delimiter $$
create event delete_retirees
on schedule every 30 second     -- here we can schedule month, week whatever we want
do
begin
	Delete 
    from employee_demographics 
    where age >= 60;
end $$
delimiter ;

select * from employee_demographics; -- to check if it is deleted or not.

-- if the event did not work or if we cannot crete we need to do this step

show variables like 'event%';  -- if it shows ON its working. If its OFF then we need to ON it.