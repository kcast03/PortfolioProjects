-- SELECT str_to_date(date, '%m/%d/%Y') FROM coviddeaths;
-- -- SELECT date,str_to_date(date, '%m/%d/%Y') FROM coviddeathscoviddeaths
-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE coviddeaths SET date = str_to_date(date, '%m/%d/%Y');

Select * 
From CovidPortfolioProject.coviddeaths
-- Where continent is not null
order by 3,4;

-- Select the Date that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject.coviddeaths
Order By 1,2;

-- Looking at the total cases vs total deaths
-- shows the likelihood of dying if you contract Covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject.coviddeaths
Where location like '%states%'
Order By 1,2;

-- Looking at the total cases vs the population
-- shows what percentage of the population has covid
Select location, date, total_cases, population, (total_cases/population)*100 as CovidPopulation
From CovidPortfolioProject.coviddeaths
Where location like '%states%'
Order By 1,2;

-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPopulation
From CovidPortfolioProject.coviddeaths
-- Where location like '%states%'
Group By location, population
Order By CovidPopulation desc;

-- change empty string into null values
-- Update coviddeaths
-- Set continent = nullif(continent, '');

-- showing countries with highest death count per population
Select location, MAX(total_deaths) as TotalDeathCount
From CovidPortfolioProject.coviddeaths
Where continent is not null
Group By location
Order By TotalDeathCount desc;

-- break things down by continent
Select continent, MAX(total_deaths) as TotalDeathCount
From CovidPortfolioProject.coviddeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc;

-- Global Numbers
Select date, SUM(cast(new_cases as unsigned)) as TotalCases, SUM(cast(new_deaths as unsigned)) as TotalDeaths, 
SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
From coviddeaths
Where continent is not null
Group by date
order by 1,2;


-- looking at total population vs vaccinations
-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE covidvaccinations SET date = str_to_date(date, '%m/%d/%Y');
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != ''
Order By 2,3;

-- use CTE
-- summing the new vaccinations by location and date
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By dea.location, dea.date)
as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != ''
)
Select * 
From PopvsVac;

-- temp table

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
Create Temporary Table PercentPopulationVaccinated
(
continent char(255),
location char(255),
Date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);


Insert Ignore into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition By dea.location Order By dea.location, dea.Date)
as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != '';

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated;

-- create views to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition By dea.location Order By dea.location, dea.Date)
as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != '';










