SHOW WARNINGS;

DROP SCHEMA IF EXISTS `EmployeesDB`;
CREATE SCHEMA IF NOT EXISTS `EmployeesDB` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `EmployeesDB`;

DROP TABLE IF EXISTS `Employees`;
CREATE TABLE `Employees` (
`EMPLOYEE_ID` INT AUTO_INCREMENT,
`FIRST_NAME` VARCHAR(20) DEFAULT NULL,
`LAST_NAME` VARCHAR(25) NOT NULL,
`EMAIL` VARCHAR(25) NOT NULL,
`PHONE_NUMBER` VARCHAR(20) DEFAULT NULL,
`HIRE_DATE` date NOT NULL,
`JOB_ID` VARCHAR(10) NOT NULL,
`SALARY` DECIMAL(8,2) DEFAULT NULL,
`COMMISSION_PCT` DECIMAL(2,2) DEFAULT NULL,
`MANAGER_ID` INT DEFAULT NULL,
`DEPARTMENT_ID` INT DEFAULT NULL,
PRIMARY KEY (`EMPLOYEE_ID`),
UNIQUE KEY `EMP_EMAIL_UK` (`EMAIL`)
);

INSERT INTO `Employees` VALUES
(100,'Steven','King','SKING','515.123.4567','1987-06-17','AD_PRES',24000.00,0.00,0,90),
(101,'Neena','Kochhar','NKOCHHAR','515.123.4568','1987-06-18','AD_VP',17000.00,0.00,100,90),
(102,'Lex','De Haan','LDEHAAN','515.123.4569','1987-06-19','AD_VP',17000.00,0.00,100,90),
(103,'Alexander','Hunold','AHUNOLD','590.423.4567','1987-06-20','IT_PROG',9000.00,0.00,102,60),
(104,'Bruce','Ernst','BERNST','590.423.4568','1987-06-21','IT_PROG',6000.00,0.00,103,60),
(105,'David','Austin','DAUSTIN','590.423.4569','1987-06-22','IT_PROG',4800.00,0.00,103,60),
(106,'Valli','Pataballa','VPATABAL','590.423.4560','1987-06-23','IT_PROG',4800.00,0.00,103,60),
(107,'Diana','Lorentz','DLORENTZ','590.423.5567','1987-06-24','IT_PROG',4200.00,0.00,103,60),
(108,'Nancy','Greenberg','NGREENBE','515.124.4569','1987-06-25','FI_MGR',12000.00,0.00,101,100),
(109,'Daniel','Faviet','DFAVIET','515.124.4169','1987-06-26','FI_ACCOUNT',9000.00,0.00,108,100),
(110,'John','Chen','JCHEN','515.124.4269','1987-06-27','FI_ACCOUNT',8200.00,0.00,108,100),
(111,'Ismael','Sciarra','ISCIARRA','515.124.4369','1987-06-28','FI_ACCOUNT',7700.00,0.00,108,100),
(112,'Jose Manuel','Urman','JMURMAN','515.124.4469','1987-06-29','FI_ACCOUNT',7800.00,0.00,108,100),
(113,'Luis','Popp','LPOPP','515.124.4567','1987-06-30','FI_ACCOUNT',6900.00,0.00,108,100),
(114,'Den','Raphaely','DRAPHEAL','515.127.4561','1987-07-01','PU_MAN',11000.00,0.00,100,30),
(115,'Alexander','Khoo','AKHOO','515.127.4562','1987-07-02','PU_CLERK',3100.00,0.00,114,30),
(116,'Shelli','Baida','SBAIDA','515.127.4563','1987-07-03','PU_CLERK',2900.00,0.00,114,30),
(117,'Sigal','Tobias','STOBIAS','515.127.4564','1987-07-04','PU_CLERK',2800.00,0.00,114,30),
(118,'Guy','Himuro','GHIMURO','515.127.4565','1987-07-05','PU_CLERK',2600.00,0.00,114,30),
(119,'Karen','Colmenares','KCOLMENA','515.127.4566','1987-07-06','PU_CLERK',2500.00,0.00,114,30),
(120,'Matthew','Weiss','MWEISS','650.123.1234','1987-07-07','ST_MAN',8000.00,0.00,100,50),
(121,'Adam','Fripp','AFRIPP','650.123.2234','1987-07-08','ST_MAN',8200.00,0.00,100,50),
(122,'Payam','Kaufling','PKAUFLIN','650.123.3234','1987-07-09','ST_MAN',7900.00,0.00,100,50),
(123,'Shanta','Vollman','SVOLLMAN','650.123.4234','1987-07-10','ST_MAN',6500.00,0.00,100,50),
(124,'Kevin','Mourgos','KMOURGOS','650.123.5234','1987-07-11','ST_MAN',5800.00,0.00,100,50),
(125,'Julia','Nayer','JNAYER','650.124.1214','1987-07-12','ST_CLERK',3200.00,0.00,120,50),
(126,'Irene','Mikkilineni','IMIKKILI','650.124.1224','1987-07-13','ST_CLERK',2700.00,0.00,120,50),
(127,'James','Landry','JLANDRY','650.124.1334','1987-07-14','ST_CLERK',2400.00,0.00,120,50),
(128,'Steven','Markle','SMARKLE','650.124.1434','1987-07-15','ST_CLERK',2200.00,0.00,120,50),
(129,'Laura','Bissot','LBISSOT','650.124.5234','1987-07-16','ST_CLERK',3300.00,0.00,121,50),
(130,'Mozhe','Atkinson','MATKINSO','650.124.6234','1987-07-17','ST_CLERK',2800.00,0.00,121,50),
(131,'James','Marlow','JAMRLOW','650.124.7234','1987-07-18','ST_CLERK',2500.00,0.00,121,50),
(132,'TJ','Olson','TJOLSON','650.124.8234','1987-07-19','ST_CLERK',2100.00,0.00,121,50),
(133,'Jason','Mallin','JMALLIN','650.127.1934','1987-07-20','ST_CLERK',3300.00,0.00,122,50),
(134,'Michael','Rogers','MROGERS','650.127.1834','1987-07-21','ST_CLERK',2900.00,0.00,122,50),
(135,'Ki','Gee','KGEE','650.127.1734','1987-07-22','ST_CLERK',2400.00,0.00,122,50),
(136,'Hazel','Philtanker','HPHILTAN','650.127.1634','1987-07-23','ST_CLERK',2200.00,0.00,122,50),
(137,'Renske','Ladwig','RLADWIG','650.121.1234','1987-07-24','ST_CLERK',3600.00,0.00,123,50),
(138,'Stephen','Stiles','SSTILES','650.121.2034','1987-07-25','ST_CLERK',3200.00,0.00,123,50),
(139,'John','Seo','JSEO','650.121.2019','1987-07-26','ST_CLERK',2700.00,0.00,123,50),
(140,'Joshua','Patel','JPATEL','650.121.1834','1987-07-27','ST_CLERK',2500.00,0.00,123,50),
(141,'Trenna','Rajs','TRAJS','650.121.8009','1987-07-28','ST_CLERK',3500.00,0.00,124,50),
(142,'Curtis','Davies','CDAVIES','650.121.2994','1987-07-29','ST_CLERK',3100.00,0.00,124,50),
(143,'Randall','Matos','RMATOS','650.121.2874','1987-07-30','ST_CLERK',2600.00,0.00,124,50),
(144,'Peter','Vargas','PVARGAS','650.121.2004','1987-07-31','ST_CLERK',2500.00,0.00,124,50),
(145,'John','Russell','JRUSSEL','011.44.1344.429268','1987-08-01','SA_MAN',14000.00,0.40,100,80),
(146,'Karen','Partners','KPARTNER','011.44.1344.467268','1987-08-02','SA_MAN',13500.00,0.30,100,80),
(147,'Alberto','Errazuriz','AERRAZUR','011.44.1344.429278','1987-08-03','SA_MAN',12000.00,0.30,100,80),
(148,'Gerald','Cambrault','GCAMBRAU','011.44.1344.619268','1987-08-04','SA_MAN',11000.00,0.30,100,80),
(149,'Eleni','Zlotkey','EZLOTKEY','011.44.1344.429018','1987-08-05','SA_MAN',10500.00,0.20,100,80),
(150,'Peter','Tucker','PTUCKER','011.44.1344.129268','1987-08-06','SA_REP',10000.00,0.30,145,80),
(151,'David','Bernstein','DBERNSTE','011.44.1344.345268','1987-08-07','SA_REP',9500.00,0.25,145,80),
(152,'Peter','Hall','PHALL','011.44.1344.478968','1987-08-08','SA_REP',9000.00,0.25,145,80),
(153,'Christopher','Olsen','COLSEN','011.44.1344.498718','1987-08-09','SA_REP',8000.00,0.20,145,80),
(154,'Nanette','Cambrault','NCAMBRAU','011.44.1344.987668','1987-08-10','SA_REP',7500.00,0.20,145,80),
(155,'Oliver','Tuvault','OTUVAULT','011.44.1344.486508','1987-08-11','SA_REP',7000.00,0.15,145,80),
(156,'Janette','King','JKING','011.44.1345.429268','1987-08-12','SA_REP',10000.00,0.35,146,80),
(157,'Patrick','Sully','PSULLY','011.44.1345.929268','1987-08-13','SA_REP',9500.00,0.35,146,80),
(158,'Allan','McEwen','AMCEWEN','011.44.1345.829268','1987-08-14','SA_REP',9000.00,0.35,146,80),
(159,'Lindsey','Smith','LSMITH','011.44.1345.729268','1987-08-15','SA_REP',8000.00,0.30,146,80),
(160,'Louise','Doran','LDORAN','011.44.1345.629268','1987-08-16','SA_REP',7500.00,0.30,146,80),
(161,'Sarath','Sewall','SSEWALL','011.44.1345.529268','1987-08-17','SA_REP',7000.00,0.25,146,80),
(162,'Clara','Vishney','CVISHNEY','011.44.1346.129268','1987-08-18','SA_REP',10500.00,0.25,147,80),
(163,'Danielle','Greene','DGREENE','011.44.1346.229268','1987-08-19','SA_REP',9500.00,0.15,147,80),
(164,'Mattea','Marvins','MMARVINS','011.44.1346.329268','1987-08-20','SA_REP',7200.00,0.10,147,80),
(165,'David','Lee','DLEE','011.44.1346.529268','1987-08-21','SA_REP',6800.00,0.10,147,80),
(166,'Sundar','Ande','SANDE','011.44.1346.629268','1987-08-22','SA_REP',6400.00,0.10,147,80),
(167,'Amit','Banda','ABANDA','011.44.1346.729268','1987-08-23','SA_REP',6200.00,0.10,147,80),
(168,'Lisa','Ozer','LOZER','011.44.1343.929268','1987-08-24','SA_REP',11500.00,0.25,148,80),
(169,'Harrison','Bloom','HBLOOM','011.44.1343.829268','1987-08-25','SA_REP',10000.00,0.20,148,80),
(170,'Tayler','Fox','TFOX','011.44.1343.729268','1987-08-26','SA_REP',9600.00,0.20,148,80),
(171,'William','Smith','WSMITH','011.44.1343.629268','1987-08-27','SA_REP',7400.00,0.15,148,80),
(172,'Elizabeth','Bates','EBATES','011.44.1343.529268','1987-08-28','SA_REP',7300.00,0.15,148,80),
(173,'Sundita','Kumar','SKUMAR','011.44.1343.329268','1987-08-29','SA_REP',6100.00,0.10,148,80),
(174,'Ellen','Abel','EABEL','011.44.1644.429267','1987-08-30','SA_REP',11000.00,0.30,149,80),
(175,'Alyssa','Hutton','AHUTTON','011.44.1644.429266','1987-08-31','SA_REP',8800.00,0.25,149,80),
(176,'Jonathon','Taylor','JTAYLOR','011.44.1644.429265','1987-09-01','SA_REP',8600.00,0.20,149,80),
(177,'Jack','Livingston','JLIVINGS','011.44.1644.429264','1987-09-02','SA_REP',8400.00,0.20,149,80),
(178,'Kimberely','Grant','KGRANT','011.44.1644.429263','1987-09-03','SA_REP',7000.00,0.15,149,0),
(179,'Charles','Johnson','CJOHNSON','011.44.1644.429262','1987-09-04','SA_REP',6200.00,0.10,149,80),
(180,'Winston','Taylor','WTAYLOR','650.507.9876','1987-09-05','SH_CLERK',3200.00,0.00,120,50),
(181,'Jean','Fleaur','JFLEAUR','650.507.9877','1987-09-06','SH_CLERK',3100.00,0.00,120,50),
(182,'Martha','Sullivan','MSULLIVA','650.507.9878','1987-09-07','SH_CLERK',2500.00,0.00,120,50),
(183,'Girard','Geoni','GGEONI','650.507.9879','1987-09-08','SH_CLERK',2800.00,0.00,120,50),
(184,'Nandita','Sarchand','NSARCHAN','650.509.1876','1987-09-09','SH_CLERK',4200.00,0.00,121,50),
(185,'Alexis','Bull','ABULL','650.509.2876','1987-09-10','SH_CLERK',4100.00,0.00,121,50),
(186,'Julia','Dellinger','JDELLING','650.509.3876','1987-09-11','SH_CLERK',3400.00,0.00,121,50),
(187,'Anthony','Cabrio','ACABRIO','650.509.4876','1987-09-12','SH_CLERK',3000.00,0.00,121,50),
(188,'Kelly','Chung','KCHUNG','650.505.1876','1987-09-13','SH_CLERK',3800.00,0.00,122,50),
(189,'Jennifer','Dilly','JDILLY','650.505.2876','1987-09-14','SH_CLERK',3600.00,0.00,122,50),
(190,'Timothy','Gates','TGATES','650.505.3876','1987-09-15','SH_CLERK',2900.00,0.00,122,50),
(191,'Randall','Perkins','RPERKINS','650.505.4876','1987-09-16','SH_CLERK',2500.00,0.00,122,50),
(192,'Sarah','Bell','SBELL','650.501.1876','1987-09-17','SH_CLERK',4000.00,0.00,123,50),
(193,'Britney','Everett','BEVERETT','650.501.2876','1987-09-18','SH_CLERK',3900.00,0.00,123,50),
(194,'Samuel','McCain','SMCCAIN','650.501.3876','1987-09-19','SH_CLERK',3200.00,0.00,123,50),
(195,'Vance','Jones','VJONES','650.501.4876','1987-09-20','SH_CLERK',2800.00,0.00,123,50),
(196,'Alana','Walsh','AWALSH','650.507.9811','1987-09-21','SH_CLERK',3100.00,0.00,124,50),
(197,'Kevin','Feeney','KFEENEY','650.507.9822','1987-09-22','SH_CLERK',3000.00,0.00,124,50),
(198,'Donald','OConnell','DOCONNEL','650.507.9833','1987-09-23','SH_CLERK',2600.00,0.00,124,50),
(199,'Douglas','Grant','DGRANT','650.507.9844','1987-09-24','SH_CLERK',2600.00,0.00,124,50),
(200,'Jennifer','Whalen','JWHALEN','515.123.4444','1987-09-25','AD_ASST',4400.00,0.00,101,10),
(201,'Michael','Hartstein','MHARTSTE','515.123.5555','1987-09-26','MK_MAN',13000.00,0.00,100,20),
(202,'Pat','Fay','PFAY','603.123.6666','1987-09-27','MK_REP',6000.00,0.00,201,20),
(203,'Susan','Mavris','SMAVRIS','515.123.7777','1987-09-28','HR_REP',6500.00,0.00,101,40),
(204,'Hermann','Baer','HBAER','515.123.8888','1987-09-29','PR_REP',10000.00,0.00,101,70),
(205,'Shelley','Higgins','SHIGGINS','515.123.8080','1987-09-30','AC_MGR',12000.00,0.00,101,110),
(206,'William','Gietz','WGIETZ','515.123.8181','1987-10-01','AC_ACCOUNT',8300.00,0.00,205,110);

