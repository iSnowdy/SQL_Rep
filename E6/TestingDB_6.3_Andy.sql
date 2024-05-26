/*

DISCLAIMER: The creation of the Schema `Big_Employees_DB` is in a different .sql file.
Also it is required to load .dump files in order to have the data inserted into the database (DB).

DB source: https://github.com/datacharmer/test_db/tree/master

The Company X has a DB called Big_Employees_DB (which will be called OG (original) DB henceforth). They use this DB to
keep track of their employees.

On the other hand, the development team has a reduced version of this OG DB that they use to carry out a wide
array of tasks and code testings. Lets call this reduced version of the DB Testing_DB.

The programming team *demands* that every morning fresh data is thrown into this Testing_DB, so that they work with the
updated data from the OG DB.

Our task is to create an event that, at a determined hour (morning), the Testing_DB is refreshed. In order to do this:

    1. Completely empty the existing Testing_DB. The content of this Testing_DB has been "sullied" and has contaminated
date from the work done on the previous day, so we are not interested in it. Also new data may have been inserted in the
OG DB.
    2. Then we dump fresh data into the Testing_DB from the OG DB. However! we are not interested in everything, since
the OG DB has way too much data. So we are only interested in a small sample of it.

As to what is considered "interesting" from the OG DB to be dumped into the Testing_DB, the criteria is the following:

    - Departments. Everything is dumped.
    - Dept_Emp. Only active tuples. Meaning: To_Date = '9999-01-01'. This date is an internal way that the company has
of saying "this employee is alive and working with us up to this date".
    - Dept_Manager. Only active tuples. Same as before; To_Date = '9999-01-01'.
    - Employees. Only active employees. Active employees are those that are somehow related to a department and the
date is also '9999-01-01'.
    - Salaries. Only the active employees AND the current salary of those employees. Also To_Date = '9999-01-01'.
    - Titles. Only from the active employees AND also their current title. Same criteria as for Salaries.

*/

USE big_employees_db;

SELECT * FROM big_employees_db.employees;
SELECT * FROM big_employees_db.DEPARTMENTS;
SELECT * FROM big_employees_db.DEPT_EMP;
SELECT * FROM big_employees_db.DEPT_MANAGER;
SELECT * FROM big_employees_db.TITLES;
SELECT * FROM big_employees_db.SALARIES;

DESC big_employees_db.EMPLOYEES;
DESC big_employees_db.DEPARTMENTS;
DESC big_employees_db.DEPT_EMP;
DESC big_employees_db.DEPT_MANAGER;
DESC big_employees_db.TITLES;
DESC big_employees_db.SALARIES;

-- First of all we have to create the Schema for the Testing_DB.

DROP SCHEMA IF EXISTS `Testing_BigEmployees_DB`;
CREATE SCHEMA IF NOT EXISTS `Testing_BigEmployees_DB` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `Testing_BigEmployees_DB`;

-- Order to load .dump files: departments, employees, dept_emp, dept_manager, titles, salaries

