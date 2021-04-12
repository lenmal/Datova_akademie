# WEATHER =============================================== Final 
CREATE TABLE t_lenka_pinosova_final_weather AS 
(SELECT w.date
		, w.city
		, w2.avg_temp
		, w3.no_rain_hours
		, max(w.wind) AS max_wind
FROM weather w
	LEFT OUTER JOIN (SELECT date
							, city
							, round(avg(temp),2) AS avg_temp 
					FROM weather 
					WHERE HOUR IN (6,9,12,15,18,21) 
					GROUP BY city, date) w2
		ON w.city = w2.city AND w.date = w2.date
	LEFT OUTER JOIN (SELECT date
							, city
							, count(hour) AS no_rain_hours 
					FROM weather
					WHERE rain != 0 
					GROUP BY city, date) w3
		ON w.city = w3.city AND w.date = w3.date
GROUP BY city, date
);


# RELIGION ============================================== Final 
CREATE TABLE t_lenka_pinosova_final_religion AS 
(SELECT r.country 
		, r.religion
	   , r.population 
	   , r2.total_population_2020
	   , round(100*r.population/r2.total_population_2020, 2) as religion_share_2020
	   , CASE WHEN r.religion = 'Christianity' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS christianity
	   , CASE WHEN r.religion = 'Islam' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS islam
	   , CASE WHEN r.religion = 'Unaffiliated Religions' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS unaff_relig
	   , CASE WHEN r.religion = 'Hinduism' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS hinduism
	   , CASE WHEN r.religion = 'Buddhism' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS buddhism
	   , CASE WHEN r.religion = 'Folk Religions' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS folk_relig
	   , CASE WHEN r.religion = 'Other Religions' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS other_relig
	   , CASE WHEN r.religion = 'Judaims' THEN round(100*r.population/r2.total_population_2020,2) ELSE NULL END AS judaims
FROM religions r 
	JOIN (SELECT r.country
				, r.YEAR
				,  SUM(r.population) AS total_population_2020
        	FROM religions  r 
       		WHERE r.year = 2020 AND r.country != "All Countries" AND population >0
        	GROUP BY r.country) r2
    ON r.country = r2.country AND r.year = r2.YEAR
WHERE r.YEAR = 2020 AND r.country != "All Countries" AND population >0
);


# LIFE_EXPECTANCY ======================================= Final 
CREATE TABLE t_lenka_pinosova_final_life AS 
(SELECT le65.country
		, le65.life_exp_1965 
		, le15.life_exp_2015
		, round(le15.life_exp_2015 - le65.life_exp_1965, 2 ) as life_exp_diff
FROM (SELECT le.country 
		, le.life_expectancy as life_exp_1965
    	FROM life_expectancy le 
   		WHERE year = 1965) le65 
    JOIN 
    	(SELECT le.country 
    		, le.life_expectancy as life_exp_2015
    	FROM life_expectancy le 
   		WHERE year = 2015) le15
    ON le65.country = le15.country
   );
   

# COUNTRIES, ECONOMIES, LOOKUP_TABLE, RELIGIONS, LIFE_EXPECTANCY =========== Final
CREATE TABLE t_lenka_pinosova_final_countries AS 
(SELECT c.country AS c_country
	, c.population 
	, round(c.population/c.surface_area,2) AS calc_pop_density
	, c.median_age_2018
	, c.iso3 
	, c.north 
	, lt.country AS lt_country
	, CASE WHEN lt.country != NULL THEN lt.country ELSE c.country END AS new_country
	, round(e.gdp/c.population,0) AS gdp_per_capita_2018
	, e.gini AS gini_koef_2018
	, e.mortaliy_under5 
	, CASE WHEN c.capital_city = "Athenai" THEN REPLACE (c.capital_city, "Athenai", "Athens")
 				WHEN c.capital_city = "Praha" THEN  REPLACE (c.capital_city, "Praha", "Prague") 
 				WHEN c.capital_city = "Bruxelles [Brussel]" THEN REPLACE (c.capital_city, "Bruxelles [Brussel]", "Brussels")
 				WHEN c.capital_city = "Bucuresti" THEN REPLACE (c.capital_city, "Bucuresti", "Bucharest")
				WHEN c.capital_city = "Chisinau" THEN REPLACE (c.capital_city, "Chisinau", "Chisinas") 
				WHEN c.capital_city = "Helsinki [Helsingfors]" THEN REPLACE (c.capital_city, "Helsinki [Helsingfors]", "Helsinki") 
				WHEN c.capital_city = "Kyiv" THEN REPLACE (c.capital_city, "Kyiv", "Kiev")
				WHEN c.capital_city = "Lisboa" THEN REPLACE (c.capital_city, "Lisboa", "Lisbon")
				WHEN c.capital_city = "Luxembourg [Luxemburg/L" THEN REPLACE (c.capital_city, "Luxembourg [Luxemburg/L", "Luxembourg")
				WHEN c.capital_city = "Roma" THEN REPLACE (c.capital_city, "Roma", "Rome") 
				WHEN c.capital_city = "Tallinn" THEN REPLACE (c.capital_city, "Tallinn", "Tallin")
				WHEN c.capital_city = "Wien" THEN REPLACE (c.capital_city, "Wien", "Vienna") 
				WHEN c.capital_city = "Warszawa" THEN REPLACE (c.capital_city, "Warszawa", "Warsaw")  				
 				ELSE c.capital_city END AS capital_city_uprava
 	, sum(freligion.christianity) AS christianity
 	, sum(freligion.islam) AS islam
 	, sum(freligion.unaff_relig) AS unaff_relig
 	, sum(freligion.hinduism) AS hinduism
 	, sum(freligion.buddhism) AS buddhism
 	, sum(freligion.folk_relig) AS folk_relig
 	, sum(freligion.other_relig) AS other_relig
 	, sum(freligion.judaims) AS judaism
 	, flife.life_exp_diff
 FROM countries c
	LEFT OUTER JOIN (SELECT DISTINCT country, iso3 FROM lookup_table) lt ON c.iso3 = lt.iso3 AND c.country =lt.country
	LEFT OUTER JOIN (SELECT * FROM economies WHERE YEAR = 2018) e ON c.country = e.country
	LEFT OUTER JOIN t_lenka_pinosova_final_religion freligion ON c.country = freligion.country
	LEFT OUTER JOIN t_lenka_pinosova_final_life flife ON c.country = flife.country
GROUP BY c.country
);


