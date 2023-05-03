--
-- Queries
--

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract covid in the US

SELECT location, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_deaths
order by 1,2;

-- Improved code to get total count of rows
SELECT location, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage, 
       COUNT(*) OVER() as TotalCount
FROM covid_deaths
ORDER BY 2 DESC;

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract covid in the United States

SELECT location, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_deaths
WHERE location = "United States"
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_deaths/population)*100 as DeathPercentage
FROM covid_deaths
order by 1,2;

-- Looking at countries with highest infection rate compared to populations.

SELECT location, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
FROM covid_deaths
order by 1,2;

-- Looking at countries with highest infection rate compared to population.

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_deaths
GROUP BY location, population
order by PercentPopulationInfected desc;

-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS FLOAT)) as total_death_count
FROM covid_deaths
GROUP BY location
order by total_death_count desc;

-- Breakdown by continent

SELECT continent, MAX(CAST(total_deaths AS FLOAT)) as total_death_count
FROM covid_deaths
WHERE continent is not null
-- WHERE location = "United States"
GROUP BY continent
order by total_death_count desc;

-- Second Version

SELECT location, continent, MAX(CAST(total_deaths AS FLOAT)) as total_death_count
FROM covid_deaths
WHERE continent = ""
GROUP BY continent, location
order by total_death_count desc;

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM covid_deaths
WHERE total_cases != "" AND total_deaths != ""
group by date
order by 1,2;

-- Global Totals

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM covid_deaths
WHERE total_cases != "" AND total_deaths != ""
-- group by date
order by 1,2;

-- Join tables for an example

SELECT *
from covid_deaths dea
join covid_vacs vac
	on dea.location = vac.location
    and dea.date = vac.date;

-- Looking at total population vs. vaccinations (joining tables)

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
from covid_deaths dea
join covid_vacs vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ""
order by 1,2,3;

-- Enhanced versions

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinated,
(rolling_vaccinated/population)*100
from covid_deaths dea
join covid_vacs vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ""
order by 2,3;

-- USE CTE example

WITH pop_vs_vac (Continent, Location, Date, Population, NewVac, RollingVac)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
-- (rolling_vaccinated/population)*100
from covid_deaths dea
join covid_vacs vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ""
-- order by 2,3
)
Select *, (RollingVac/Population)*100
from pop_vs_vac;

-- Temp table example

DROP TABLE IF EXISTS covid_per_pop_vac;

CREATE TABLE covid_per_pop_vac (
  Continent NVARCHAR(255),
  Location NVARCHAR(255),
  Date DATETIME,
  Population NVARCHAR(255),
  New_vaccinations NVARCHAR(255),
  Rolling_vaccinated NVARCHAR(255)
);

INSERT INTO covid_per_pop_vac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_vaccinated
FROM covid_deaths dea
JOIN covid_vacs vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != "";

SELECT *, (Rolling_vaccinated/Population)*100
FROM PerPopVac;

--
-- Views
--

-- Create view to store data for later vizualizations

Create View covid_percent_population_vaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_vaccinated
FROM covid_deaths dea
JOIN covid_vacs vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != "";
SELECT *, (Rolling_vaccinated/Population)*100
FROM covid_per_pop_vac;