-- ----------------------------------------------------------------
-- Table Employees
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `TESTING_EMPLOYEES`;
CREATE TABLE IF NOT EXISTS `TESTING_EMPLOYEES` (
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

DROP TABLE IF EXISTS `TESTING_DEPARTMENTS`;
CREATE TABLE IF NOT EXISTS `TESTING_DEPARTMENTS` (
    `Dept_No` CHAR(4) NOT NULL,
    `Dept_Name` VARCHAR(40) NOT NULL,
    PRIMARY KEY (Dept_No),
    UNIQUE KEY (Dept_Name)
);

-- ----------------------------------------------------------------
-- Table Dept_Manager
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `TESTING_DEPT_MANAGER`;
CREATE TABLE IF NOT EXISTS `TESTING_DEPT_MANAGER` (
    `Emp_No` INT NOT NULL,
    `Dept_No` CHAR(4) NOT NULL,
    -- `From_Date` DATE NOT NULL, We are not interested in the historic
    `To_Date` DATE NOT NULL,
    FOREIGN KEY (Emp_No) REFERENCES TESTING_EMPLOYEES(Emp_No) ON DELETE CASCADE,
    FOREIGN KEY (Dept_No) REFERENCES TESTING_DEPARTMENTS(Dept_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, Dept_No)
);

-- ----------------------------------------------------------------
-- Table Dept_Emp
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `TESTING_DEPT_EMP`;
CREATE TABLE IF NOT EXISTS `TESTING_DEPT_EMP` (
    `Emp_No` INT NOT NULL,
    `Dept_No` CHAR(4) NOT NULL,
    -- `From_Date` DATE NOT NULL, We are not interested in the historic
    `To_Date` DATE NOT NULL,
    FOREIGN KEY (Emp_No) REFERENCES TESTING_EMPLOYEES(Emp_No) ON DELETE CASCADE,
    FOREIGN KEY (Dept_No) REFERENCES TESTING_DEPARTMENTS(Dept_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, Dept_No)
);

-- ----------------------------------------------------------------
-- Table Titles
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `TESTING_TITLES`;
CREATE TABLE IF NOT EXISTS `TESTING_TITLES` (
    `Emp_No` INT NOT NULL,
    `Title` VARCHAR(50) NOT NULL,
    -- `From_Date` DATE NOT NULL, We are not interested in the historic
    `To_Date` DATE,
    FOREIGN KEY (Emp_No) REFERENCES TESTING_EMPLOYEES(Emp_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No, Title)
);

-- ----------------------------------------------------------------
-- Table Salaries
-- ---------------------------------------------------------------

DROP TABLE IF EXISTS `TESTING_SALARIES`;
CREATE TABLE IF NOT EXISTS `TESTING_SALARIES` (
    `Emp_No` INT NOT NULL,
    `Salary` INT NOT NULL,
    -- `From_Date` DATE NOT NULL, We are not interested in the historic
    `To_Date` DATE NOT NULL,
    FOREIGN KEY (Emp_No) REFERENCES TESTING_EMPLOYEES(Emp_No) ON DELETE CASCADE,
    PRIMARY KEY (Emp_No)
);

-- Now we have the Testing_DB Schema without the attributes that we have no interest in (records such as From_Date).

-- 1. Emptying the Testing_DB.

/*

Ok so we have to empty any data that is currently being held in the Testing_DB every morning. Also we have to take
into account restrictions such as FK's. Probably.

We could do this in many different ways. The "brute" way would be to just do a DROP SCHEMA. But then that would imply
to run again all the DDL.

Another option would be to properly DELETE everything from the tables in order. Or maybe even DROP tables. Hmmm.
However we do have ON DELETE CASCADE here.

Maybe even consider using stored procedures and call them from the EVENT.

So apparently MySQL doesn't support setting start/end times in the SCHEDULE clause. So we need to find a work around :)

For that we will create 2 procedures and 1 event. The first procedure will only have a kind of checker if the time
we want is now. Then, if it is, it will run the second procedure which contains what we want to do. Finally, the EVENT
itself will run every lets say 1 hour and call the timer procedure.

This way we will have sort of a chain of things happening and only will execute when we want to. Also by separating
the procedures into 2 we can easily change when we want the main procedure to fire. Abstraction and modulation \o/

In the main procedure everything is wrapped inside a transaction. The reason being that a DELETE, even if its made in
a testing database, can be very dangerous. We are also disabling Foreign Keys so we are able to actually delete anything.
Also we are making use of the DELETE ON CASCADE declared on the DDL.

If anything goes wrong, we could do a ROLLBACK (which is commented) and *in theory* things would revert back to
its original state.

sources:
https://stackoverflow.com/questions/70578941/mysql-event-scheduler-every-day-start-at-12-am-and-continue-work-every-15-minute
https://dba.stackexchange.com/questions/234796/mysql-schedular-every-day-in-a-time-periode-every-hour

*/

SELECT VERSION();
SET @time = HOUR(current_timestamp);
SELECT @time;

SHOW VARIABLES WHERE Variable_name = 'autocommit'; -- ON / OFF

DELIMITER $$
DROP PROCEDURE IF EXISTS main_procedure_empty_TestDB $$
CREATE PROCEDURE main_procedure_empty_TestDB()
COMMENT
'
Procedure that actually deletes the data from the Test_DB
'
BEGIN

    START TRANSACTION;

        SET FOREIGN_KEY_CHECKS = 0; -- disabling FK's

        DELETE FROM TESTING_EMPLOYEES;
        DELETE FROM TESTING_DEPARTMENTS; -- *insert ON DELETE CASCADE meme*

        SET FOREIGN_KEY_CHECKS = 1; -- enabling FK's again
    -- ROLLBACK;
    COMMIT;

END $$

DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS check_time $$
CREATE PROCEDURE check_time()
COMMENT
'
Checks if the hour timestamp is "X". We can easily modify when to run the main procedure here by changing
this hour
'
BEGIN

    IF hour(current_timestamp) >= 5 THEN -- (X) put hour here to test :)
        CALL main_procedure_empty_TestDB();
    END IF;

