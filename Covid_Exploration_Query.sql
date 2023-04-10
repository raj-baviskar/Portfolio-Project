# Covid Data Exploration Project

# Understanding basic data for the project
SELECT  location,
        date,
        population,
        new_cases,
        total_cases,
        total_deaths
FROM `flawless-snow-370312.portfolio_project.covid_death` 
ORDER BY location, date;

# Understanding death rate
# Shows Death rates were at peak during early May of 2020
SELECT  location,
        date,
        total_cases,
        total_deaths,
        (total_deaths/total_cases)*100 AS death_rate
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE location = 'India'
ORDER BY death_rate DESC;

# Gives an average death rate for Covid till 15/03/2023
SELECT  location,
        AVG((total_deaths/total_cases)*100) AS death_rate
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE location = 'India'
GROUP BY location
ORDER BY death_rate DESC;

# Understanding the infection rate in India
SELECT  location,
        date,
        population,
        total_cases,
        (total_cases/population)*100 AS infection_rate
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE location = 'India'
ORDER BY infection_rate DESC;

# Comparison of countries infection rate
SELECT  location,
        population,
        MAX(total_cases) AS total_cases,
        (MAX(total_cases)/population)*100 AS infection_rate
FROM `flawless-snow-370312.portfolio_project.covid_death` 
GROUP BY location, population
ORDER BY infection_rate DESC;

# Highest Death Count by Country
SELECT  location,
        MAX(total_deaths) AS total_death
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death DESC;

# Highest Death Count by Continent
SELECT  location,
        MAX(total_deaths) AS total_death
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death DESC;

# Total cases and deaths based on days
SELECT  date,
        SUM(new_cases) AS total_cases,
        SUM(new_deaths) AS total_death,
        (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS death_rate
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

# Total cases and deaths till 15/03/2023 
SELECT  SUM(new_cases) AS total_cases,
        SUM(new_deaths) AS total_death,
        (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS death_rate
FROM `flawless-snow-370312.portfolio_project.covid_death` 
WHERE continent IS NOT NULL;

# Looking population and vaccination 
SELECT  d.continent,
        d.location,
        d.date,
        d.population,
        v.new_vaccinations
FROM  `flawless-snow-370312.portfolio_project.covid_death` d
JOIN  `flawless-snow-370312.portfolio_project.covid_vaccination` v
      ON d.location = v.location
      AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

# Looking at total vaccinations
SELECT  d.continent,
        d.location,
        d.date,
        d.population,
        v.new_vaccinations,
        SUM(new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM  `flawless-snow-370312.portfolio_project.covid_death` d
JOIN  `flawless-snow-370312.portfolio_project.covid_vaccination` v
      ON d.location = v.location
      AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

# Percentage of people vaccinated
WITH percentage_people_vaccinated AS(
   SELECT  d.continent,
        d.location,
        d.population,
        v.new_vaccinations,
        SUM(new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
   FROM  `flawless-snow-370312.portfolio_project.covid_death` d
   JOIN  `flawless-snow-370312.portfolio_project.covid_vaccination` v
         ON d.location = v.location
         AND d.date = v.date
   WHERE d.continent IS NOT NULL
   ORDER BY d.location, d.date
)
SELECT  *,
        (total_vaccinations/population)*100 AS percentage_vaccinated
FROM percentage_people_vaccinated;

# Creating a temp table

DROP TABLE IF EXISTS portfolio_project.people_vaccinated;
CREATE TABLE portfolio_project.people_vaccinated AS
  SELECT  d.continent,
        d.location,
        d.population,
        v.new_vaccinations,
        SUM(new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
   FROM  `flawless-snow-370312.portfolio_project.covid_death` d
   JOIN  `flawless-snow-370312.portfolio_project.covid_vaccination` v
         ON d.location = v.location
         AND d.date = v.date
   WHERE d.continent IS NOT NULL
   ORDER BY d.location, d.date;
SELECT  *,
        (total_vaccinations/population)*100 AS percentage_vaccinated
FROM portfolio_project.people_vaccinated;


## Data extracted for Tableau Dashboard
##Total cases, death and death percentage
SELECT SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths)/SUM(New_Cases))*100 as DeathPercentage
FROM `flawless-snow-370312.portfolio_project.covid_death`
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;

## Death count as per continents
SELECT location, 
       SUM(new_deaths) AS TotalDeathCount
FROM `flawless-snow-370312.portfolio_project.covid_death`
WHERE continent IS NULL
      AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC;

## Infection rate in every country
SELECT location, 
       population, 
       MAX(total_cases) as HighestInfectionCount,  
       Max((total_cases/population))*100 as PercentPopulationInfected
FROM `flawless-snow-370312.portfolio_project.covid_death`
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

##Country wise infection rate
SELECT location, 
       population,
       date, 
       MAX(total_cases) as HighestInfectionCount,  
       MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `flawless-snow-370312.portfolio_project.covid_death`
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;
