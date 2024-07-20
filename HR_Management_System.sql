--******************************** Basic Queries ******************************/

--Retrieve all employee details:

SELECT * FROM Employees;

--Retrieve employee details along with department and job title:

SELECT e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName, j.JobTitle
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Jobs j ON e.JobID = j.JobID;

--Find employees in 'Human Resources' department:

SELECT e.EmployeeID, e.FirstName, e.LastName
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Human Resources';

--Get the number of employees in each department:

SELECT d.DepartmentName, COUNT(e.EmployeeID) AS EmployeeCount
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

--Calculate total salary expenditure for each department:

SELECT d.DepartmentName, SUM(e.Salary) AS TotalSalary
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

--Retrieve employees with salaries above 60000:

SELECT EmployeeID, FirstName, LastName, Salary
FROM Employees
WHERE Salary > 60000;

--Calculate attendance percentage for each employee:

SELECT e.EmployeeID, e.FirstName, e.LastName,
       (SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.AttendanceID)) AS AttendancePercentage
FROM Employees e
JOIN Attendance a ON e.EmployeeID = a.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

--Retrieve leave records for a specific employee:

SELECT * FROM Leave
WHERE EmployeeID = 1;

--Get the total number of leave days taken by each employee:

SELECT 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName,       
    SUM(l.enddate - l.startdate)+1 as TotalLeaveDays       
FROM Employees e
JOIN Leave l ON e.EmployeeID = l.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName   
;

--Get average performance rating for each employee:

SELECT e.EmployeeID, e.FirstName, e.LastName,
       AVG(pr.Rating) AS AverageRating
FROM Employees e
JOIN PerformanceReviews pr ON e.EmployeeID = pr.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

--Get employees with performance ratings above a certain threshold:

SELECT e.EmployeeID, e.FirstName, e.LastName, AVG(pr.Rating) AS AverageRating
FROM Employees e
JOIN PerformanceReviews pr ON e.EmployeeID = pr.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
HAVING AVG(pr.Rating) > 4;

--******************************** Complex Queries ******************************/

--Retrieve Employees with the Longest Tenure in Each Department

SELECT e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName, e.HireDate
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate = (
    SELECT MIN(HireDate)
    FROM Employees
    WHERE DepartmentID = e.DepartmentID
);

SELECT 
    e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName, e.HireDate
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate IN (
    SELECT MinHireDate FROM(
    SELECT 
        DepartmentID,
        MIN(HireDate) AS MinHireDate
    FROM Employees
    GROUP BY DepartmentID)
);

SELECT EmployeeID, FirstName, LastName, DepartmentName, HireDate 
FROM(
SELECT distinct
    e.EmployeeID, e.FirstName, e.LastName, d.DepartmentName, e.HireDate,    
    ROW_NUMBER() OVER(PARTITION BY e.DepartmentID ORDER BY e.HireDate) AS MinHireDate
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
)
WHERE MinHireDate = 1
;

--Calculate Total Salary Expenditure and Average Salary by Department and Job Title

SELECT d.DepartmentName, j.JobTitle, SUM(e.Salary) AS TotalSalary, AVG(e.Salary) AS AverageSalary
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Jobs j ON e.JobID = j.JobID
GROUP BY d.DepartmentName, j.JobTitle;

--Retrieve Employees Who Have Never Taken Leave

SELECT e.EmployeeID, e.FirstName, e.LastName
FROM Employees e
LEFT JOIN Leave l ON e.EmployeeID = l.EmployeeID
WHERE l.EmployeeID IS NULL;

--Calculate the Average Attendance Percentage by Department

SELECT d.DepartmentName, AVG(
    CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END
) * 100.0 / COUNT(a.AttendanceID) AS AverageAttendancePercentage
FROM Employees e
JOIN Attendance a ON e.EmployeeID = a.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

--Retrieve Top 5 Employees with the Highest Average Performance Rating

SELECT * FROM
(
    SELECT e.EmployeeID, e.FirstName, e.LastName, AVG(pr.Rating) AS AverageRating
    FROM Employees e
    JOIN PerformanceReviews pr ON e.EmployeeID = pr.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName
    ORDER BY AverageRating DESC
)
WHERE ROWNUM <= 5;

--Calculate the Total Number of Leave Days Taken by Each Department

SELECT 
    d.DepartmentName,     
    SUM((l.EndDate - l.StartDate) + 1) AS TotalLeaveDays
FROM Employees e
JOIN Leave l ON e.EmployeeID = l.EmployeeID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

--Retrieve Employees Who Have Not Received a Performance Review in the Last Year

SELECT e.EmployeeID, e.FirstName, e.LastName
FROM Employees e
LEFT JOIN PerformanceReviews pr ON e.EmployeeID = pr.EmployeeID 
AND pr.ReviewDate > ADD_MONTHS(SYSDATE,-12)
WHERE pr.ReviewDate IS NULL;

--Calculate the Monthly Payroll Cost for the Last 6 Months

SELECT     
    TO_CHAR(TO_DATE(HireDate,'DD-MON-YY'), 'YYYY-MON') AS Month,
    SUM(Salary) AS MonthlyPayrollCost
FROM Employees
WHERE HireDate >= ADD_MONTHS(SYSDATE,-6)
GROUP BY TO_CHAR(TO_DATE(HireDate,'DD-MON-YY'), 'YYYY-MON')
ORDER BY Month DESC;

--Retrieve Employees Who Have Taken the Most Leaves

SELECT * FROM
(
SELECT e.EmployeeID, e.FirstName, e.LastName, COUNT(l.LeaveID) AS NumberOfLeaves
FROM Employees e
JOIN Leave l ON e.EmployeeID = l.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY NumberOfLeaves DESC
)
WHERE ROWNUM <= 10;

--Calculate the Distribution of Employees by Age Group

SELECT 
    CASE
        WHEN ROUND((sysdate - dateofbirth)/365) < 30 THEN 'Under 30'
        WHEN ROUND((sysdate - dateofbirth)/365) BETWEEN 30 AND 39 THEN '30-39'
        WHEN ROUND((sysdate - dateofbirth)/365) BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS AgeGroup,
    COUNT(EmployeeID) AS EmployeeCount
FROM Employees
GROUP BY 
    CASE
        WHEN ROUND((sysdate - dateofbirth)/365) < 30 THEN 'Under 30'
        WHEN ROUND((sysdate - dateofbirth)/365) BETWEEN 30 AND 39 THEN '30-39'
        WHEN ROUND((sysdate - dateofbirth)/365) BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END;



