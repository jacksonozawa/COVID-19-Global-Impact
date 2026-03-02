-- TABLEAU QUERIES
-- These were the primary tables used to for the visualizations in my Tableau dashboard.

-- Overall Country Data
WITH CountryStats AS
  (
  SELECT dea.location AS country, MAX(dea.total_cases) AS total_cases, MAX(dea.population) AS population, MAX(dea.total_deaths) AS total_deaths, MAX (vac.people_vaccinated) AS total_vaccinated
  FROM `CovidData.covid_deaths` dea
  JOIN `CovidData.covid_vaccinations` vac
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  GROUP BY 1
  )
SELECT country, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_rate, (total_vaccinated/population)*100 AS vaccination_rate
FROM CountryStats
ORDER BY country;

-- Time Trend (Global Deaths vs Vaccinations)
WITH GlobalTrend AS
  (
   SELECT 
        dea.date,
        SUM(dea.new_deaths) AS total_deaths,
        SUM(vac.new_vaccinations) AS total_vaccinations
    FROM `CovidData.covid_deaths` dea
    JOIN `CovidData.covid_vaccinations` vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    GROUP BY dea.date
  )
SELECT date
, SUM(total_deaths) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rolling_death_count
, SUM(total_vaccinations) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rolling_vaccination_count
FROM GlobalTrend
ORDER BY date;