# Covid19_diff & tests ======================================== Final 
CREATE TABLE t_lenka_pinosova_final_covid AS  
(SELECT  cbd.date
		, cbd.country
		, cbd.confirmed
		, cbd.deaths
		, cbd.recovered
		, ct.tests_performed
FROM covid19_basic_differences cbd 
	LEFT OUTER JOIN 
		(SELECT date
			, CASE WHEN country = "Czech Republic" THEN  REPLACE (country, "Czech Republic", "Czechia")
					WHEN country = "Democratic Republic of Congo" THEN REPLACE (country, "Democratic Republic of Congo", "Congo (Kinshasa)")
					WHEN country = "Macedonia" THEN REPLACE (country, "Macedonia", "North Macedonia")
					WHEN country = "South Korea" THEN REPLACE (country, "South Korea", "Korea South")
					WHEN country = "Taiwan" THEN REPLACE (country, "Taiwan", "Taiwan*")
					WHEN country = "United States" THEN REPLACE (country, "United States", "US") 
					ELSE country END AS rename_country
			, tests_performed 
		FROM covid19_tests 
		WHERE tests_performed != 0 and date >"2020-01-22"
		GROUP BY date, country) ct 
	ON cbd.country = ct.rename_country AND cbd.date = ct.date
);


# Final table ==========================================================10min
CREATE TABLE t_lenka_pinosova_final_sql as
(SELECT fcovid.date 
	, fcovid.country 
	, CASE WHEN weekday (fcovid.date) BETWEEN 0 AND 4 
			THEN 0 
			ELSE 1 END AS week_day
	, if (fcountry.north > 0,
			(CASE WHEN DATE_FORMAT(fcovid.date, "%m.%d") BETWEEN "03.20" AND "06.19" THEN 0
			WHEN DATE_FORMAT(fcovid.date, "%m.%d") BETWEEN "06.20" AND "09.20" THEN 1
			WHEN DATE_FORMAT(fcovid.date, "%m.%d") BETWEEN "09.22" AND "12.20" THEN 2
			ELSE 3 END),
			(CASE WHEN DATE_FORMAT(fcovid.date, "%m.%d") BETWEEN "03.20" AND "06.19" THEN 2
			WHEN DATE_FORMAT(fcovid.date, "%m.%d") BETWEEN "06.20" AND "09.20" THEN 3
			WHEN DATE_FORMAT(fcovid.date, "%m.%d") BETWEEN "09.22" AND "12.20" THEN 0
			ELSE 1 END)) AS year_season
	, fcovid.confirmed
	, fcovid.deaths
	, fcovid.recovered
	, fcovid.tests_performed
	, CASE WHEN fcovid.tests_performed > 0 
			THEN round(100*fcovid.confirmed/fcovid.tests_performed,2)
			ELSE NULL END AS positiv_in_percent
	, fcountry.population
	, fcountry.calc_pop_density
	, fcountry.gdp_per_capita_2018
	, fcountry.gini_koef_2018
	, fcountry.median_age_2018
	, fcountry.mortaliy_under5
	, fcountry.life_exp_diff
	, fcountry.christianity 
	, fcountry.islam 
	, fcountry.unaff_relig 
	, fcountry.hinduism  
	, fcountry.buddhism 
	, fcountry.folk_relig 
	, fcountry.other_relig
	, fcountry.judaism 
	, fweather.avg_temp
	, fweather.no_rain_hours
	, fweather.max_wind 
FROM t_lenka_pinosova_final_covid fcovid
	LEFT OUTER JOIN t_lenka_pinosova_final_countries fcountry 
		ON fcovid.country = fcountry.new_country  
	LEFT OUTER JOIN t_lenka_pinosova_final_weather fweather 
		ON fweather.city =fcountry.capital_city_uprava AND fweather.date =fcovid.date
);


# Mazání pomocných tabulek =========================================
DROP TABLE t_lenka_pinosova_final_countries
, t_lenka_pinosova_final_religion
, t_lenka_pinosova_final_life
, t_lenka_pinosova_final_weather 
, t_lenka_pinosova_final_covid 
;



