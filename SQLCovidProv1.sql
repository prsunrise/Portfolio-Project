--Testing Both Covid Tables 
Select * 
From PortfolioProject..CovidDeaths
Order by 3,4

Select location
From PortfolioProject..CovidDeaths
group by location
order by location


-- Viewing total cases v total deaths
-- Displays the likelihood of dying from COVID
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Percentage of population that contracted COVID 
Select location, date, total_cases, Population, (total_cases/population)*100 as ContractedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Highest infection rate compared to population 
Select location, Max(total_cases) as HighestInfectionCount, Population, Max((total_cases/population))*100 as PercentpopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'United Kingom' or location = 'United States'
Group by location, population
order by PercentpopulationInfected desc

-- -Countries Highest Death Count per population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount -- we need to cast this as an int because the datatype is saved as varchar 
From PortfolioProject..CovidDeaths
Group by location -- World S. America are populating in Location , this needs to be fixed. 
order by TotalDeathCount desc


Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select location, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Breaks things down by Continent
-- it appears Canada is not included in calc of N America 
Select continent, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


--Filtering by Continent ( Displaying Continents with highest death count per pop
Select continent, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Filtering to find NULL
Select continent, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- GLobal Numbers
Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date -- we will receive an error because we cant just group by date, we will need to use an agregate function
order by 1,2

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

	-- Total Population v Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
	-- This enables a rolling count will ignoring nulls until a new country appears. 
	as RollingPeopleVaccinated
	-- If a mathematical operation is needed with the results a CTE is needed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3


--USE CTE 

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
	-- This enables a rolling count will ignoring nulls until a new country appears. 
	as RollingPeopleVaccinated
	-- If a mathematical operation is needed with the results a CTE is needed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3
)
Select * , ( RollingPeopleVaccinated /population) * 100 as Total_Vac
from PopvsVac

-- Temp Table 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
( 
continent nvarchar(255),
location nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT (int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
	-- This enables a rolling count will ignoring nulls until a new country appears. 
	as RollingPeopleVaccinated
	-- If a mathematical operation is needed with the results a CTE is needed
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

Select * , (RollingPeopleVaccinated /population) * 100 as Total_Vac
from #PercentPopulationVaccinated