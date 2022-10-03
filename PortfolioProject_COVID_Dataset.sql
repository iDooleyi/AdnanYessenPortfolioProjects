SELECT *
FROM PortfolioProject..COVIDDeaths
WHERE continent is not null
ORDER BY 3,4

--select *
--from PortfolioProject..COVIDVaccinations
--order by 3,4

--Select the data thats going to be used

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDDeaths 
WHERE continent is not null
order by 1,2

--Total Cases VS Total Deaths

SELECT Location, Date, total_cases, total_deaths, (Total_deaths/Total_Cases)*100 AS Death_Percentage
FROM PortfolioProject..COVIDDeaths 
WHERE Location like '%Kingdom%' and continent is not null
order by 1,2

-- Total Cases vs Population

SELECT Location, Date, total_cases, population, (Total_cases/Population)*100 AS Case_Percentage
FROM PortfolioProject..COVIDDeaths 
WHERE Location like '%Kingdom%' and continent is not null
order by 1,2

-- Highest infection rate compared to population 

SELECT Location, MAX(total_cases) AS Highest_Infection_Count, population, (MAX(Total_cases)/Population)*100 AS Max_Case_Percentage
FROM PortfolioProject..COVIDDeaths 
WHERE continent is not null
Group By population, Location
order by Max_Case_Percentage desc

-- Highest death count per population

SELECT Location, Max(cast(total_deaths as Int)) AS Total_Deaths
FROM PortfolioProject..COVIDDeaths 
WHERE continent is not null
Group By population, Location
order by Total_Deaths desc

-- Highest death count per continent 

SELECT continent, Max(cast(total_deaths as Int)) AS Total_Deaths
FROM PortfolioProject..COVIDDeaths 
WHERE continent is not null
Group By continent
order by Total_Deaths desc

-- Breaking down the global numbers 

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..COVIDDeaths 
WHERE continent is not null
order by 1,2

-- Joining the COVID Vaccinations table with the COVID Deaths table and checking the amount of the total population that have been vaccinated (w/rolling count)

SELECT death.continent, death.location, death.date, death.population, Vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations AS int)) OVER (Partition by death.location Order By death.location, death.date) AS RollingCount 
FROM PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations Vacc
	ON death.location = Vacc.location
	and death.date = Vacc.date
WHERE death.continent is not null
Order by 2,3

-- Using a CTE 

With PopulationVSVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingCount)
as 
(
SELECT death.continent, death.location, death.date, death.population, Vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations AS int)) OVER (Partition by death.location Order By death.location, death.date) AS RollingCount 
FROM PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations Vacc
	ON death.location = Vacc.location
	and death.date = Vacc.date
WHERE death.continent is not null
)

SELECT*, (RollingCount/Population)*100
FROM PopulationVSVaccinated

-- Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCount numeric
)

Insert into #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, Vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations AS int)) OVER (Partition by death.location Order By death.location, death.date) AS RollingCount 
FROM PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations Vacc
	ON death.location = Vacc.location
	and death.date = Vacc.date
--WHERE death.continent is not null

SELECT*, (RollingCount/Population)*100
FROM #PercentPopulationVaccinated

