--   ##Covid-19 Analysis##

select * 
from PortfolioProjectOne..CovidDeaths
order by 3,4

--select * 
--from PortfolioProjectOne..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProjectOne..CovidDeaths
order by 1,2

-- Gives total deaths to total cases percentage.

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectOne..CovidDeaths
where location like '%states%'
order by 1,2

-- Gives the percentage of people who contacted covid .

select location, date,population, total_cases,(total_cases/population)*100 as ContactPercentage
from PortfolioProjectOne..CovidDeaths
--where location like '%states%'
order by 1,2


-- Gives countries with high infection rate

select location,population, max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as ContactPercentage
from PortfolioProjectOne..CovidDeaths
--where location like '%states%'
group by location, population
order by ContactPercentage desc

--  Gives countries with highest deathrate due to covid

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectOne..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectOne..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- ## Global Figures ##

select  date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjectOne..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select   sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjectOne..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Gives total population wrt Vaccinacation

select dea.continent , dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinationPerDay
from PortfolioProjectOne..CovidDeaths dea
join PortfolioProjectOne..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	order by 1,2,3

	-- ## CTE ##
	--Percentage of people vaccinated

	with PopvsVac(continent,location,date,population,new_vaccinations,VaccinationPerDay)
	as
	(
	select dea.continent , dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinationPerDay
from PortfolioProjectOne..CovidDeaths dea
join PortfolioProjectOne..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2,3
	)
	select*,(VaccinationPerDay/population)*100 
	from PopvsVac

	-- ## TEMP TABLE ##
	drop table if exists PercentagePopulationVac

	create table PercentagePopulationVac
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	New_vaccinations numeric,
	VaccinationPerDay numeric
	)

	insert into PercentagePopulationVac
	select dea.continent , dea.location, dea.date, dea.population, dea.new_vaccinations,
     sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinationPerDay
     from PortfolioProjectOne..CovidDeaths dea
     join PortfolioProjectOne..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
	 --where dea.continent is not null
	 --order by 1,2,3
	 
     select *,(VaccinationPerDay/population)*100 
	 from PercentagePopulationVac
	
	-- ## Creating view to store data ##

	-- droping the view in case it already exists
	drop view if exists PercentagePopulationVaccinations

	-- creating view
	CREATE VIEW [PercentagePopulationVaccinations] as
	select dea.continent , dea.location, dea.date, dea.population, dea.new_vaccinations,
    sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinationPerDay
    from PortfolioProjectOne..CovidDeaths dea
    join PortfolioProjectOne..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null;
	--order by 1,2,3

	
	-- display of the view
select * from [PercentagePopulationVaccinations];
	