SELECT * FROM Employees; -- 102 rows start

-- 1. Incrementar el salario en un 10% para todos los empleados que Salary > 3000.00.

SELECT FIRST_NAME, SALARY
FROM Employees
WHERE SALARY < 3000.00; -- 24 tuples (re launch after UPDATE query for changes) -> 17 after

UPDATE Employees
SET Salary = Salary * 1.1
WHERE SALARY < 3000.00;

-- 2. Eliminar todos los empleados cuyo MANAGER_ID = 100 y DEP_ID = 50.

SELECT *
FROM Employees
WHERE MANAGER_ID = 100 AND DEPARTMENT_ID = 50;

DELETE
FROM Employees
WHERE MANAGER_ID = 100 AND DEPARTMENT_ID = 50;

-- The select is just to check if it has worked properly. We can see that it did. Also another thing to note is that
-- in the DDL here our only CONSTRAINT is a PRIMARY KEY. As there are no FOREIGN KEYS, we do not have to worry about
-- enabling/disabling to not compromise integrity

-- 3. Aumentar la comisión en 0.05 para los empleados comerciales cuyo JOB_ID = "SA_" y que fueron contratados en agosto de 1987.

SELECT
    COMMISSION_PCT,
    JOB_ID,
    HIRE_DATE
FROM Employees
WHERE JOB_ID LIKE 'SA_%'
    AND HIRE_DATE BETWEEN '1987-08-01' AND '1987-08-31'
