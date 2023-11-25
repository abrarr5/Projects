
-- Select * 
-- From covidvaccinations
-- order by 3,4;

Select * 
From coviddeaths
order by 3,4;


Select Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
order by 1,2;

-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From coviddeaths
Where location like '%states%'
order by 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
From coviddeaths
-- Where location like '%states%'
order by 1,2;


-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentofPopulationInfected desc;

-- Showing the countries with the highest death  count per population

Select Location, MAX(Total_deaths) as TotaldeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc;

-- By Continent 

Select continent, MAX(Total_deaths) as TotaldeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)* 100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From coviddeaths
-- Where location like '%states%'
-- where continent is not null
-- Group by date
order by 1,2;


-- looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location, dea.date) as rollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- Use CTE 

-- With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
-- as
-- (
-- Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location, dea.date) as rollingPeopleVaccinated
-- From coviddeaths dea
-- Join covidvaccinations vac
--     On dea.location = vac.location
--     and dea.date = vac.date
-- where dea.continent is not null
-- )
-- order by 1,2,3;

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;
-- where dea.continent is not null 

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated;

-- -- Creating view to strore data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


Select * 
From PercentPopulationVaccinated