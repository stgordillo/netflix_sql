--Checking out the columns--
SELECT *
FROM netflix_2021
LIMIT 10;

--Changing column names to be recognizable and also because cast and type are already  SQL commands--
ALTER TABLE netflix_2021
RENAME COLUMN type TO movie_or_show;

ALTER TABLE netflix_2021
RENAME COLUMN "cast" TO cast_members;

ALTER TABLE netflix_2021
RENAME COLUMN listed_in TO genre;

--Finding the nulls in each column--
SELECT 
	SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
	SUM(CASE WHEN movie_or_show IS NULL THEN 1 ELSE 0 END) AS type_nulls,
	SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
	SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_nulls,
	SUM(CASE WHEN cast_members IS NULL THEN 1 ELSE 0 END) AS cast_nulls,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
	SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_added_nulls,
	SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS release_year_nulls,
	SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
	SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
	SUM(CASE WHEN genre IS NULL THEN 1 ELSE 0 END) AS genre_nulls,
	SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description_nulls
FROM netflix_2021;
/* 2634 nulls found in director, 825 in cast_members, 831 in country, 10 in date_added, 4 in rating, and 3 in duration
I'm going to leave the nulls in director and country so I don't use them in analysis,
drop cast_members and description since I won't need them to find the answers to my business questions 
and delete the rows of missing data in the rest */

--Dropping unneeded columns--
ALTER TABLE netflix_2021 DROP COLUMN cast_members, 
	DROP COLUMN description;

/* Deleting rows with nulls in date_added, rating and duration
Checking the data first before deleting it */
/*
SELECT * FROM netflix_2021
WHERE date_added IS NULL 
	OR rating IS NULL 
	OR duration IS NULL;
*/
--17 rows in total
DELETE FROM netflix_2021
WHERE date_added IS NULL 
	OR rating IS NULL 
	OR duration IS NULL;

--What countries make the most tv shows and movies?
SELECT country, COUNT(country) AS media_per_country
FROM netflix_2021
GROUP BY country
ORDER BY media_per_country DESC;
/* The United States has the most media by far at 2809 on Netflix 
India is the next most at 972 followed by United Kingdom, Japan and South Korea */

--Who are the most prolific directors represented on Netflix?
SELECT director, COUNT(director) AS director_count
FROM netflix_2021
GROUP BY director
ORDER BY director_count DESC
LIMIT 10;
/* The top director on Netflix is Rajiv Chilaka, who makes Indian children's shows
Many of the top directors create comedy shows/specials or children's shows */

--Most popularly produced genre on Netflix--
SELECT genre, COUNT(genre) AS most_produced_genre
FROM netflix_2021
GROUP by genre
ORDER BY most_produced_genre DESC;
/* Most popular genres are Dramas, Documentaries, Stand-Up Comedy Specials and Children's media (movies or shows)
This seems to line up with the kinds of top directors that we saw in the previous query*/

--How many shows are on Netflix compared to movies?--
SELECT
	(SELECT COUNT(movie_or_show)
	FROM netflix_2021
	WHERE movie_or_show = 'Movie') AS movie,
	COUNT(movie_or_show) AS show
FROM netflix_2021
WHERE movie_or_show = 'TV Show';
/* 
*/

--What genre are most common for Movies?--
SELECT  
    genre,
    COUNT(CASE WHEN movie_or_show = 'Movie' THEN 1 END) AS movie_count
FROM netflix_2021
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 5;

--Also, what genre are most common for TV Shows?--
SELECT  
    genre,
    COUNT(CASE WHEN movie_or_show = 'TV Show' THEN 1 END) AS show_count
FROM netflix_2021
GROUP BY genre
ORDER BY show_count DESC
LIMIT 5;

--Ratings for each Movie on Netflix--
WITH total_ratings AS 
	(SELECT COUNT(CASE WHEN rating = 'G' THEN 1 END) AS g_rating,
	COUNT(CASE WHEN rating = 'PG' THEN 1 END) AS pg_rating,
	COUNT(CASE WHEN rating = 'PG-13' THEN 1 END) AS pg13_rating,
	COUNT(CASE WHEN rating = 'R' THEN 1 END) AS r_rating,
	COUNT(CASE WHEN rating = 'NC-17' THEN 1 END) AS nc17_rating,
	COUNT(CASE WHEN rating = 'UR' or rating = 'NR' THEN 1 END) AS unrated_rating
    FROM netflix_2021)
SELECT *,
       (g_rating + pg_rating + pg13_rating + r_rating + nc17_rating + unrated_rating) AS total_movie_ratings
FROM total_ratings;

