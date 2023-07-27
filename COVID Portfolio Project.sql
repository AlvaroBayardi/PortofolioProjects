SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4



--Select Data that we are goingo to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in  your country
SELECT Location, date, total_cases, total_deaths,
/*TRY_CAST convert column in float*/
TRY_CAST(total_deaths as float) / TRY_CAST(total_cases as float) *100 as DeathPercentage /*easier to interpreter*/
FROM PortfolioProject..CovidDeaths
WHERE Location like '%uruguay%' and continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total vs Population
-- Show what percentage of population got Covid
SELECT Location, date, Population, total_cases, 
TRY_CAST(total_cases as float) / TRY_CAST(population as float) *100 as CovidPopulationPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Location like '%uruguay%' and continent is not null
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
SELECT Location, Population, MAX(total_deaths) as DeathsCount, MAX((total_deaths/population))* 100 as PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationDeath desc


-- Showing Countries with Highest Death Count
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

---- Let Break Things Down BY Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount,  MAX((total_deaths/population))* 100 as PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentPopulationDeath desc

--Global Number  
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Loking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(BIGINT,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
from PopvsVac 

-- temp table
drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by  2, 3
select *, (RollingPeopleVaccinated/Population)*100  as VaccinatedPercent
from #PercentPopulationVaccinated 
--order by  VaccinatedPercent desc



--creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by  2, 3

SELECT * FROM PercentPopulationVaccinated;