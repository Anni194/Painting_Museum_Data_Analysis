# Q1) Fetch all the paintings which are not dislayed in any of the museums?
SELECT * FROM work WHERE museum_id IS NULL;

# Q2) Are there any museums without any paintings?
SELECT * FROM museum m 
WHERE NOT EXISTS (SELECT 1 FROM work w WHERE m.museum_id=w.work_id );


# Q3) How many paintings have an asking price of more than their regular price ?
SELECT * FROM product_size WHERE sale_price > regular_price;

# Q4) Identify the paintings whose asking price is less than 50% of its regular price ?
SELECT * FROM product_size WHERE sale_price < (regular_price/2);

# Q5) Which Canva size costs the most ?
SELECT * FROM product_size ORDER BY sale_price DESC LIMIT 1; 

# Q6) Delette Duplicate records from work, product_size, subject and image_link tables ?
DELETE w1
FROM work w1
LEFT JOIN (
    SELECT MIN(work_id) AS min_work_id
    FROM work
    GROUP BY work_id
) AS w2 ON w1.work_id = w2.min_work_id
WHERE w2.min_work_id IS NULL;

DELETE ps1
FROM product_size ps1
LEFT JOIN (
    SELECT MIN(ctid) AS min_ctid
    FROM product_size
    GROUP BY work_id, size_id
) AS ps2 ON ps1.ctid = ps2.min_ctid
WHERE ps2.min_ctid IS NULL;

DELETE s1
FROM subject s1
LEFT JOIN (
    SELECT MIN(ctid) AS min_ctid
    FROM subject
    GROUP BY work_id, subject
) AS s2 ON s1.ctid = s2.min_ctid
WHERE s2.min_ctid IS NULL;

DELETE il1
FROM image_link il1
LEFT JOIN (
    SELECT MIN(ctid) AS min_ctid
    FROM image_link
    GROUP BY work_id
) AS il2 ON il1.ctid = il2.min_ctid
WHERE il2.min_ctid IS NULL;

# Q7) Identify the museums with invalid city information in the given dataset ?
SELECT * FROM museum WHERE city REGEXP '^[0-9]';

# Q8) Museum_hrs table has 1 invalid entry. Identify it and remove it 
DELETE mh
FROM museum_hours mh
LEFT JOIN (
    SELECT MIN(ctid) AS min_ctid
    FROM museum_hours
    GROUP BY museum_id
) AS mh_min ON mh.ctid = mh_min.min_ctid
WHERE mh_min.min_ctid IS NULL;

# Q9) Fetch the top 10 most famous paintings subject ?
SELECT * FROM subject ORDER BY product_size DESC ;

# Q10) Identify the museums which are open on both Sunday & Monday. Display museum_name, city.
SELECT * FROM museum_hours AS mh1 WHERE day="Sunday" 
and exists (SELECT 1 from museum_hours mh2
             WHERE mh1.museum_id=mh2.museum_id
             AND mh2.day="Monday");
             
# Q11) How many museums are open every single day?

SELECT count(1)
FROM (SELECT museum_id, count(1)
FROM museum_hours 
GROUP BY (museum_id)
HAVING COUNT(1)=7) x;
             
# Q12) Which are the Top 5 most popular museum ? (Based on no of paintings in museum)
SELECT m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;
    
# Q13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
SELECT a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;

# Q14) Display the 3 least popular canva sizes
SELECT label, no_of_paintings
FROM (
    SELECT cs.label, COUNT(1) AS no_of_paintings,
           DENSE_RANK() OVER (ORDER BY COUNT(1)) AS ranking
    FROM work w
    JOIN product_size ps ON ps.work_id = w.work_id
    JOIN canvas_size cs ON cs.size_id = ps.size_id
    GROUP BY cs.size_id, cs.label
) AS x
WHERE x.ranking <= 3;

# Q15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
SELECT museum_name, city, day, open, close, duration
FROM (
    SELECT m.name AS museum_name, m.state AS city, day, open, close,
           TIMESTAMPDIFF(HOUR, STR_TO_DATE(open, '%h:%i %p'), STR_TO_DATE(close, '%h:%i %p')) AS duration,
           RANK() OVER (ORDER BY TIMESTAMPDIFF(HOUR, STR_TO_DATE(open, '%h:%i %p'), STR_TO_DATE(close, '%h:%i %p')) DESC) AS rnk
    FROM museum_hours mh
    JOIN museum m ON m.museum_id = mh.museum_id
) AS x
WHERE x.rnk = 1;


