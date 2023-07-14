USE portfolioproject;

CREATE TABLE coviddeaths (
  id INT AUTO_INCREMENT NOT NULL,
  iso_code VARCHAR(20),
  continent VARCHAR(20),
  location VARCHAR(20),
  date DATE,
  population BIGINT,
  total_cases VARCHAR(20),
  new_cases INT,
  new_cases_smoothed VARCHAR(20),
  total_deaths VARCHAR(20),
  new_deaths VARCHAR(20),
  new_deaths_smoothed VARCHAR(20),
  total_cases_per_million VARCHAR(20),
  new_cases_per_million VARCHAR(20),
  new_cases_smoothed_per_million VARCHAR(20),
  total_deaths_per_million VARCHAR(20),
  new_deaths_per_million VARCHAR(20),
  new_deaths_smoothed_per_million VARCHAR(20),
  reproduction_rate VARCHAR(20),
  icu_patients VARCHAR(20),
  icu_patients_per_million VARCHAR(20),
  hosp_patients VARCHAR(20),
  hosp_patients_per_million VARCHAR(20),
  weekly_icu_admissions VARCHAR(20),
  weekly_icu_admissions_per_million VARCHAR(20),
  weekly_hosp_admissions VARCHAR(20),
  weekly_hosp_admissions_per_million VARCHAR(20)
);

SELECT * FROM coviddeaths;

SHOW VARIABLES LIKE "local_infile";
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/portfolioproject/CovidDeaths.csv'
INTO TABLE coviddeaths
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SELECT COUNT(*) FROM coviddeaths;

CREATE TABLE covidvaccinations (
  iso_code VARCHAR(20),
  continent VARCHAR(20),
  location VARCHAR(20),
  date DATE,
  new_tests VARCHAR(20),
  total_tests VARCHAR(20),
  total_tests_per_thousand VARCHAR(20),
  new_tests_per_thousand VARCHAR(20),
  new_tests_smoothed VARCHAR(20),
  new_tests_smoothed_per_thousand VARCHAR(20),
  positive_rate VARCHAR(20),
  tests_per_case VARCHAR(20),
  tests_units VARCHAR(20),
  total_vaccinations VARCHAR(20),
  people_vaccinated VARCHAR(20),
  people_fully_vaccinated VARCHAR(20),
  new_vaccinations VARCHAR(20),
  new_vaccinations_smoothed VARCHAR(20),
  total_vaccinations_per_hundred VARCHAR(20),
  people_vaccinated_per_hundred VARCHAR(20),
  people_fully_vaccinated_per_hundred VARCHAR(20),
  new_vaccinations_smoothed_per_million VARCHAR(20),
  stringency_index VARCHAR(20),
  population_density VARCHAR(20),
  median_age VARCHAR(20),
  aged_65_older VARCHAR(20),
  aged_70_older VARCHAR(20),
  gdp_per_capita VARCHAR(20),
  extreme_poverty VARCHAR(20),
  cardiovasc_death_rate VARCHAR(20),
  diabetes_prevalence VARCHAR(20),
  female_smokers VARCHAR(20),
  male_smokers VARCHAR(20),
  handwashing_facilities VARCHAR(20),
  hospital_beds_per_thousand VARCHAR(20),
  life_expectancy VARCHAR(20),
  human_development_index VARCHAR(20)
  );
  
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/portfolioproject/CovidVaccinations.csv'
INTO TABLE covidvaccinations
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SELECT COUNT(*) FROM covidvaccinations;

SELECT * FROM coviddeaths;
SELECT * FROM covidvaccinations;

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT * FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- -- select data that we are going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

-- looking at the total cases vs total deaths in Bangladesh
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE location LIKE '%bangladesh%'
ORDER BY 1,2;

-- looking at the total cases vs the population
-- shows what percentages of population has gotten covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentpopulationinfected
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- looking at countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS highestinfectioncount, MAX((total_cases/population))*100 AS percentpopulationinfected
FROM coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY percentpopulationinfected DESC;

-- showing the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS totaldeathcount
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing the continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS totaldeathcount
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- global numbers
SELECT date, SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS totalcases, SUM(new_deaths) AS totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- joining coviddeaths and covidvaccinations
SELECT * 
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date;

-- looking at total population vs vaccinations
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date
ORDER BY 2,3;

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location 
	ORDER BY death.location, death.date) AS rollingpeoplevaccinated
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date
ORDER BY 2,3;

-- looking at total population vs vaccinations
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY death.location 
	ORDER BY death.location, death.date) AS rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date
ORDER BY 2,3;

-- using CTE to perform calculation on partition by in previous query
WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS (
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY death.location 
	ORDER BY death.location, death.date) AS rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date
-- ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac;


-- using temp table to perform calculation on partition by in previous query
DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TEMPORARY TABLE percentpopulationvaccinated (
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rollingpeoplevaccinated NUMERIC
);
INSERT INTO percentpopulationvaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY death.location 
	ORDER BY death.location, death.date) AS rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date;
-- ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100 AS roll_ppl_vaccinated
FROM percentpopulationvaccinated;

-- creating view to store data for later visualizations
CREATE VIEW percentpopulationvaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY death.location 
	ORDER BY death.location, death.date) AS rollingpeoplevaccinated
    -- (rollingpeoplevaccinated/population)*100
FROM coviddeaths death
JOIN covidvaccinations vac 
	ON death.location = vac.location
	AND death.date = vac.date
    WHERE death.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated;