END $$

DELIMITER ;


DELIMITER $$
DROP EVENT IF EXISTS Empty_Testing_DB $$
CREATE EVENT Empty_Testing_DB
ON SCHEDULE EVERY 1 HOUR
    STARTS now() -- STARTS now()
COMMENT
'
This event will call the procedure within it every hour starting the moment it is created.
Then, the procedure that is called will check time. If the time is what we want it to be, then
only then it will be called. This call will at the same time call the main procedure that we want
to execute: the deletion of everything inside the Testing_DB
'
DO
    BEGIN
        CALL check_time();
    END $$

DELIMITER ;

-- Sooo this *should* work :smileyface:

/*

Ok now we need to INSERT the filtered data into the Testing_DB.

After considering the criteria on which data has to be dumped into the Testing_DB, then we have to run another EVENT
that must be triggered after the EVENT to empty the Testing_DB is fired.

Think of a way to actually accomplish this.

Possible strategy:

    - Design the SELECTs for each attribute.
    - Modify those SELECTs into a procedure.
    - Fit in those procedure into the EVENT / another "main" procedure.
    - Work around to trigger the second event only after the first one is fired. Safety mechanism sort of? How?

*/

SET @examples = current_timestamp;
SELECT @examples;

-- Dept_Emp
SELECT *
FROM big_employees_db.dept_emp
WHERE To_Date = '9999-01-01'
ORDER BY To_Date DESC ; -- 331.603 -> 240.124

SELECT * FROM big_employees_db.dept_emp;

-- Dept_manager
SELECT *
FROM big_employees_db.dept_manager
WHERE To_Date = '9999-01-01'
ORDER BY To_Date DESC ; -- 24 -> 9

SELECT * FROM big_employees_db.dept_manager;

-- Employees
SELECT e.*
FROM big_employees_db.employees e
INNER JOIN big_employees_db.dept_emp e2
    ON e.Emp_No = e2.Emp_No
           AND e2.To_Date = '9999-01-01'

UNION

SELECT e.*
FROM big_employees_db.employees e
INNER JOIN big_employees_db.dept_manager e3
    ON e.Emp_No = e3.Emp_No
            AND e3.To_Date = '9999-01-01'; -- 300.024 -> 240.124


SELECT * FROM big_employees_db.employees;

SELECT * FROM big_employees_db.departments;

SELECT *
FROM big_employees_db.employees
WHERE Emp_No NOT IN (
    SELECT dept_emp.Emp_No
    FROM big_employees_db.dept_emp
    );

-- Salaries

SELECT * FROM big_employees_db.salaries;

SELECT *
FROM big_employees_db.salaries s
WHERE To_Date = '9999-01-01'
    AND s.Emp_No IN (
        SELECT e1.Emp_No
        FROM big_employees_db.dept_emp e1
        WHERE e1.To_Date = '9999-01-01'

        UNION

        SELECT e2.Emp_No
        FROM big_employees_db.dept_manager e2
        WHERE e2.To_Date = '9999-01-01'
    ); -- -> 2.844.047 -> 240.124


-- Titles

SELECT * FROM big_employees_db.titles;

SELECT *
FROM big_employees_db.titles t
WHERE To_Date = '9999-01-01'
    AND t.Emp_No IN (
        SELECT e1.Emp_No
        FROM big_employees_db.dept_emp e1
        WHERE e1.To_Date = '9999-01-01'

        UNION

        SELECT e2.Emp_No
        FROM big_employees_db.dept_manager e2
        WHERE e2.To_Date = '9999-01-01'
    ); -- 443.308 -> 240.124
