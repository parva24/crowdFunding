create database crowdfunding;
use crowdfunding;
select * from projects;
select count(*) from projects;


load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\location.csv'
into table location
fields terminated by ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
ignore 1 rows;

desc creator;
ALTER DATABASE crowdfunding CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
ALTER TABLE creator CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
cREATE TABLE calender_table (
    date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Week_of_Year Int,
    Day_of_Week int,
    Day Int,
    Day_Name Varchar(30),
    Quarter VARCHAR(5),
    YearMonth VARCHAR(10),
	FinancialMonth VARCHAR(5),
    FinancialQuarter VARCHAR(5)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
cREATE TABLE category (
   id INT ,
    name VARCHAR(100),
    parent_id INT,
    position INT
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

cREATE TABLE location (
       id INT PRIMARY KEY,
    displayable_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    type VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    name VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    state VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    short_name VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    is_root VARCHAR(20),
    country VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE Creator (
  id INT primary key,
    name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

select * from location;
select count(*) from location;

#--------------- Total Number of Projects based on Outcome-------------------#

SELECT state, COUNT(*) AS total_projects
FROM projects
GROUP BY state
ORDER BY total_projects DESC;

#------------------- Total Number of Projects Based on Locations ------------------#
SELECT country, COUNT(*) AS total_projects
FROM projects
GROUP BY country
ORDER BY total_projects DESC;

#--------------------- Total Number of Projects Based on Category ------------------#
SELECT category_id,count(ProjectID) as total_projects
FROM projects
GROUP BY 1
ORDER BY 1 asc;  

#------------------ Total Number of Projects By Year, Quarter & Month -----------------#
SELECT 
    YEAR(from_unixtime(created_at)) AS year,
    QUARTER(from_unixtime(created_at)) AS quarter,
    MONTHNAME(from_unixtime(created_at)) AS month,
    COUNT(*) AS total_projects
FROM 
   projects
GROUP BY 
    YEAR(from_unixtime(created_at)), 
    QUARTER(from_unixtime(created_at)), 
    MONTHNAME(from_unixtime(created_at))
ORDER BY 
    YEAR(from_unixtime(created_at)) DESC, 
    QUARTER(from_unixtime(created_at)), 
    MONTHNAME(from_unixtime(created_at)); 


SELECT 
    YEAR(from_unixtime(created_at)) AS year,
    COUNT(*) AS total_projects
FROM  projects
GROUP BY 1
ORDER BY 1;

select * from projects;

#---------------------- Total Number of Projects By Amount Raised-------------------------------#
SELECT 
    name AS project_name,
    state,
    sum(goal * static_usd_rate) AS amount_raised
FROM 
    projects
WHERE 
    state = 'successful'
    order by amount_raised desc;
    #-------------------------------------------#
    SELECT 
    concat(round(sum(goal * static_usd_rate)/1000000000,2),'B') AS total_in_billions
FROM 
    projects
WHERE 
    state = 'successful';
    
 #----------------- Total Number of Successful Projects By Backers -------------------------#
SELECT 
    name AS project_name,
    state,
    backers_count
FROM 
    projects
WHERE 
    state = 'successful'
ORDER BY 
    backers_count DESC;
    
    #---------------------------------------------------------#
    SELECT 
    project_name,
    state,
    backers_count,
    rnk
FROM (
    SELECT 
        name AS project_name,
        state,
        backers_count,
        RANK() OVER (ORDER BY backers_count DESC) AS rnk
    FROM 
        projects
    WHERE 
        state = 'successful'
) ranked
WHERE 
    rnk <= 10;
    
#----------- Average Number of Days for Successful Projects --------------------------#
SELECT 
    state as project,
    round(avg(datediff(from_unixtime(successful_at), from_unixtime(created_at))),0) as avg_days_for_project
FROM 
    projects
WHERE 
    state = 'successful'
    and successful_at is not null
    and created_at is not null
    group by state
ORDER BY 
   avg_days_for_project DESC; 

#----------------- Percentage of Successful Projects Overall ----------------------#
SELECT 
   concat(
   round((COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 / COUNT(*)),2),'%')
   AS success_percentage
FROM 
    projects;

select * from projects;

#----------- Percentage of successful projects by category --------------#
SELECT 
    category_id,
    COUNT(*) AS total_projects,
sum(case when state = 'successful' then 1
else 0 
end) as successful_projects,
concat(round((sum(case when state = 'successful' then 1
else 0 
end) / count(*)) * 100,
2
),'%') as successful_percentage
FROM 
    projects 
GROUP BY 
   category_id
ORDER BY 
    round(sum(case when state = 'successful' then 1 else 0 end)/count(*)) * 100,2
    DESC; 
    
  use crowdfunding;  
    -- Percentage of Successful Projects by Goal Range --
SELECT 
    CASE 
        WHEN (goal * static_usd_rate) < 5000 THEN 'less than 5000'
        WHEN (goal * static_usd_rate) BETWEEN 5000 AND 20000 THEN '5000 to 20000'
        WHEN (goal * static_usd_rate) BETWEEN 20000 AND 50000 THEN '20000 to 50000'
        WHEN (goal * static_usd_rate) BETWEEN 50000 AND 100000 THEN '50000 to 100000'
        ELSE 'greater than 100000'
    END AS goal_range,
    COUNT(ProjectID) AS total_projects,
    COUNT(CASE WHEN state = 'successful' THEN 1 END) AS successful_projects,
    concat(round((COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0 / COUNT(ProjectID)),2),'%') AS success_percentage
FROM 
    projects
GROUP BY 1
ORDER BY 2;
   
    