ORDER BY HIRE_DATE ASC;

UPDATE Employees
SET COMMISSION_PCT = COMMISSION_PCT + 0.05
WHERE JOB_ID LIKE 'SA_%'
    AND HIRE_DATE BETWEEN '1987-08-01' AND '1987-08-31';

-- 4. Mostrar el: First_Name, Last_Name, Phone_Number y Salary de aquellos empleados que Salary < 3000e y su JOB_ID = "ST_CLERK".
-- Se deberán de asignar alias para cada columna. Deberá de estar ordenado por Salary en orden DESC.

SELECT concat(LAST_NAME, ', ', FIRST_NAME) AS 'Employee Name', PHONE_NUMBER AS 'Employee Phone Number', SALARY AS 'Salary'
FROM Employees
WHERE SALARY < 3000.00 AND JOB_ID = 'ST_CLERK'
ORDER BY SALARY DESC;

-- 5. Mostrar el: First_Name, Last_Name y Hire_DATE de aquellos empleados que hayan sido contratados entre
-- 1987-07-10 y 1987-09-10 del Department_ID = 50. Los resultados deben de estar ordenados por Hire_Date.

SELECT
    FIRST_NAME AS 'First Name',
    LAST_NAME AS 'Last Name',
    HIRE_DATE AS 'Hire Date'
