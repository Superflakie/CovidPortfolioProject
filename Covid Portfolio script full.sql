--1 

SELECT SUM(New_Cases) as Total_Cases, SUM(cast(New_Deaths as bigint)) as Total_Deaths, SUM(cast(New_Deaths as bigint))/SUM(New_Cases) * 100 AS DeathPercentage
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE Continent is not NULL
--GROUP BY date
ORDER BY 1,2


--2
-- Taking these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT Location, SUM(cast(Total_Deaths AS bigint)) AS TotalDeathCount
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent is NULL
AND Location not in ('European union', 'World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'International')
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- 3

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount, MAX((Total_cases/Population)) * 100 AS PercentagePopulationInfected
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

-- 4

DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations, SUM(CONVERT(bigint, Vac.New_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM MyPortfolioProject..CovidDeaths Dea
JOIN MyPortfolioProject..CovidVaccinations Vac
  ON Dea.Location = Vac.Location
  and Dea.Date = Vac.Date
--WHERE dea.Continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentRollingPeopleVaccinated
FROM #PercentagePopulationVaccinated
ORDER BY #PercentagePopulationVaccinated DESC

--5

SELECT Location, Population, Date, MAX(Total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 AS PercentagePopulationInfected
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
GROUP BY Location, population, Date
ORDER BY PercentagePopulationInfected DESC  





SELECT *
FROM MyPortfolioproject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM MyPortfolioproject..CovidVaccinations
WHERE continent is not NULL
--ORDER BY 3,4

-- Select Data that i would use

SELECT Location, Date, Total_cases, New_cases, Total_deaths, population
FROM MyPortfolioproject..CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total deaths
-- shows the possibility of dying if you contract covid in your country

SELECT Location, Date, Total_cases, New_cases, Total_deaths, (Total_Deaths/Total_cases) * 100 AS PercentageDeaths
FROM MyPortfolioproject..CovidDeaths
WHERE location like '%Canada%'
and continent is not NULL
ORDER BY 1,2

-- Looking at the total cases vs Population
-- Shows what percentage of Population that has was infected

SELECT Location, Date, Population, Total_cases, (Total_cases/Population) * 100 AS PercentagePopulationInfected
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
and continent is not NULL
ORDER BY 1,2


-- looking at countries with Highest infection rate compared to population

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount, MAX((Total_cases/Population)) * 100 AS PercentagePopulationInfected
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
and continent is not NULL
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing the Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(Total_Deaths AS bigint)) AS TotalDeathCount
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THIS DOWN BY LOCATION

SELECT location, MAX(cast(Total_Deaths AS bigint)) AS TotalDeathCount
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent is NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THIS DOWN BY CONTINENT

-- Showing the continents with the Highest death Count per population

SELECT Continent, MAX(cast(Total_Deaths AS bigint)) AS TotalDeathCount
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent is not NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Global Numbers


SELECT Date, SUM(New_Cases) as Total_Cases, SUM(cast(New_Deaths as bigint)) as Total_Deaths, SUM(cast(New_Deaths as bigint))/SUM(New_Cases) * 100 AS DeathPercentage
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE Continent is not NULL
GROUP BY Date
ORDER BY 1,2

SELECT SUM(New_Cases) as Total_Cases, SUM(cast(New_Deaths as bigint)) as Total_Deaths, SUM(cast(New_Deaths as bigint))/SUM(New_Cases) * 100 AS DeathPercentage
FROM MyPortfolioproject..CovidDeaths
--WHERE location like '%Canada%'
WHERE Continent is not NULL
--GROUP BY Date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations
, SUM(CONVERT(bigint, Vac.New_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM MyPortfolioProject..CovidDeaths Dea
JOIN MyPortfolioProject..CovidVaccinations Vac
  ON Dea.Location = Vac.Location
  and Dea.Date = Vac.Date
  WHERE dea.Continent is not NULL
  ORDER BY 2,3


  -- Use CTE

  WITH PopvsVac (Continent, Location, Date, POpulation, New_Vaccinations, RollingPeopleVaccinated)
  AS
  (
SELECT dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations, SUM(CONVERT(bigint, Vac.New_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM MyPortfolioProject..CovidDeaths Dea
JOIN MyPortfolioProject..CovidVaccinations Vac
  ON Dea.Location = Vac.Location
  and Dea.Date = Vac.Date
WHERE dea.Continent is not NULL
--ORDER BY 2,3
  )
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

 -- TEMP Table

DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations, SUM(CONVERT(bigint, Vac.New_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM MyPortfolioProject..CovidDeaths Dea
JOIN MyPortfolioProject..CovidVaccinations Vac
  ON Dea.Location = Vac.Location
  and Dea.Date = Vac.Date
--WHERE dea.Continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentRollingPeopleVaccinated
FROM #PercentagePopulationVaccinated


--Creating view to store data for visualisations

CREATE VIEW PercentagePopulationVaccinated as 
SELECT dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_vaccinations, SUM(CONVERT(bigint, Vac.New_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM MyPortfolioProject..CovidDeaths Dea
JOIN MyPortfolioProject..CovidVaccinations Vac
  ON Dea.Location = Vac.Location
  and Dea.Date = Vac.Date
WHERE dea.Continent is not NULL
--ORDER BY 2,3

Select *
FROM PercentagePopulationVaccinated
