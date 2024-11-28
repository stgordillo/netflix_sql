--Checking out the columns--
SELECT *
FROM nflx
LIMIT 10;

--Changing column names to be recognizable and also because cast is already a SQL function--
ALTER TABLE nflx
RENAME COLUMN type TO kind;

ALTER TABLE nflx
RENAME COLUMN "cast" TO cast_members;

ALTER TABLE nflx
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
FROM nflx;
--2634 nulls found in director, 825 in cast_members, 831 in country, 10 in date_added, 4 in rating, and 3 in duration--
--I'm going to replace the nulls in director with "unknown", drop cast_members, country, and description since I won't need them to find the answers to my business questions and delete the rows of missing data in the rest--

--Dropping unneeded columns--
ALTER TABLE nflx DROP COLUMN cast_members, 
	DROP COLUMN country, 
	DROP COLUMN description;

--Deleting rows with nulls in date_added, rating and duration--
--Checking the data first before deleting it--
SELECT * FROM nflx
WHERE date_added IS NULL OR rating IS NULL OR duration IS NULL;
--17 rows in total--
DELETE FROM nflx
WHERE date_added IS NULL OR rating IS NULL OR duration IS NULL;

--Removing "TV", "Show", and "Movies" from the genres column since I already have a column that describes where it is a Movie or a TV Show--
UPDATE nflx
SET genres = REPLACE(genres, 'TV', '');

UPDATE nflx
SET genres = REPLACE(genres, 'Shows', '');

UPDATE nflx
SET genres = REPLACE(genres, 'Movies', '');

--Dividing each genre up into individual categories--
