#1. Who is the senior most employee based on job title?
select * from employee order by levels desc limit 1;

#2. Which countries have the most Invoices?
select billing_country,count(*) as invoice_count 
from invoice group by billing_country 
order by invoice_count desc limit 1;

#3. What are top 3 values of total invoice?
select * from invoice order by total desc limit 3;

#Which city has the best customers?  Write a query that returns one city that has the highest sum of invoice totals.
select billing_city, sum(total) as sum_total from invoice group by billing_city order by sum_total desc limit 1;

#5. Who is the best customer? Write a query that returns the person who has spent the most money
select c.first_name, c.last_name, i.customer_id ,sum(i.total) as sum_total 
from customer as c ,invoice as i 
where c.customer_id=i.customer_id
group by i.customer_id order by sum_total desc limit 1;

#1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select c.email,c.first_name,c.last_name,g.name 
from customer c,invoice_line i,track t, genre g, invoice iv
where  iv.customer_id=c.customer_id and iv.invoice_id=i.invoice_id  and i.track_id=t.track_id and t.genre_id= g.genre_id
and g.name= 'Rock' and c.email like 'A%' order by c.email;

#2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
select a.name ,count(al.artist_id) as ct
from artist a, album al, track t 
where a.artist_id=al.artist_id and al.album_id=t.album_id and track_id in
(select track_id from track 
join genre on track.genre_id=genre.genre_id 
where genre.name='Rock' )
group by a.artist_id order by ct desc limit 10;


#3. Return Name and Milliseconds for all the track names that have a song length longer than the average song length.Order by the song length  
select name, milliseconds  from track 
where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc;

#1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

#2. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


#3.  Write a query that returns the country along with the top customer and how much they spent.
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1 

