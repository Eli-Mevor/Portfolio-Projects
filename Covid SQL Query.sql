--looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerCasePercent
FROM Covid19Deaths
WHERE location = 'Ghana'
ORDER BY 1,2

-- looking at the total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePerPopPercent
FROM Covid19Deaths
ORDER BY 1,2

--looking at countries with the highest infection rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM Covid19Deaths
GROUP BY location, population
ORDER BY 4 DESC

-- showing countries with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM Covid19Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


--global numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as Totaldeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM Covid19Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--looking at population vs vaccination

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid19Deaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


---using CTE

WITH PopVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid19Deaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VacPerPop
FROM PopVac




CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population int,
New_Vaccinations int,
RollingPeopleVaccinated int,
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid19Deaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as VacPerPop
FROM PercentagePopulationVaccinated



--creating a view to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid19Deaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