FROM Employees
WHERE HIRE_DATE BETWEEN '1987-07-10' AND '1987-09-10' AND
    DEPARTMENT_ID IN (
        SELECT DEPARTMENT_ID
        FROM Employees
        WHERE DEPARTMENT_ID = 50
        )
ORDER BY HIRE_DATE ASC;

SELECT
    FIRST_NAME AS 'First Name',
    LAST_NAME AS 'Last Name',
    HIRE_DATE AS 'Hire Date'
FROM Employees
WHERE DEPARTMENT_ID = 50 AND
    HIRE_DATE BETWEEN '1987-07-10' AND '1987-09-10'
ORDER BY HIRE_DATE ASC;

-- Both versions of the Query can be used. They produce the same result. However the second one is a bit easier
-- to understand

-- 6. Contar y mostrar todos los empleados que Salary > 10000.

SELECT FIRST_NAME AS 'Employee Name', count(*) AS 'Quantity'
FROM Employees
WHERE SALARY > 10000.00
GROUP BY FIRST_NAME
ORDER BY 'Quantity' ASC;

SELECT count(*) AS 'How many people earn more than $10000.00'
FROM Employees
WHERE SALARY > 10000.00;

/*

This Query shows the First Name of the Employees who earn more than 10000.00 and also counts
how many people with that same First Name earn that amount (thanks to the Group By).
Since this is a small database, we don't have many names repeated. And even less people with a salary
higher than 10000.00 who also happen to share the same First Name.

If we only wanted to know how many people earn that amount, then the second Query would be the answer.

The INSERT below is there to prove that the GROUP BY Query works. If we are to INSERT a person with the same
First Name as one of the people that already exists with a Salary of > 10000.00, it will return a counter of 2
Then the DELETE is there to not mess up the database :)

INSERT INTO `Employees` VALUES (207,'Steven','Testing','Piss','525.123.4567','1988-06-17','AD_PRES',69000.00, 0.00, 0,90);

DELETE
FROM Employees
WHERE EMPLOYEE_ID = 207;

*/