--Ratings for each TV Show on Netflix using a Common Table Expression--
WITH total_ratings AS 
	(SELECT COUNT(CASE WHEN rating = 'TV-Y' THEN 1 END) AS tvy_rating,
	COUNT(CASE WHEN rating = 'TV-Y7' OR rating = 'TV-Y7-FA' THEN 1 END) AS tvy7_rating,
	COUNT(CASE WHEN rating = 'TV-G' THEN 1 END) AS tvg_rating,
	COUNT(CASE WHEN rating = 'TV-14' THEN 1 END) AS tv14_rating,
	COUNT(CASE WHEN rating = 'TV-PG' THEN 1 END) AS tvpg_rating,
	COUNT(CASE WHEN rating = 'TV-MA' THEN 1 END) AS tvma_rating
	FROM netflix_2021)
SELECT *,
       (tvy_rating + tvy7_rating + tvg_rating + tv14_rating + tvpg_rating + tvma_rating) AS total_tv_ratings
FROM total_ratings;


--What's the percentage of ratings per genre?--
SELECT 
    genre,
    rating,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY genre), 2) AS percent_of_genres
FROM netflix_2021
GROUP BY genre, rating
ORDER BY genre, percent_of_genres DESC;

--How has the number of titles added to Netflix changed over time?--
SELECT 
    DATE_PART('year', date_added) AS year_streamed,
    COUNT(*) AS title_count
FROM netflix_2021
WHERE date_added IS NOT NULL
GROUP BY DATE_PART('year', date_added)
ORDER BY year_streamed;

--Are there seasonal trends in content releases?--
--A. Total titles released per season--

SELECT 
    CASE
        WHEN DATE_PART('month', date_added) IN (12, 1, 2) THEN 'Winter'
        WHEN DATE_PART('month', date_added) IN (3, 4, 5) THEN 'Spring'
        WHEN DATE_PART('month', date_added) IN (6, 7, 8) THEN 'Summer'
        WHEN DATE_PART('month', date_added) IN (9, 10, 11) THEN 'Fall'
    END AS season,
    COUNT(*) AS title_count
FROM netflix_2021
WHERE date_added IS NOT NULL
GROUP BY season
ORDER BY title_count DESC;

--B. Top 3 genre realeased per season along with number of titles each--
WITH season_genre_counts AS (
    SELECT 
        CASE
            WHEN DATE_PART('month', date_added) IN (12, 1, 2) THEN 'Winter'
            WHEN DATE_PART('month', date_added) IN (3, 4, 5) THEN 'Spring'
            WHEN DATE_PART('month', date_added) IN (6, 7, 8) THEN 'Summer'
            WHEN DATE_PART('month', date_added) IN (9, 10, 11) THEN 'Fall'
        END AS season,
        genre,
        COUNT(*) AS title_count,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CASE
                    WHEN DATE_PART('month', date_added) IN (12, 1, 2) THEN 'Winter'
                    WHEN DATE_PART('month', date_added) IN (3, 4, 5) THEN 'Spring'
                    WHEN DATE_PART('month', date_added) IN (6, 7, 8) THEN 'Summer'
                    WHEN DATE_PART('month', date_added) IN (9, 10, 11) THEN 'Fall'
                END
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM netflix_2021
    WHERE date_added IS NOT NULL
    GROUP BY season, genre
)
SELECT season, genre, title_count
FROM season_genre_counts
WHERE rank <= 3
ORDER BY season, rank;

--C. Combined above, Top 3 genre per season, title count by genre per season, total titles released per season--
WITH season_genre_counts AS (
    SELECT 
        CASE
            WHEN DATE_PART('month', date_added) IN (12, 1, 2) THEN 'Winter'
            WHEN DATE_PART('month', date_added) IN (3, 4, 5) THEN 'Spring'
            WHEN DATE_PART('month', date_added) IN (6, 7, 8) THEN 'Summer'
            WHEN DATE_PART('month', date_added) IN (9, 10, 11) THEN 'Fall'
        END AS season,
        genre,
        COUNT(*) AS title_count,
        SUM(COUNT(*)) OVER (
            PARTITION BY 
                CASE
                    WHEN DATE_PART('month', date_added) IN (12, 1, 2) THEN 'Winter'
                    WHEN DATE_PART('month', date_added) IN (3, 4, 5) THEN 'Spring'
                    WHEN DATE_PART('month', date_added) IN (6, 7, 8) THEN 'Summer'
                    WHEN DATE_PART('month', date_added) IN (9, 10, 11) THEN 'Fall'
                END
        ) AS total_titles_per_season,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CASE
                    WHEN DATE_PART('month', date_added) IN (12, 1, 2) THEN 'Winter'
                    WHEN DATE_PART('month', date_added) IN (3, 4, 5) THEN 'Spring'
                    WHEN DATE_PART('month', date_added) IN (6, 7, 8) THEN 'Summer'
                    WHEN DATE_PART('month', date_added) IN (9, 10, 11) THEN 'Fall'
                END
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM netflix_2021
    WHERE date_added IS NOT NULL
    GROUP BY season, genre
)
SELECT season, genre, title_count, total_titles_per_season
FROM season_genre_counts
WHERE rank <= 3
ORDER BY season, rank;
