CREATE DATABASE Employee_Management_System;
USE Employee_Management_System;

CREATE TABLE JobDepartment (
Job_ID INT PRIMARY KEY,
jobdept VARCHAR(50),
name VARCHAR(100),
description TEXT,
salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
salary_ID INT PRIMARY KEY,
Job_ID INT,
amount DECIMAL(10,2),
annual DECIMAL(10,2),
bonus DECIMAL(10,2),
CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
emp_ID INT PRIMARY KEY,
firstname VARCHAR(50),
lastname VARCHAR(50),
gender VARCHAR(10),
age INT,
contact_add VARCHAR(100),
emp_email VARCHAR(100) UNIQUE,
emp_pass VARCHAR(50),
Job_ID INT,
CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
REFERENCES JobDepartment(Job_ID)
ON DELETE SET NULL
ON UPDATE CASCADE
);
-- Table 4: Qualification
CREATE TABLE Qualification (
QualID INT PRIMARY KEY,
Emp_ID INT,
Position VARCHAR(50),
Requirements VARCHAR(255),
Date_In DATE,
CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
REFERENCES Employee(emp_ID)
ON DELETE CASCADE
ON UPDATE CASCADE
);
-- Table 5: Leaves
CREATE TABLE Leaves (
leave_ID INT PRIMARY KEY,
emp_ID INT,
date DATE,
reason TEXT,
CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 6: Payroll
CREATE TABLE Payroll (
payroll_ID INT PRIMARY KEY,
emp_ID INT,
job_ID INT,
salary_ID INT,
leave_ID INT,
date DATE,
report TEXT,
total_amount DECIMAL(10,2),
CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES
SalaryBonus(salary_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
ON DELETE SET NULL ON UPDATE CASCADE
);

-- Which departments have the highest number of employees?

select d.jobdept,count(e.emp_id) as total_emp from jobdepartment as d
join employee as e
on d.job_id = e.job_id
group by d.jobdept order by total_emp desc limit 1;

-- What is the average salary per department

select d.jobdept,avg(s.amount) as avg_salary from salarybonus as s
join  jobdepartment as d
on s.job_id = d.job_id
group by d.jobdept;

-- How many different job roles exist in each 
-- department
select jobdept,count(name)as dif_roles 
from jobdepartment
group by jobdept order by dif_roles desc;
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT e.emp_ID) AS qualified_employees
FROM Employee e
JOIN Qualification q
ON e.emp_ID = q.Emp_ID;

-- What is the average bonus given per department?

SELECT d.jobdept,
       ROUND(AVG(s.bonus),2) AS avg_bonus
FROM JobDepartment d
JOIN SalaryBonus s
ON d.Job_ID = s.Job_ID
GROUP BY d.jobdept;

-- What is the total monthly payroll processed?

SELECT YEAR(date) AS year,
       MONTHNAME(date) AS month,
       SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date), MONTHNAME(date)
ORDER BY YEAR(date), MONTH(date);

-- What is the average number of leave days taken by its employees per department

SELECT
    d.jobdept,
    COUNT(*) / COUNT(DISTINCT e.emp_id) AS avg_leave_days
FROM leaves l
JOIN employee e
    ON e.emp_id = l.emp_id
JOIN jobdepartment d
    ON d.job_id = e.job_id
GROUP BY d.jobdept;