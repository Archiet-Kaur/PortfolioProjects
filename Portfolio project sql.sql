select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- select * from PortfolioProject..CovidVaccinations
-- order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order  by 1,2

--total cases v/s total deaths
-- shows likelihood of dying if you contract covid in india.

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like '%india%' and continent is not null
order by 1,2


-- total cases v/s population
-- shows what percentage of population has gotten covid
Select location, date, Population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0))*100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%india%' and continent is not null
order by 1,2

--countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0)))*100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
where continent is not null
group by Location, Population
--where Location like '%india%'
order by PercentPopulationInfected desc


--countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--continents with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..covidDeaths
where continent is null
group by Location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as tot_cases,SUM(new_deaths) as tot_deaths, --SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
(CONVERT(float, SUM(new_deaths)) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--where location like '%india%' 
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as tot_cases,SUM(new_deaths) as tot_deaths, --SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
(CONVERT(float, SUM(new_deaths)) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--where location like '%india%' 
where continent is not null
order by 1,2


-- TOTAL POPULATION V/S VACCINATION
select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent,dea.location, dea.date, dea.population, nullif(convert(float,vac.new_vaccinations),0) as new_vaccinations,
sum(nullif(convert(float, vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- WITH CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, nullif(convert(float,vac.new_vaccinations),0) as new_vaccinations,
sum(nullif(convert(float, vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 from PopVsVac

--TEMP TABLE

DROP table #PercentPopulationVaccinated


create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, nullif(convert(float,vac.new_vaccinations),0) as new_vaccinations,
sum(nullif(convert(float, vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--create view to store data for later visualisation

create view PercentPopulationVaccinatedview as
select dea.continent,dea.location, dea.date, dea.population, nullif(convert(float,vac.new_vaccinations),0) as new_vaccinations,
sum(nullif(convert(float, vac.new_vaccinations),0)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
GO

drop view PercentPopulationVaccinatedview

select * from PercentPopulationVaccinatedview