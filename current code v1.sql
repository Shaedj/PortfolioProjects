Select *
FROM portfolioproject.coviddeaths
ORDER BY 3,4;


#Select *
#FROM portfolioproject.covidvaccinations
#ORDER BY 3,4;

-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
Where continent is not null
ORDER by 1,2;
-- I put order by 1, 2 in order to have the table organized by the first and second column, or location and date.

-- Looking at Total cases VS Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death ratio'
FROM portfolioproject.coviddeaths
WHERE location = 'United States'
ORDER by 1,2;
-- I add the 'Death Ratio' column in order to calculate what percentage of people die compared to the total cases.
-- I multiply by 100 in order to get the percentage number


-- Looking at Total Cases VS Population
Select location, date, total_cases, population, (total_cases/Population)*100 AS 'Percent infected'
FROM portfolioproject.coviddeaths
WHERE location = 'United States'
ORDER by total_cases;
-- Dividing total cases with population to see what percent of the population caught covid before


-- Looking at Countries with highest infection rate compared to population
Select location, MAX(total_cases) AS HighestInfectionCount, population, Max((total_cases/Population))*100 AS 'PercentPopulationInfected'
FROM portfolioproject.coviddeaths
Where continent is not null
GROUP by location, population
Order by PercentPopulationInfected desc;


-- Showing countries with the highest death count per population
Select location, MAX(CAST(Total_deaths as unsigned)) as TotalDeathCount
FROM portfolioproject.coviddeaths
Where continent is not null 
GROUP by location
Order by TotalDeathCount desc;


-- Let's Break things down by Continent
Select Continent, MAX(CAST(Total_deaths as unsigned)) as TotalDeathCount
FROM portfolioproject.coviddeaths
Where continent is not null 
GROUP by Continent
Order by TotalDeathCount desc;
-- Doesn't seem right, numbers a off.

Select continent, MAX(CAST(Total_deaths as unsigned)) as TotalDeathCount
FROM portfolioproject.coviddeaths
Where continent is not null 
GROUP by continent
Order by TotalDeathCount desc;


-- Showing the continents with the highest death counts
Select Continent, MAX(CAST(Total_deaths as unsigned)) as TotalDeathCount
FROM portfolioproject.coviddeaths
Where continent is not null 
GROUP by Continent
Order by TotalDeathCount desc;


-- Global Numbers
Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(New_cases)*100 as GlobalDeathPercentage
FROM portfolioproject.coviddeaths
WHERE continent is not null
-- GROUP by date
ORDER by 2,3;

-- per date global numbers
Select date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(New_cases)*100 as GlobalDeathPercentage
FROM portfolioproject.coviddeaths
WHERE continent is not null
GROUP by date
ORDER by 2,3;


-- Joining COVID VACCINATION TABLE --
SELECT *
FROM portfolioproject.coviddeaths
JOIN portfolioproject.covidvaccinations
ON coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date;


-- Looking at Total Population VS Vaccinations
SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, SUM(covidvaccinations.new_vaccinations) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingVaccinated
FROM portfolioproject.coviddeaths
JOIN portfolioproject.covidvaccinations
ON coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
ORDER BY 1,2,3;


-- USE CTE
With PopVSVac (Continent, Location, Date, population, new_vaccinations, RollingVaccinated)
as
(
SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, SUM(covidvaccinations.new_vaccinations) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingVaccinated
FROM portfolioproject.coviddeaths
JOIN portfolioproject.covidvaccinations
ON coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
-- ORDER BY 2,3
)

SELECT *, (RollingVaccinated/population)*100
FROM PopVSVAC


-- TEMP TABLE

CREATE temporary Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, SUM(covidvaccinations.new_vaccinations) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingVaccinated
FROM portfolioproject.coviddeaths
JOIN portfolioproject.covidvaccinations
ON coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
-- ORDER BY 2,3

SELECT *, (RollingVaccinated/population)*100
FROM temporary table PercentPopulationVaccinated



-- ChatGPT advice:

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
  Continent VARCHAR(255),
  Location VARCHAR(255),
  Date DATETIME,
  Population DECIMAL(15,2),
  New_vaccinations DECIMAL(15,2),
  RollingVaccinated DECIMAL(15,2)
);

INSERT INTO PercentPopulationVaccinated
SELECT coviddeaths.continent, 
       coviddeaths.location, 
       coviddeaths.date, 
       coviddeaths.population, 
       covidvaccinations.new_vaccinations, 
       SUM(covidvaccinations.new_vaccinations) OVER (PARTITION BY coviddeaths.location 
                                                     ORDER BY coviddeaths.date) AS RollingVaccinated
FROM portfolioproject.coviddeaths
JOIN portfolioproject.covidvaccinations
  ON coviddeaths.location = covidvaccinations.location
  AND coviddeaths.date = covidvaccinations.date;

SELECT *, (RollingVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;




-- Creating views to store for later visualizations --

CREATE VIEW PercentPopulationVaccinated AS
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL;


CREATE VIEW DEATH_RATIO AS
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death ratio'
FROM portfolioproject.coviddeaths
WHERE location = 'United States'
ORDER by 1,2;


CREATE VIEW PERCENT_INFECTED AS
Select location, date, total_cases, population, (total_cases/Population)*100 AS 'Percent infected'
FROM portfolioproject.coviddeaths
WHERE location = 'United States'
ORDER by total_cases;


Create VIEW CountryPercentageInfected as
Select location, MAX(total_cases) AS HighestInfectionCount, population, Max((total_cases/Population))*100 AS 'PercentPopulationInfected'
FROM portfolioproject.coviddeaths
Where continent is not null
GROUP by location, population
Order by PercentPopulationInfected desc;


CREATE VIEW CountryTotalDeathCount AS
Select location, MAX(CAST(Total_deaths as unsigned)) as TotalDeathCount
FROM portfolioproject.coviddeaths
Where continent is not null 
GROUP by location
Order by TotalDeathCount desc;


CREATE VIEW ContinentsDeathCounts AS
Select continent, MAX(CAST(Total_deaths as unsigned)) as TotalDeathCount
FROM portfolioproject.coviddeaths
Where continent is not null 
GROUP by continent
Order by TotalDeathCount desc;


CREATE View GlobalNumberPERdate AS
Select date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(New_cases)*100 as GlobalDeathPercentage
FROM portfolioproject.coviddeaths
WHERE continent is not null
GROUP by date
ORDER by 2,3;