-- 7. Calcular la suma y media de los salarios de los empleados por departamento.

SELECT
    DEPARTMENT_ID AS 'Department ID',
    sum(SALARY) AS 'Sum Salaries by Department',
    avg(SALARY) AS 'Average Salaries by Department'
FROM employees
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID DESC ;

-- 8. Calcular el salario mínimo y máximo para cada tipo de trabajo (Job_ID) excluyendo Job_ID = "IT_PROG", "SA_MAN" & "SA_REP".

SELECT
    JOB_ID AS 'Type of Work',
    min(SALARY) AS 'Minimum Salary',
    max(SALARY) AS 'Maximum Salary'
FROM Employees
WHERE JOB_ID NOT IN (
    SELECT JOB_ID
    FROM Employees
    WHERE JOB_ID IN (
        'IT_PROG',
        'SA_MAN',
        'SA_REP'
        )
)
GROUP BY JOB_ID
ORDER BY JOB_ID;

-- You could also do a WHERE JOB_ID = ... but would have to repeat that as many times as JOB_ID's you want to
-- not include. So doing it with a IN is a bit prettier

-- 9. Listar los trabajos cuyo salario sea > $5000 ordenados por la media de los salarios totales

SELECT
    JOB_ID AS 'Type of Work',
    avg(SALARY) AS 'Average_Salary'
