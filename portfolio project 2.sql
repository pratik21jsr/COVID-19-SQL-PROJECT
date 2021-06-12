select * from ..coviddeaths
order by 3,4

--select * from ..covidvaccinations
--order by 3,4

select location, date, total_cases,new_cases, total_deaths, population 
from ..coviddeaths
order by 1,2

-- Looking at the Total cases vs Total deaths
select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Death_percentage 
from ..coviddeaths
where location like '%india%'
order by 1,2

-- Look at total cases vs population
select location, date, total_cases, population, (total_cases / population)*100 as percentage_infected
from ..coviddeaths
where location like '%india%'
order by 1,2

-- looking at the country with highest infection rate
select location, population, max(total_cases) as highest_infection_count , max( (total_cases / population)*100) as percentinfected  
from ..coviddeaths
group by location, population
order by 4 Desc 

-- showing the contries with highest deathcount with population
-- Using continent is  not nuall as without it it is selecting the continents too 
select location, Max(cast(total_deaths as int)) as total_death_count
from ..coviddeaths
where continent is not null
group by location
order by total_death_count desc

-- Showing values by continent
select location, Max(cast(total_deaths as int)) as total_death_count
from ..coviddeaths
where continent is null
group by location
order by total_death_count desc

-- Global numbers
select date, sum(total_cases) , sum(cast(total_deaths as int))
from ..coviddeaths
where continent is not null
group by date
order by date

select sum(new_cases) as TotalCases , sum(cast(new_deaths as int)) as Totaldeath
from ..coviddeaths
where continent is not null

-- Joining the two tables
Select * 
from .coviddeaths dea
join ..covidvaccinations vac
on dea.location = vac.location and dea.date=vac.date

-- Looking for total population vs vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
from .coviddeaths dea
join ..covidvaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Doing a rolling count for finding total vaccinated using the new vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
from .coviddeaths dea
join ..covidvaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from .coviddeaths dea
join ..covidvaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using the with function to get the PercentagePeopleVaccinated
with popvsvac as (
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from .coviddeaths dea
join ..covidvaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from popvsvac
where location like '%india'



-- Creating view to store data for later visualization
create view PercentPeopleVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from .coviddeaths dea
join ..covidvaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

select *
from PercentPeopleVaccinated