--Checking out the columns--
SELECT *
FROM netflix_2021
LIMIT 10;

--Changing column names to be recognizable and also because cast is already a SQL function--
ALTER TABLE netflix_2021
RENAME COLUMN type TO movie_or_show;

ALTER TABLE netflix_2021
RENAME COLUMN "cast" TO cast_members;

ALTER TABLE netflix_2021
RENAME COLUMN listed_in TO genres;

--Finding the nulls in each column--
SELECT 
	SUM(CASE WHEN show_id IS NULL THEN 1 ELSE 0 END) AS show_id_nulls,
	SUM(CASE WHEN kind IS NULL THEN 1 ELSE 0 END) AS type_nulls,
	SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
	SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_nulls,
	SUM(CASE WHEN cast_members IS NULL THEN 1 ELSE 0 END) AS cast_nulls,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
	SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_added_nulls,
	SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS release_year_nulls,
	SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
	SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
	SUM(CASE WHEN genres IS NULL THEN 1 ELSE 0 END) AS genres_nulls,
	SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description_nulls
FROM netflix_2021;
--2634 nulls found in director, 825 in cast_members, 831 in country, 10 in date_added, 4 in rating, and 3 in duration--
--I'm going to replace the nulls in director with "unknown", drop cast_members, country, and description since I won't need them to find the answers to my business questions and delete the rows of missing data in the rest--

--Dropping unneeded columns--
ALTER TABLE netflix_2021 DROP COLUMN cast_members, 
	DROP COLUMN country, 
	DROP COLUMN description;

--Deleting rows with nulls in date_added, rating and duration--
--Checking the data first before deleting it--
SELECT * FROM netflix_2021
WHERE date_added IS NULL 
	OR rating IS NULL 
	OR duration IS NULL;
--17 rows in total--
DELETE FROM netflix_2021
WHERE date_added IS NULL 
	OR rating IS NULL 
	OR duration IS NULL;

--Checking out what countries make the most movies
SELECT country, COUNT(country) AS most
FROM netflix_2021
GROUP BY country
ORDER BY most DESC;

--Most popularly produced genres on Netflix--
SELECT genres, COUNT(genres) AS most_produced_genres
FROM netflix_2021
GROUP by genres
ORDER BY most_produced_genres DESC;

--How many shows are on Netflix compared to movies?--
SELECT
	(SELECT COUNT(movie_or_show)
	FROM netflix_2021
	WHERE movie_or_show = 'Movie') AS movie,
	COUNT(movie_or_show) AS show
FROM netflix_2021
WHERE movie_or_show = 'TV Show';
