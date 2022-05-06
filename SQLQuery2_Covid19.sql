select *
from PortfolioProjects..CovidDeaths$
order by 3,4

select * 
from PortfolioProjects..CovidDeaths$
order by 3,4

 --SELECT DATA THAT WE ARE INTERESTED IN USING FOR THIS QUERY
 select location, date, total_cases ,new_cases, total_deaths ,population
 from PortfolioProjects..CovidDeaths$
 order by 1,2

 --TOTAL CASES VS TOTAL DEATHS (Calculation 1) specific to Africa
 select location, date, total_cases, total_deaths ,
 (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProjects..CovidDeaths$
 where location like '%africa%' 
 order by 1,2

 --TOTAL CASES VS POPULATION SIZE , SPECIFIC TO AFRICA
 select location, date, total_cases, population ,
 (total_cases/population)*100 as Total_Cases_Percentage
 from PortfolioProjects..CovidDeaths$
 where location like '%africa%' 
 order by 1,2

 --country with the highest infaction rate compared to population
 select location, max(total_cases), population ,
 max((total_cases/population))*100 as HighestInfection_country
 from PortfolioProjects..CovidDeaths$
 group by location, population
 order by HighestInfection_country desc --shows the table from the mentioned colunm name and orders the colunm in a descending order

 --country with the highest death count per population
 select location, max(cast(total_deaths as int)) as TotalDeathCount --cast when your expected values dont make sense
 from PortfolioProjects..CovidDeaths$
 where location is not null
 group by location
 order by TotalDeathCount desc

 --GROUPING BY CONTINENT with highest numbers of deaths 
 select location, max(cast(total_deaths as int)) as TotalDeathCount --cast when your expected values dont make sense
 from PortfolioProjects..CovidDeaths$
 where continent is null
 group by location
 order by TotalDeathCount desc

 --GLOBAL NUMBER CALCULATIONS for newcases vs new deaths per day
 select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage --calculation of global death percentage
 from PortfolioProjects..CovidDeaths$
 where continent is not null
 group by date 
 order by 1,2

  --using the CTE***
 With PopVSvac ( continent , location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (		
	 --JOINING COVID_DEATHS + VACCINE TABLES 
	select death.continent, death.location, vac.date , death.population, death.new_vaccinations
	,sum(convert(int,death.new_vaccinations)) OVER (Partition by death.location order by death.location, vac.date) as RollingPeopleVaccinated
	--to do
	from PortfolioProjects..CovidDeaths$ death
	right join PortfolioProjects..CovidVaccinations$ vac
		On death.location = vac.location
		and death.date = vac.date
	where death.continent is not null
	
 )
 --drama doesnt work the cte section...
   select * , (RollingPeopleVaccinated/population)*100
  from PopVSvac

 ---temporary table(no outputs yet)
 drop table if exists #RercentagePopulationVaccinated
 Create table #RercentagePopulationVaccinated
 (
	continent nvarchar(255),
	Location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric	
 )
 insert into #RercentagePopulationVaccinated
 select death.continent, death.location, vac.date , death.population, death.new_vaccinations
	,sum(convert(int,death.new_vaccinations)) OVER (Partition by death.location order by death.location, vac.date) as RollingPeopleVaccinated
	--to do
	from PortfolioProjects..CovidDeaths$ death
	right join PortfolioProjects..CovidVaccinations$ vac
		On death.location = vac.location
		and death.date = vac.date
	where death.continent is not null
	