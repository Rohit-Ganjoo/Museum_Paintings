# Queries for Museum Paintings:


USE paintings;
-- use the database paintings, it is more like load this database inside the workspace. 


-- 1. Fetch all the paintings which are not displayed on any museums? 

SELECT NAME AS Paintings
FROM WORK 
WHERE museum_id IS NULL;


-- 2. Are there museums without any paintings? -->

SELECT * FROM museum AS m
WHERE NOT EXISTS ( SELECT work_id FROM work AS w
					WHERE w.museum_id = m.museum_id);



-- 3. How many paintings have an asking price of more than their regular price? -->

SELECT *
FROM product_size
WHERE sale_price > regular_price;



-- 4. Identify the paintings whose asking price is less than 50% of its regular price -->

SELECT name AS Paintings, work_id FROM work WHERE work_id IN 
( SELECT work_id FROM product_size WHERE sale_price <  0.5  * regular_price );



-- 5. Which canva size costs the most? -->

SELECT p.sale_price AS SalePrice, c.label AS Canvas
FROM product_size AS p
JOIN canvas_size c ON c.size_id = p.size_id
ORDER BY p.sale_price DESC
LIMIT 1;




-- 6. Identify the museums with invalid city information in the given dataset -->


SELECT *
FROM museum 
WHERE city REGEXP '[0-9]';





-- 7. Museum_Hours table has 1 invalid entry. Identify it and remove it. -->

-- Step 1: Check for invalid rows
SELECT *
FROM (
    SELECT TIME_FORMAT(TIMEDIFF(open, close), '%H:%i') AS time_difference, museum_id, day
    FROM museum_hours
) p
WHERE p.time_difference REGEXP '[-]';

-- Step 2: Remove the identified invalid rows
DELETE FROM museum_hours
WHERE (museum_id = 40 AND day = 'Friday')
    OR (museum_id = 44 AND day = 'Tuesday')
    OR (museum_id = 48 AND day = 'Monday')
    OR (museum_id = 49 AND day = 'Thursday')
    OR (museum_id = 73 AND day = 'Thusday');





-- 8. Fetch the top 10 most famous painting subject -->

SELECT *
FROM (
    SELECT
        s.subject,
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS ranking
    FROM
        work w
    JOIN
        subject s ON s.work_id = w.work_id
    GROUP BY
        s.subject
) x
WHERE
    ranking <= 10;







-- 9. Identify the museums which are open on both Sunday and Monday. Display museum name, city. -->

SELECT name AS Museum_name
FROM museum m
WHERE m.museum_id IN (
    SELECT museum_id
    FROM museum_hours mh1
    WHERE day = 'Sunday'
      AND EXISTS (
          SELECT museum_id
          FROM museum_hours mh2
          WHERE mh1.museum_id = mh2.museum_id
            AND day = 'Monday'
      )
);






-- 10. How many museums are open every single day? -->

SELECT museum_id, COUNT(day) AS Open_days
FROM museum_hours
GROUP BY museum_id
HAVING Open_days = 7;





-- 11. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum) -->

SELECT m.name AS Museum_name, m.city AS City, m.country AS Country, x.no_of_paintings
FROM (
    SELECT m.museum_id, COUNT(1) AS no_of_paintings,
    RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN museum m ON m.museum_id = w.museum_id
    GROUP BY m.museum_id
) x 
JOIN museum m ON m.museum_id = x.museum_id
WHERE x.rnk <= 5;





-- 12. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist) -->

SELECT * FROM 
(
    SELECT a.full_name AS Artist_name, COUNT(w.work_id) AS `Number of Paintings`, 
    ROW_NUMBER() OVER (ORDER BY COUNT(w.work_id) DESC) AS Ranking
    FROM work w 
    JOIN artist a ON a.artist_id = w.artist_id
    GROUP BY 1
) x
WHERE x.Ranking <= 5;





-- 13. Display the 3 least popular canva sizes. -->

SELECT * FROM (
    SELECT c.label AS Canvas, COUNT(w.work_id) AS `Number of Paintings`, 
    DENSE_RANK() OVER (ORDER BY COUNT(w.work_id) ASC) AS Ranking
    FROM canvas_size c 
    JOIN product_size ps ON ps.size_id = c.size_id
    JOIN work w ON w.work_id = ps.work_id
    GROUP BY 1
) x
WHERE x.Ranking <= 3;




-- 14. Which Museum is open for the longest during a day. Display museum name, state and hours open and which day? -->


SELECT DISTINCT * FROM (
    SELECT m.name AS `Museum Name`, TIME_FORMAT(TIMEDIFF(mh.open, mh.close), '%H:%i') AS Open_time, m.city, m.state
    FROM museum_hours mh 
    JOIN museum m ON m.museum_id = mh.museum_id
) x
ORDER BY Open_time DESC
LIMIT 5;





-- 15. Which Museum has the most no of most popular painting style? -->

