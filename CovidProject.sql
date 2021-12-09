select * from CoivdProject.dbo.CovidDeaths$
order by 3,4

--select * from CovidVaccinations$
--order by 3,4

select location, date,total_cases, new_cases,total_deaths, population
from CovidDeaths$
order by 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
select location, date,total_cases, new_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2

-- LOOKING TOTAL CASES VS POPULATION
select location, date,total_cases, new_cases,population, (total_cases/population) * 100 as CovidPercentage
from CovidDeaths$
--where location like '%states%'
order by 1,2

-- LOOKING AT COUNTRIES WITH HIGEST INFECTION RATE COMPARED TO POPULATION
select location,population, MAX(total_cases) as highestCount, MAX((total_cases/population)) * 100 as InfectedRate
from CoivdProject.dbo.CovidDeaths$
--where location like '%states%'
GROUP BY location, population
order by InfectedRate desc

-- Showing highest death count per population
select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CoivdProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
GROUP BY location
order by TotalDeathCount desc

--Break things down to Continent
select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from CoivdProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Correct things with Continent
select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from CoivdProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is null
GROUP BY location
order by TotalDeathCount desc

-- World total death percentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int)) /sum(new_cases)) * 100 as Death_Percentage
from CoivdProject.dbo.CovidDeaths$
where continent is not null
order by 1,2

--Looking the total population vaccination rate
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CoivdProject.dbo.CovidDeaths$ as dea
join CoivdProject.dbo.CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Rolling Count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as RollingCount
--, (RollingCount/ population) * 100
from CoivdProject.dbo.CovidDeaths$ as dea
join CoivdProject.dbo.CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use of CTE
with PopvsVac (continent, location, date, population,new_vaccinations, RollingCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as RollingCount
--, (RollingCount/ population) * 100
from CoivdProject.dbo.CovidDeaths$ as dea
join CoivdProject.dbo.CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingCount/population)*100
from PopvsVac


--Temp Table

Drop table if exists #PercentageVaccinations
Create Table #PercentageVaccinations
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCount numeric
)

 
Insert into #PercentageVaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as RollingCount
--, (RollingCount/ population) * 100
from CoivdProject.dbo.CovidDeaths$ as dea
join CoivdProject.dbo.CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingCount/population)*100
from #PercentageVaccinations

-- CREATING VIEWS FOR VISUALIZATION LATER
Create view PercentageVaccinations as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as RollingCount
--, (RollingCount/ population) * 100
from CoivdProject.dbo.CovidDeaths$ as dea
join CoivdProject.dbo.CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*
from PercentageVaccinations