FROM Employees
GROUP BY JOB_ID
HAVING Average_Salary > 5000.00
ORDER BY 'Average Salary' ASC;

/*

Ok few things here. HAVING is used after the GROUP BY clause. It basically a filter, just like WHERE
but applied after the GROUP BY

Also take into account that if we want to reference an alias using HAVING, it must be without '' and if it
contains spaces then replace them with _

*/

-- 10. Sacar: (1) el empleado con el salario más alto, (2) el empleado con el salario más bajo, (3) empleados cuyo
-- salario coincide con la media de salarios de todos los empleados, (4) ¿cuántos empleados tienen un salario mayor que
-- la media? ¿quiénes son? y (5) ¿cuántos menor que la media? ¿quiénes son?

SELECT min(SALARY) AS 'Min', -- 2310
       max(SALARY) AS 'Max', -- 24000
       avg(SALARY) AS 'Average' -- 6482.35
FROM Employees;

SELECT
    FIRST_NAME AS 'First Name',
    SALARY AS 'Salary'
FROM Employees
WHERE Salary = (
    SELECT avg(SALARY)
    FROM Employees);

SELECT
    EMPLOYEE_ID AS 'Employee ID',
    concat(LAST_NAME, ', ', FIRST_NAME) AS 'Employee Name',
    SALARY AS 'Salary'
FROM Employees
WHERE Salary >= (
    SELECT avg(SALARY)
    FROM Employees);

SELECT
    EMPLOYEE_ID AS 'Employee ID',
    concat(LAST_NAME, ', ', FIRST_NAME) AS 'Employee Name',
    SALARY AS 'Salary'
FROM Employees
WHERE Salary <= (
    SELECT avg(SALARY)
    FROM Employees);


SELECT COUNT(*) AS 'Employees with Salary Above Average'
FROM Employees
WHERE SALARY > (
    SELECT AVG(SALARY)
    FROM Employees);

SELECT COUNT(*) AS 'Employees with Salary Below Average'
FROM Employees
WHERE SALARY < (
    SELECT AVG(SALARY)
    FROM Employees);


-- With the first Query with show both the lowest, highest and also as an extra the average salaries between
-- all of the employees

-- Then with the second Query we filter who has a Salary that is equivalent of the average of all of the salaries
-- in the whole company

-- With the third and fourth Querys we filter who has a Salary that is above/below the average of all the salaries
-- in the company

-- Finally the 5th and 6th Querys shows how many employees have a salary above/below the average. This could already be seen
-- in the third and fourth Querys (number of tuples), but this way it is a bit clearer

-- 11. Suma y promedio de los salarios de cada JOB_ID

SELECT
    JOB_ID AS 'Type of Work',
    sum(SALARY) AS 'Sum of Salaries by Type of Work',
    avg(SALARY) AS 'Average of Salaries by Type of Work'
FROM Employees
GROUP BY JOB_ID
ORDER BY JOB_ID;