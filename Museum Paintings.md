```
import pandas as pd
from sqlalchemy import create_engine


conn_string = 'mysql://root:1122@localhost/paintings'
db = create_engine(conn_string)
conn = db.connect()


files = ['artist','canvas_size','image_link','museum','museum_hours','product_size','subject','work']
for file in files:
    df= pd.read_csv(f"C:/Users/zeus/Desktop/Git Repositories/Museum_Painting/{file}.csv")
    df.to_sql(file, con=conn, if_exists='replace', index = False)
```
# Here we will be solving 22 Question of SQL ranges from beginner level to Expert level:

1. Fetch all the paintings which are not displayed on any museums?

![[Task 1.png]]
Here we are getting 1000 rows which means that there are 1000 paintings that are not displayed any museum.

2. Are there museums without any paintings?

![[TASK2.png]]
The Output window throws an empty space which means that there is not a single museum without paintings. It means that all the Museum have atleast of one painting. 

3. How many paintings have an asking price of more than their regular price?
![[TASK 3.png]]
Here we are again having a blank output which means that here is not a single painting that have asking price more than their regular price.


4. Identify the paintings whose asking price is less than 50% of its regular price
![[TASK 4.png]]
There are 34 of such paintings that have the asking price less than the 50% of its regular price.

5. Which canva size costs the most?
![[Pasted image 20240114233657.png]]
so the canvas with the size 48" x 96"(122cm x 244cm) is the most expensive one. 

6. Delete duplicate records from work, product_size, subject and image_link tables

7. Identify the museums with invalid city information in the given dataset
![[Pasted image 20240115001221.png]]


8. Museum_Hours table has 1 invalid entry. Identify it and remove it.

![[Pasted image 20240115005855.png]]
These are the museums which are having invalid opening and closing time.
9. Fetch the top 10 most famous painting subject
![[Pasted image 20240115015148.png]]
10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
![[Pasted image 20240115015254.png]]
There are 27 of these museums that are open both sunday and monday. 



11. How many museums are open every single day?
![[Pasted image 20240115015928.png]]

There are 16 museums which are open for all 7 days of the week
12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
![[Pasted image 20240115021202.png]]



13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
![[Pasted image 20240115100737.png]]



14. Display the 3 least popular canva sizes
![[Pasted image 20240115134201.png]]



15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
![[Pasted image 20240115232126.png]]




16. Which museum has the most no of most popular painting style?
![[Pasted image 20240116005223.png]]




17. Identify the artists whose paintings are displayed in multiple countries
![[Pasted image 20240116015158.png]]




1. Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.


3. Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label
![[Pasted image 20240116191617.png]]

4. Which country has the 5th highest no of paintings?
![[Pasted image 20240116224931.png]]
5. Which are the 3 most popular and 3 least popular painting styles?
![[Pasted image 20240116224920.png]]
6. Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality

![[Pasted image 20240116230843.png]]




















Rough
select * from work;
select * from subject;
with Image_CTE as(
select work_id, url, thumbnail_small_url, thumbnail_large_url,
row_number() over(partition by work_id, url, thumbnail_small_url, thumbnail_large_url 
					order by work_id) as RowNumber
from image_link
)
delete from Image_CTE
where RowNumber > 1;

WITH Image_CTE AS (
    SELECT 
        work_id, 
        url, 
        thumbnail_small_url, 
        thumbnail_large_url,
        ROW_NUMBER() OVER (PARTITION BY work_id, url, thumbnail_small_url, thumbnail_large_url ORDER BY work_id) AS RowNumber
    FROM 
        image_link
)

DELETE FROM image_link
WHERE (work_id, url, thumbnail_small_url, thumbnail_large_url, RowNumber) IN (
    SELECT work_id, url, thumbnail_small_url, thumbnail_large_url, RowNumber
    FROM Image_CTE
    WHERE RowNumber > 1
);


select * from (
select work_id, url, thumbnail_small_url, thumbnail_large_url,
row_number() over(partition by work_id, url, thumbnail_small_url, thumbnail_large_url 
					order by work_id) as RowNumber
from image_link
) p
where RowNumber  = 1;

SELECT *
FROM (
    SELECT 
        work_id,
        name,
        artist_id,
        style,
        museum_id,
        ROW_NUMBER() OVER (PARTITION BY work_id, name, artist_id, style, museum_id ORDER BY work_id) AS RowNumber
    FROM 
        work
) AS Subquery
WHERE 
    RowNumber = 1;

business 
