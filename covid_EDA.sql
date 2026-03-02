-- COUNTRY LEVEL ANALYSIS

-- All Countries in dataset
SELECT DISTINCT location
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL;

-- Total Cases vs Population Over Time (Countries)
-- Shows what percentage of a Country's population contracted COVID at a specfic date
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs Total Deaths Over Time (Countries)
-- Shows fatality rate of COVID at a specific date
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_rate
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs Population Over Time (United States)
-- Shows what percentage of the US contracted COVID at a specific date
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM `CovidData.covid_deaths`
WHERE location LIKE '%United States%'
ORDER BY location, date;

-- Total Cases vs Total Deaths Over Time (United States)
-- Shows fatality rate of COVID in the US at a specific date
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_rate
FROM `CovidData.covid_deaths`
WHERE location LIKE '%United States%'
ORDER BY location, date;
 
--  Countries with highest Infection Count
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS highest_infection_rate
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_count DESC;

--  Countries with highest Infection Rate
SELECT location, population, MAX(total_cases/population)*100 AS highest_infection_rate, MAX(total_cases) AS highest_infection_count
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- Countries with highest Death Count
SELECT location, population, MAX(total_deaths) AS total_death_count, MAX(total_deaths/population)*100 AS highest_fatality_rate
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Countries with highest Fatality Rate
SELECT location, population, MAX(total_deaths/population)*100 AS highest_fatality_rate, MAX(total_deaths) AS total_death_count
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_fatality_rate DESC;

-- CONTINENT LEVEL ANALYSIS

-- To analyze Continents, adjust the WHERE clause to 'continent IS NULL'
-- Example: Continents with highest Infection Rate at any point in time
SELECT location, population, MAX(total_cases/population)*100 AS highest_infection_rate, MAX(total_cases) AS highest_infection_count
FROM `CovidData.covid_deaths`
WHERE continent IS NULL AND location NOT IN ('European Union', 'World', 'International')
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- GLOBAL LEVEL ANALYSIS

-- COVID Cases vs Deaths across the world at a specific date
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS fatality_rate
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Total COVID Cases vs Deaths in the world
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS fatality_rate
FROM `CovidData.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total Vaccinations in the world
SELECT SUM(vac.new_vaccinations) AS total_vaccinations
FROM `CovidData.covid_deaths` dea
JOIN `CovidData.covid_vaccinations` vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


-- ANALYZING BOTH DATASETS (Deaths + Vaccinations)

-- Total Population vs Vaccinations at a specific date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
FROM `CovidData.covid_deaths` dea
JOIN `CovidData.covid_vaccinations` vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Total Population vs Percent Vaccinated at a specfic date (using CTE)
WITH PopvsVac AS 
  (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_count
  FROM `CovidData.covid_deaths` dea
  JOIN `CovidData.covid_vaccinations` vac 
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  ORDER BY 2, 3
  )
SELECT *, (rolling_vaccination_count/population)*100 AS rolling_percent_vaccinated
FROM PopvsVac;

-- Total Vaccination Rate per Country
SELECT dea.location, MAX(dea.population) AS total_population, MAX(vac.people_vaccinated) AS total_vaccinations, MAX(vac.people_vaccinated)/MAX(dea.population)*100 AS vaccination_rate
FROM `CovidData.covid_deaths` dea
JOIN `CovidData.covid_vaccinations` vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY 1
ORDER BY vaccination_rate DESC;

-- Vaccination Rate vs Fatality Rate per Country (using CTE)
WITH CountryStats AS
  (
  SELECT dea.location AS country, MAX(dea.population) AS population, MAX(dea.total_deaths) AS total_deaths, MAX (vac.people_vaccinated) AS total_vaccinated
  FROM `CovidData.covid_deaths` dea
  JOIN `CovidData.covid_vaccinations` vac
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  GROUP BY 1
  )
SELECT country, (total_deaths/population)*100 AS fatality_rate, (total_vaccinated/population)*100 AS vaccination_rate
FROM CountryStats
WHERE total_deaths IS NOT NULL AND total_vaccinated IS NOT NULL
ORDER BY fatality_rate DESC;

-- Vaccination Rate vs Positive Test Rate (using CTE)
WITH CovidVacc AS
  (
  SELECT dea.location AS location, dea.date AS date, (vac.people_vaccinated/dea.population)*100 AS vaccination_rate, vac.positive_rate AS positive_rate
  FROM `CovidData.covid_deaths` dea
  JOIN `CovidData.covid_vaccinations` vac 
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  )
SELECT location, date, vaccination_rate, positive_rate
FROM CovidVacc
WHERE vaccination_rate IS NOT NULL AND positive_rate IS NOT NULL;

-- Vaccination Rate vs Infection Rate (using CTE)
WITH CovidVacc AS
  (
  SELECT dea.location AS location, dea.date AS date, (vac.people_vaccinated/dea.population)*100 AS vaccination_rate, (dea.total_cases/population)*100 AS infection_rate
  FROM `CovidData.covid_deaths` dea
  JOIN `CovidData.covid_vaccinations` vac 
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  )
SELECT location, date, vaccination_rate, infection_rate
FROM CovidVacc
WHERE vaccination_rate IS NOT NULL AND infection_rate IS NOT NULL;

-- GDP per Capita vs Vaccination Rate
SELECT dea.location, MAX(vac.gdp_per_capita) AS gdp_per_capita, MAX(vac.people_vaccinated/dea.population)*100 AS vaccination_rate
FROM `CovidData.covid_deaths` dea
JOIN `CovidData.covid_vaccinations` vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY 1
ORDER BY gdp_per_capita DESC;

-- GDP per Capita vs Fatality Rate
SELECT dea.location, MAX(vac.gdp_per_capita) AS gdp_per_capita, MAX(dea.total_deaths/dea.population)*100 AS fatality_rate
FROM `CovidData.covid_deaths` dea
JOIN `CovidData.covid_vaccinations` vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY 1
ORDER BY fatality_rate DESC;