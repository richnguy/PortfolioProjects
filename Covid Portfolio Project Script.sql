SELECT
	*
FROM 
	PortfolioProject..CovidDeaths
ORDER BY
	3,
	4

--SELECT
--	*
--FROM
--	PortfolioProject..CovidVaccinations
--ORDER BY
--	3,
--	4

-- Select Data that we are going to be using

SELECT
	Location,
	Date,
	Total_Cases,
	New_cases,
	Total_deaths,
	Population
FROM 
	PortfolioProject..CovidDeaths
ORDER BY
	1,
	2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you're infected by covid in Australia
SELECT
	Location,
	Date,
	Total_Cases,
	Total_deaths,
	Round((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%Australia%'
ORDER BY
	1,
	2

-- Looking at Total Cases vs Population
-- Shows what percentage of popluation infected by Covid

SELECT
	Location,
	Date,
	Total_Cases,
	Population,
	Round((total_cases/population)*100,2) AS PopulationInfectedPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%Australia%'
ORDER BY
	1,
	2

-- Countries with Highest Infection Rates compared to Population

Select 
	Location,
	Population, 
	MAX(Total_cases) AS HighestInfectedCount,
	ROUND(MAX((Total_cases/population))*100,2) as PopulationInfectedPercentage
FROM
	PortfolioProject..CovidDeaths
GROUP BY
	Location,
	Population
ORDER BY
	PopulationInfectedPercentage DESC


-- Show Countries with Highest Death Count per Population

SELECT
	Location,
	MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	Location
ORDER BY
	TotalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

SELECT
	continent,
	MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT
	sum(new_cases),
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
	--total_deaths,
	--Round((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
--GROUP BY
--	DATE
ORDER BY
	1,
	2

--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProject..CovidDeaths death
	JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE
	death.continent IS NOT NULL
-- ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProject..CovidDeaths death
	JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE
	-- death.continent IS NOT NULL
-- ORDER BY 2, 3

Select 
	*, 
	(RollingPeopleVaccinated/population)*100
FROM 
	#PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM
	PortfolioProject..CovidDeaths death
	JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE
	death.continent IS NOT NULL
--ORDER BY 
--	2, 3

SELECT *
FROM PercentPopulationVaccinated