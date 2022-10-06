
select *
from [portfolio project]..CovidDeaths$
order by 3, 4

select *
from [portfolio project]..CovidDeaths$
order by 3, 4

--select data that we will be doing

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..CovidDeaths$
order by 1, 2

--looking at total cases vs total death
--shows likelihood of dying if you contract covid in Nigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_of_death
from [portfolio project]..CovidDeaths$
where location like'%Nigeria%'
order by 1, 2

--looking at the total cases vs pop
--shows what percent of the pop has covid

select location, date, total_cases, population, (total_cases/population)*100 as percentofpopulationInfected
from [portfolio project]..CovidDeaths$
--where location like'%Nigeria%'
order by 1, 2

--looking at countries with highest infection rate compared to pop

select location,population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as percentOfPopulationInfected
from [portfolio project]..CovidDeaths$
--where location like'%Nigeria%'
group by location, population
order by percentOfPopulationInfected desc

--what country has the highest confirmed cases in africa
select continent, location, max(total_cases) as highestInfectionCount
from [portfolio project]..CovidDeaths$
where continent like'%africa%'
group by continent, location
order by highestInfectionCount desc

--what country has the highest confirmed cases in Europe
select continent, location, max(total_cases) as highestInfectionCount
from [portfolio project]..CovidDeaths$
where continent like'%europe%'
group by continent, location
order by highestInfectionCount desc

--what country has the highest confirmed cases in north america
select continent, location, max(total_cases) as highestInfectionCount
from [portfolio project]..CovidDeaths$
where continent like'%north america%'
group by continent, location
order by highestInfectionCount desc

--showing continents with highest death counts
select continent, max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project]..CovidDeaths$
--where location like'%Nigeria%'
where continent is not null
group by continent
order by totaldeathcount desc

--looking at total pop vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int, vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as rollingvaccine
--, (rollingvaccine/population)*100
from [portfolio project]..CovidDeaths$ dea
join [portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--using cte
with popvsvacc(continent, location, date, population,new_vaccinations, rollingvaccine)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int, vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as rollingvaccine
--, (rollingvaccine/population)*100
from [portfolio project]..CovidDeaths$ dea
join [portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingvaccine/population)*100
from popvsvacc



--temp table
drop table if exists percentpopvaccinated
create table percentpopvaccinated
(
continent nvarchar(255),
location nvarchar(120),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccine numeric
)


insert into percentpopvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int, vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as rollingvaccine
--, (rollingvaccine/population)*100
from [portfolio project]..CovidDeaths$ dea
join [portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (rollingvaccine/population)*100
from percentpopvaccinated


--creating view to store data for later visulizations
create view vpercentpopvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int, vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as rollingvaccine
--, (rollingvaccine/population)*100
from [portfolio project]..CovidDeaths$ dea
join [portfolio project]..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3