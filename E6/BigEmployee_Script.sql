SHOW WARNINGS;

DROP SCHEMA IF EXISTS `Big_Employees_DB`;
CREATE SCHEMA IF NOT EXISTS `Big_Employees_DB` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `Big_Employees_DB`;

-- Order to load .dump files: departments, employees, dept_emp, dept_manager, titles, salaries

-- ----------------------------------------------------------------
-- Table Employees
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `EMPLOYEES`;
CREATE TABLE IF NOT EXISTS `EMPLOYEES` (
    `Emp_No` INT NOT NULL,
    `Birth_Date` DATE NOT NULL,
    `First Name` VARCHAR(14) NOT NULL,
    `Last_Name` VARCHAR(16) NOT NULL,
    `Gender` ENUM ('M', 'F') NOT NULL,
    `Hire_Date` DATE,
    PRIMARY KEY (Emp_No)
);

-- ----------------------------------------------------------------
-- Table Departments
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `DEPARTMENTS`;
CREATE TABLE IF NOT EXISTS `DEPARTMENTS` (
    `Dept_No` CHAR(4) NOT NULL,
    `Dept_Name` VARCHAR(40) NOT NULL,
    PRIMARY KEY (Dept_No),
    UNIQUE KEY (Dept_Name)
);

-- ----------------------------------------------------------------
-- Table Dept_Manager
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `DEPT_MANAGER`;
CREATE TABLE IF NOT EXISTS `DEPT_MANAGER` (
    `Emp_No` INT NOT NULL,
    `Dept_No` CHAR(4) NOT NULL,
    `From_Date` DATE NOT NULL,
    `To_Date` DATE NOT NULL,
    FOREIGN KEY (Emp_No) REFERENCES EMPLOYEES(Emp_No) ON DELETE CASCADE,
    FOREIGN KEY (Dept_No) REFERENCES DEPARTMENTS(Dept_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, Dept_No)
);

-- ----------------------------------------------------------------
-- Table Dept_Emp
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `DEPT_EMP`;
CREATE TABLE IF NOT EXISTS `DEPT_EMP` (
    `Emp_No` INT NOT NULL,
    `Dept_No` CHAR(4) NOT NULL,
    `From_Date` DATE NOT NULL,
    `To_Date` DATE NOT NULL,
    FOREIGN KEY (Emp_No) REFERENCES EMPLOYEES(Emp_No) ON DELETE CASCADE,
    FOREIGN KEY (Dept_No) REFERENCES DEPARTMENTS(Dept_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, Dept_No)
);

-- ----------------------------------------------------------------
-- Table Titles
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `TITLES`;
CREATE TABLE IF NOT EXISTS `TITLES` (
    `Emp_No` INT NOT NULL,
    `Title` VARCHAR(50) NOT NULL,
    `From_Date` DATE NOT NULL,
    `To_Date` DATE,
    FOREIGN KEY (Emp_No) REFERENCES EMPLOYEES(Emp_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, Title, From_Date)
);

-- ----------------------------------------------------------------
-- Table Salaries
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `SALARIES`;
CREATE TABLE IF NOT EXISTS `SALARIES` (
    `Emp_No` INT NOT NULL,
    `Salary` INT NOT NULL,
    `From_Date` DATE NOT NULL,
    `To_Date` DATE NOT NULL,
    FOREIGN KEY (Emp_No) REFERENCES EMPLOYEES(Emp_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, From_Date)
);

-- Load .dump files

SELECT * FROM EMPLOYEES;
SELECT * FROM DEPARTMENTS;
SELECT * FROM DEPT_EMP;
SELECT * FROM DEPT_MANAGER;
SELECT * FROM TITLES;
SELECT * FROM SALARIES;