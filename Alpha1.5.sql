--VERIFYING UPLOADED DATA

SELECT *
FROM yuro..CovidDeaths
ORDER BY 3, 4

SELECT *
FROM yuro..CovidVaccinations
ORDER BY 3, 4

--SELECTING SPECIFIC DATA

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM yuro..CovidDeaths
ORDER BY 2, 3

--LOOKING AT TOTAL CASES PER TOTAL DEATHS
--percentage of deaths per location

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentageDeaths
FROM yuro..CovidDeaths
ORDER BY 2, 3 

--percentage of deaths in my country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentageDeaths
FROM yuro..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1, 2 

--LOOKING AT TOTAL CASES VS POPULATION OF NIGERIA
--query shows the percentage of nigerians that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentageInfected
FROM yuro..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1, 2 

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE PER LOCATION
--query alos shows percentage of infected
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS percentageInfected
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY PercentageInfected DESC

--LOOKING AT COUNTRIES WITH THE HIGHEST DEATH RATE
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathRate
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY HighestDeathRate DESC

--because of the duplicate values in continent and contry columns, I have to make the continent not null

SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathRate
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not NULL
GROUP BY location
ORDER BY HighestDeathRate DESC

--LOOKING AT THE DATA AS PER CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathRate
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY HighestDeathRate DESC

--LOOKING AT GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM yuro..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2 

--JOINING BOTH TABLES UPLOADED EARLIER
--query below shows the Total Population Vs Caccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM yuro..CovidDeaths dea
JOIN yuro..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3

--LOOKING AT THE ROLLING COUNT OF THE VALUES

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM yuro..CovidDeaths dea
JOIN yuro..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3

--USING CTE

WITH popuVSvac  (continent, location, date, population, new_vaccinations, RollingPeopleCount)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM yuro..CovidDeaths dea
JOIN yuro..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleCount/population)*100
FROM popuVSvac

--CREATING VIEWS FOR VISUALIZATION

create view  popuVSvac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM yuro..CovidDeaths dea
JOIN yuro..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2, 3

SELECT *
FROM popuVSvac

--MODIFYING QUERIES FOR TABLEAU VISUALIZATIONS
--1

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM yuro..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2 

--2 filtering the continent and location columns to remove duplicate entries

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathRate
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is NULL
AND location not IN ('World', 'European Union', 'International')
AND location not like '%income%'
GROUP BY location
ORDER BY TotalDeathRate DESC

--3
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS percentageInfected
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY PercentageInfected DESC

-- Factoring in the date
--4

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS percentageInfected
FROM yuro..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population, date
ORDER BY PercentageInfected DESC

