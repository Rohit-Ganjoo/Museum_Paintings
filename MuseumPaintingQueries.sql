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

select distinct * from 
(select m.name as `Museum Name`, time_format(timediff(mh.open, mh.close),'%H:%i') as Open_time,m.city,m.state
from museum_hours mh 
join museum m 
on m.museum_id = mh.museum_id)x
order by Open_time desc
limit 5  ;


-- 16. Which museum has the most no of most popular painting style?

with pop_style as 
			(select style
			,rank() over(order by count(1) desc) as rnk
			from work
			group by style),
		cte as
			(select w.museum_id,m.name as museum_name,ps.style, count(1) as no_of_paintings
			,rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			join pop_style ps on ps.style = w.style
			where w.museum_id is not null
			and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
	select museum_name,style,no_of_paintings
	from cte 
	where rnk=1;






-- 17. Identify the artists whose paintings are displayed in multiple countries

with paint as
	(select distinct a.full_name as Artist_Name, w.name as painting, m.name as Museum,
	m.country 
	from work w
	join artist a on a.artist_id=w.artist_id
	join museum m on m.museum_id=w.museum_id)
select Artist_Name, count(1) as `Number of countries`
from paint
group by 1
order by 2 desc;

-- 18. Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
	
    select country,city, count(name) as `Number of Museums` from museum
    Group by country,city
    order by 3 desc;
    
    
    
WITH cte_country AS (
    SELECT country, COUNT(1) AS count_country,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM museum
    GROUP BY country
),
cte_city AS (
    SELECT city, COUNT(1) AS count_city,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM museum
    GROUP BY city
),
filtered_countries AS (
    SELECT DISTINCT country
    FROM cte_country
    WHERE rnk = 1
),
filtered_cities AS (
    SELECT DISTINCT city
    FROM cte_city
    WHERE rnk = 1
)
SELECT group_concat(country) AS top_countries,
       group_concat(city) AS top_cities
FROM filtered_countries
CROSS JOIN filtered_cities;
    
-- 19. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label
WITH Ranking AS (
    SELECT
        sale_price,
        size_id, 
        work_id,
        RANK() OVER (ORDER BY sale_price DESC) AS rnk_desc,
        RANK() OVER (ORDER BY sale_price ASC) AS rnk_asc
    FROM product_size
)
SELECT
    a.full_name AS `Artist Name`,
    w.name AS `Painting Name`,
    R.sale_price AS `Painting Price`,
    m.name AS `Museum Name`,
    m.city AS `Museum City`,
    cs.label AS `Canvas Dimension`
FROM Ranking R
JOIN work w ON w.work_id = R.work_id
JOIN museum m ON m.museum_id = w.museum_id
JOIN canvas_size cs ON cs.size_id = R.size_id
JOIN artist a ON a.artist_id = w.artist_id
WHERE rnk_desc = 1 OR rnk_asc = 1;


-- 20. Which country has the 5th highest no of paintings?
select * from work;
select * from museum;


with highest as 
(select m.country as `Country`,count(w.work_id) as `Number of Paintings`,row_number() over (order by count(w.work_id) desc) as Rnk
from work  w 
join museum m 
on m.museum_id = w.museum_id
group by 1)
select *
from highest
where Rnk = 5;


-- 21. Which are the 3 most popular and 3 least popular painting styles?
with cte as 
(select style, count(work_id) as cnt
		, rank() over(order by count(work_id) desc) rnk
		, count(1) over() as no_of_records
		from work
		where style is not null
		group by style)

select style,
case 
	when Rnk <= 3 then 'Most Popular'
    else 'Least Popular'
end as remarks
from cte 
where Rnk <=3
or Rnk > no_of_records - 3;







-- 22. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality

select `Artist Name`,`Nationality`,`Number of Painitings`
from 
(select a.full_name as `Artist Name`,
		a.nationality as `Nationality`,
		count(w.work_id) as `Number of Painitings`,
        rank() over ( order by count(w.work_id) desc) as Rnk
        from work w 
        join artist a on a.artist_id = w.artist_id
        join subject s on s.work_id = w.work_id
        join museum m on m.museum_id = w.museum_id
        where s.subject = 'Portraits'
        and m.country != 'USA'
        group by 1,2) X
where x.rnk <=10 ;
        

