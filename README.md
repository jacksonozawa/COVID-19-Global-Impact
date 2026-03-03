# COVID-19 Global Impact Analysis

### Project Overview
This project aims to analyze global COVID data from January 2020 to April 2021, analyzing the disease's early impact on the world's population.

### Data Sources
Two data sets were used in this analysis, CovidDeaths.xlsx and CovidVaccinations.xlsx files. Both datasets are sourced from Our World In Data. 

### Tools
I used Excel to clean and prepare the data before using SQL to perform exploratory data analysis. I then used the queried data in Tableau for visualization and dashboard creation. 

### Data Analysis
I performed exploratory analysis using SQL to explore the COVID data on 3 different levels (Country, Continent, Global) and examined relationships between COVID deaths and vaccinations, utlizing JOINS, CTE's, and aggregation The queries I used can be found in the covid_EDA_queries.sql file. 

### Visualization
I queried two separate tables to use for my Tableau visualizations, seen in covid_tableau_queries.sql.

My dashboard contains five distinct visualizations:
  1. Global KPI - Table containing Total Cases, Total Deaths, Total Vaccinations, Global Fatality Rate, and Global Vaccination Rate.
  2. Country Statistics - World map shaded based on Country's percent population infected. Displays Country specific COVID metrics.
  3. Top 10 Countries - Bar graph displaying the Top 10 Countries of a selected metric (Total Cases, Fatality Rate, Vaccination Rate)
  4. Fatality Rate vs Vaccination Rate - Scatterplot to show the relationship between Fatality Rate and Vaccination Rate of all countries.
  5. Global Trends Over Time - Dual-axis line graph illustrating the Rolling Death Count and Vaccination Count over the dataset's time period.