WITH pop_style AS (
    SELECT style, RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work
    GROUP BY style
),
cte AS (
    SELECT
        w.museum_id,
        m.name AS museum_name,
        ps.style,
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN museum m ON m.museum_id = w.museum_id
    JOIN pop_style ps ON ps.style = w.style
    WHERE w.museum_id IS NOT NULL AND ps.rnk = 1
    GROUP BY w.museum_id, m.name, ps.style
)
SELECT museum_name, style, no_of_paintings
FROM cte
WHERE rnk = 1;







-- 16. Identify the artists whose paintings are displayed in multiple countries -->

WITH paint AS (
    SELECT DISTINCT
        a.full_name AS Artist_Name,
        w.name AS painting,
        m.name AS Museum,
        m.country
    FROM work w
    JOIN artist a ON a.artist_id = w.artist_id
    JOIN museum m ON m.museum_id = w.museum_id
)
SELECT Artist_Name, COUNT(1) AS `Number of countries`
FROM paint
GROUP BY 1
ORDER BY 2 DESC;






-- 17. Display the country and the city with most no of museums. Output 2 separate columns to mention the city and country. If there are multiple value, separate them with comma. -->

WITH cte_country AS (
    SELECT
        country,
        COUNT(1) AS count_country,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM
        museum
    GROUP BY
        country
),
cte_city AS (
    SELECT
        city,
        COUNT(1) AS count_city,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM
        museum
    GROUP BY
        city
),
filtered_countries AS (
    SELECT DISTINCT
        country
    FROM
        cte_country
    WHERE
        rnk = 1
),
filtered_cities AS (
    SELECT DISTINCT
        city
    FROM
        cte_city
    WHERE
        rnk = 1
)
SELECT
    GROUP_CONCAT(country) AS top_countries,
    GROUP_CONCAT(city) AS top_cities
FROM
    filtered_countries
CROSS JOIN
    filtered_cities;






-- 18. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label -->


WITH Ranking AS (
    SELECT
        sale_price,
        size_id, 
        work_id,
        RANK() OVER (ORDER BY sale_price DESC) AS rnk_desc,
        RANK() OVER (ORDER BY sale_price ASC) AS rnk_asc
    FROM
        product_size
)
SELECT
    a.full_name AS `Artist Name`,
    w.name AS `Painting Name`,
    R.sale_price AS `Painting Price`,
    m.name AS `Museum Name`,
    m.city AS `Museum City`,
    cs.label AS `Canvas Dimension`
FROM
    Ranking R
JOIN
    work w ON w.work_id = R.work_id
JOIN
    museum m ON m.museum_id = w.museum_id
JOIN
    canvas_size cs ON cs.size_id = R.size_id
JOIN
    artist a ON a.artist_id = w.artist_id
WHERE
    rnk_desc = 1 OR rnk_asc = 1;







-- 19. Which country has the 5th highest no of paintings? -->


WITH highest AS (
    SELECT
        m.country AS `Country`,
        COUNT(w.work_id) AS `Number of Paintings`,
        ROW_NUMBER() OVER (ORDER BY COUNT(w.work_id) DESC) AS Rnk
    FROM
        work w 
    JOIN
        museum m ON m.museum_id = w.museum_id
    GROUP BY
        1
)
SELECT *
FROM
    highest
WHERE
    Rnk = 5;







-- 20. Which are the 3 most popular and 3 least popular painting styles? -->

WITH cte AS (
    SELECT
        style,
        COUNT(work_id) AS cnt,
        RANK() OVER (ORDER BY COUNT(work_id) DESC) AS rnk,
        COUNT(1) OVER() AS no_of_records
    FROM
        work
    WHERE
        style IS NOT NULL
    GROUP BY
        style
)

SELECT
    style,
    CASE
        WHEN Rnk <= 3 THEN 'Most Popular'
        ELSE 'Least Popular'
    END AS remarks
FROM
    cte
WHERE
    Rnk <= 3
    OR Rnk > no_of_records - 3;








-- 21. Which artist has the most no of Portraits paintings outside USA? Display artist name, no of paintings and the artist nationality. -->

SELECT
    `Artist Name`,
    `Nationality`,
    `Number of Painitings`
FROM
    (
        SELECT
            a.full_name AS `Artist Name`,
            a.nationality AS `Nationality`,
            COUNT(w.work_id) AS `Number of Painitings`,
            RANK() OVER (ORDER BY COUNT(w.work_id) DESC) AS Rnk
        FROM
            work w
        JOIN
            artist a ON a.artist_id = w.artist_id
        JOIN
            subject s ON s.work_id = w.work_id
        JOIN
            museum m ON m.museum_id = w.museum_id
        WHERE
            s.subject = 'Portraits'
            AND m.country != 'USA'
        GROUP BY
            1, 2
    ) X
WHERE
    X.rnk <= 10;


