use paintings;
show tables;
select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;

-- 1. Fetch all the paintings which are not displayed on any museums? 
SELECT NAME AS Paintings
FROM WORK 
WHERE museum_id IS NULL;


-- 2. Are there museums without any paintings?
SELECT * FROM museum AS m
WHERE NOT EXISTS ( SELECT work_id FROM work AS w
					WHERE w.museum_id = m.museum_id);


-- 3. How many paintings have an asking price of more than their regular price?

select * from product_size 
where sale_price > regular_price;

-- 4. Identify the paintings whose asking price is less than 50% of its regular price
select name as Paintings,work_id
from work 
where work_id in
(select work_id 
from product_size
where sale_price < 0.5*regular_price);


-- 5. Which canva size costs the most?

select ps.rnk as Ranking,cs.label as Canvas, ps.sale_price
from (
select *, rank() over(order by sale_price desc) as rnk
from product_size) ps
join canvas_size cs on cs.size_id = ps.size_id
where ps.rnk =1;

select p.sale_price as `SalePrice`, c.label as Canvas
from product_size as p
join canvas_size c 
on c.size_id = p.size_id
order by p.sale_price desc
limit 1;


-- 6. Delete duplicate records from work, product_size, subject and image_link tables




-- 7. Identify the museums with invalid city information in the given dataset


select * from museum 
	where city regexp '[0-9]';
-- 8. Museum_Hours table has 1 invalid entry. Identify it and remove it.

-- This query is used to check the invalid rows 
SELECT *
FROM museum_hours
WHERE CAST(open AS TIME) < CAST(close AS TIME);

select * from (
SELECT TIME_FORMAT(TIMEDIFF(open, close), '%H:%i') AS time_difference, museum_id,day
FROM museum_hours) p
where time_difference regexp '[-]';


-- after knowing what are the parameters of the wrong rows we can easily remove it: 
DELETE FROM museum_hours
WHERE (museum_id = 40 AND day = 'Friday')
   OR (museum_id = 44 AND day = 'Tuesday')
   OR (museum_id = 48 AND day = 'Monday' )
   OR (museum_id = 49 AND day = 'Thursday')
   OR (museum_id = 73 AND day = 'Thusday');


-- 9. Fetch the top 10 most famous painting subject
select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10;


-- 10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
select name as Museum_name from museum m
where m.museum_id in (
select museum_id from museum_hours mh1
where day = 'Sunday' and
exists (select museum_id from museum_hours mh2
where mh1.museum_id = mh2.museum_id
and day = 'Monday') );



-- 11. How many museums are open every single day?

select museum_id, count(day) as Open_days
 from museum_hours
 group by museum_id
 having Open_days = 7;
 
 
 
 
-- 12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select m.name as Museum_name, m.city as City, m.country as Country, x.no_of_paintings
from (
select m.museum_id, count(1) as no_of_paintings,
rank() over (order by count(1) desc) as rnk
from work w
join museum m 
on m.museum_id = w.museum_id
group by m.museum_id) x 
join museum m 
on m.museum_id = x.museum_id
where x.rnk <= 5;


-- 13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)




select * from 
(select a.full_name as Artist_name, count(w.work_id) as `Number of Paintings`, 
row_number() over (order by count(w.work_id) desc) as Ranking
from work w 
join artist a 
on a.artist_id = w.artist_id
group by 1)x
where x.Ranking <=5;

-- 14. Display the 3 least popular canva sizes.


select * from (
select c.label as Canvas, count(w.work_id) as `Number of Paintings`, 
dense_rank() over (order by count(w.work_id) asc) as Ranking
from canvas_size c 
join product_size ps on ps.size_id = c.size_id
join work w on w.work_id = ps.work_id
group by 1)x
where  x.Ranking <= 3;



-- 15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
select * from museum;
select * from museum_hours;

select * from 
(select m.name as `Museum Name`, time_format(timediff(mh.open, mh.close),'%H:%i') as Open_time
from museum_hours mh 
join museum m 
on m.museum_id = mh.museum_id)x
order by Open_time desc
limit 1  ;
-- 16. Which museum has the most no of most popular painting style?

-- 17. Identify the artists whose paintings are displayed in multiple countries
-- 18. Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
-- 19. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label
-- 20. Which country has the 5th highest no of paintings?
-- 21. Which are the 3 most popular and 3 least popular painting styles?
-- 22. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality