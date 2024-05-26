/*

DISCLAIMER: The creation of the Schema `Staff_Example` is in another .sql file; called Staff_Script and it is attached.

We must create the procedures to accomplish a CRUD. Meaning, we need to create procedures that INSERT, SELECT, UPDATE &
DELETE. Those procedures will have the following names:

    - crea_staff
    - read_staff
    - update_staff
    - delete_staff

The `Start Date` attribute will take the current date (curdate()).
If the `Salary` is higher than the max(Salary), then Salary = max.
If the `Salary` is lower than the min(Salary), then Salary = min.

To ensure that our CRUD is good enough, we must add a series of validations and error control. Some of those would include:

    * Verify that IN parameters, if we have them, aren't "NOT NULL".
    * Verify that DATATYPES are the correct ones. Meaning that if the IN is a VARCHAR, it actually is a VARCHAR
    * Verify that the IN parameters are within the accepted range of parameters. So if the IN is a VARCHAR(55), the
    IN parameter that we are taking can't be more than 55 characters long.
    * Register these types of mistakes and also errors (try-catch) in some kind of variable.
    * Using TRANSACTIONS would be helpful. I think.

crea_staff (INSERT)

    * Parameters must be positive.
    * Validate dates. It is said that the attribute Start Date MUST take the current date.
    * Foreign Keys. We must handle situations where the User tries to violate referential integrity.
    * Adjust the Salary to the limit that is given to us. In this case min(salary) < NEW.Salary < max(Salary).
    * Check for duplicates.

read_staff (SELECT)

    * Parameters must be positive.
    * Cases where the IN parameter does not exist in the table.
    * Maybe restrict with what kind of values the User can do a search? Like he/she can look for Employee Code or
    Salary, but he/she cannot filter by Job?

update_staff (UPDATE)

    * Parameters must be positive.
    * Validate dates. Just like in crea_staff.
    * Referential Integrity.
    * Check if the IN parameter actually exists in the table.
    * Adjust the Salary.
    * Concurrency! Try to handle this shit with TRANSACTIONS.

delete_staff (DELETE)

    * Verify that the IN parameter actually exists.
    * Verification that we are not violating the Referential Integrity when trying to delete something. Although in the
DDL FK's have ON DELETE/UPDATE NO ACTION already. Hmm...

In all cases, we must have a LOG that will say if the operation was successful or if it wasn't and WHY. Consider using
personalized ERROR CODES.

Reactive/Pro - Active (kind of made-up names) Programming. Reactive programming is all about not permitting any kind of
errors. We prevent them. On the other hand, Pro - Active programming is done when we let the errors happen
but we catch them and then react to them. This can be done, for example, using HANDLERS, TRIGGERS or EVENTS.

If I were to use HANDLERS, some ERROR CODES to take into account would be:

    * 1005. Can't create table.
    * 1048. NOT NULL values not given.
    * 1054. Unknown column.
    * 1062. Duplicates.
    * 1064. Syntax errors. Maybe not needed?
    * 1142. Grants (permissions).
    * 1146. Table does not exist.
    * 1215. FK's.
    * 1216. FK's.
    * 1264. Out of range error. Not sure how exactly this works. So would be easier controlling the range of values
for Salary with Reactive programming I think. What about 1690?
    * 1265. Data truncated. If we try to add values that are too big.
    * 1364. This happens if we try to INSERT in a table with a default value and we don't specify it. Maybe
useful for JDBC?
    * 1366. Incorrect integer value. For example if we try to add a VARCHAR to INT attribute.
    * 1451. FK's.
    * 1452. Cannot add/update child row. Happens when we try to add/update a row that depends on a parent row and this
parent row does not exist. Basically inside the FK's sack.
    * 2002. Connection to MySQL. Very useful when trying to call procedures from JDBC, for example.

Sources:
https://dev.mysql.com/doc/mysql-errors/8.0/en/server-error-reference.html

*/


USE `Staff_Example`;
SELECT * FROM department;
SELECT * FROM staff;

DELIMITER $$
DROP PROCEDURE IF EXISTS salarios_empleados $$
CREATE PROCEDURE salarios_empleados(OUT output VARCHAR(666))
BEGIN

    DECLARE min_salary DECIMAL(7,2);
    DECLARE max_salary DECIMAL(7,2);
    DECLARE avg_salary DECIMAL(7,2);

    DECLARE cuantos_min SMALLINT;
    DECLARE cuantos_max SMALLINT;
    DECLARE cuantos_avg SMALLINT;

     START TRANSACTION;

         SELECT min(Salary) INTO min_salary
         FROM staff;
         SELECT max(Salary) INTO max_salary
         FROM staff;
         SELECT avg(Salary) INTO avg_salary
         FROM staff;

         SELECT count(*) INTO cuantos_min
         FROM staff
         WHERE Salary = min_salary ;
         SELECT count(*) INTO cuantos_max
         FROM staff
         WHERE Salary = max_salary ;
         SELECT count(*) INTO cuantos_avg
         FROM staff
         WHERE Salary = avg_salary ;

         SET output = concat('Salarios Mínimos: ', cuantos_min, '. Valor: ', min_salary, ' | Salarios Máximos: ',
                        cuantos_max, '. Valor: ', max_salary, ' | Salarios Medios: ', cuantos_avg, '. Valor: ', avg_salary);

     COMMIT;

END $$
DELIMITER ;

CALL salarios_empleados(@resultado);
SELECT @resultado;

-- ----------------------------------------------------------------
-- CRUD
-- ----------------------------------------------------------------


-- create_staff (INSERT)


DESC department;
DESC staff;

DELIMITER $$
DROP PROCEDURE IF EXISTS min_max_salary $$
CREATE PROCEDURE min_max_salary(OUT min_salary DECIMAL(7,2), OUT max_salary DECIMAL(7,2))
BEGIN

    START TRANSACTION;

        SELECT min(Salary) INTO min_salary
        FROM staff;
        SELECT max(Salary) INTO max_salary
        FROM staff;

    COMMIT ;

END $$
DELIMITER ;

CALL min_max_salary(@min, @max);
SELECT @min, @max;

DELIMITER $$
DROP PROCEDURE IF EXISTS crea_staff $$
CREATE PROCEDURE crea_staff(IN emp_code SMALLINT UNSIGNED,
                            IN emp_name VARCHAR(25),
                            IN emp_job VARCHAR(25),
                            IN emp_salary DECIMAL(7,2),
                            IN dp_code SMALLINT UNSIGNED,
                            IN emp_start_date DATE,
                            IN sup_officer SMALLINT UNSIGNED,
                            OUT output VARCHAR(300))
                            -- Gotta be careful with the names of IN parameters. If they math exactly those
                            -- of the INSERT, then we are going to have problems :D

COMMENT
'
Part of a CRUD. INSERT procedure that procures that the parameters given are proper ones
'

proc_label: BEGIN

    DECLARE max_salary INT;
    DECLARE min_salary INT;

    -- First of all, HANDLERS for some common ERROR CODES


    DECLARE EXIT HANDLER FOR 1048 -- Prevents violations of NOT NULL attributes
        BEGIN
            SET output = 'Error (1048): Mandatory data was not given';
        END;

    DECLARE EXIT HANDLER FOR 1054
        BEGIN
            SET output = 'Error (1054): Column/Attribute does not exist';
        END;

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET output = 'Error (1062): Duplicate values';
        END;

    DECLARE EXIT HANDLER FOR 1142
        BEGIN
            SET output = 'Error (1142): You do not have enough privileges to do this';
        END;

    DECLARE EXIT HANDLER FOR SQLSTATE '23000' -- Instead of adding error codes one by one, they have like a 'group' that they belong to
        BEGIN
            SET output = 'Error Group (23000): Referential Integrity was compromised ';
        END;

    DECLARE EXIT HANDLER FOR 1265 -- Values that are too big
        BEGIN
            SET output = 'Error (1265): Values given are too big';
        END;

    IF emp_job NOT IN (
        SELECT Job
        FROM staff
        WHERE Job = emp_job
        )
    THEN
        SET output = 'Error. The Job does not exist'; -- Like this we will make sure a Job Value is properly introduced
        LEAVE proc_label;
    END IF;

    IF emp_start_date IS NULL THEN
        SET emp_start_date = curdate(); -- This solves the premise of "Start Date taking current date"
        SET output = 'Start Date added as of TODAY ';
    END IF;

    CALL min_max_salary(min_salary, max_salary);
    IF emp_salary < min_salary THEN
        SET emp_salary = min_salary;
        SET output = 'The Salary has been adjusted to the minimum possible ';
    ELSEIF emp_salary > max_salary THEN
        SET emp_salary = max_salary;
        SET output = 'The Salary has been adjusted to the maximum possible ';
    END IF;

    IF emp_salary IS NULL THEN
        SET output = 'Salary has not been introduced. Please, update later on ';
    END IF;

    -- If everything is OK until now, THEN we do the INSERT

    START TRANSACTION;

    INSERT INTO staff_example.staff(Employee_Code, Name, Job, Salary, Department_Code, Start_Date, Superior_Officer)
    VALUES (emp_code, emp_name, emp_job, emp_salary, dp_code, emp_start_date, sup_officer);

    IF output IS NOT NULL THEN
        SET output = concat(output,'| Creation of the New Employee Successful');
    ELSE
        SET output = 'Creation of the New Employee Successful';
    END IF;

    COMMIT;

END proc_label $$
DELIMITER ;


SELECT @min, @max;

DESC staff;
CALL crea_staff(0001, 'MartínezTest', 'Programmer',
                5555.55, 08, '2024-05-25', 0413, @test1);
SELECT @test1;

CALL crea_staff(0001, 'MartíneSDzTest', 'Programmer',
                5515.55, 08, '2022-05-25', @test2);
SELECT @test2;

CALL crea_staff(0003, 'JuanitoTest', 'Programmer',
                99999, 08, '2024-05-25', 0413, @test3);
SELECT @test3;

CALL crea_staff(0005, 'ClaudiaTest', 'Programmer',
                2, 08, '2024-05-25', 0413, @test4);
SELECT @test4;

CALL crea_staff(0006, 'fkTests', 'Programmer',
                5555, 08, '1999-5-21', 0413, @test5);
SELECT @test5;

CALL crea_staff(0001, 'Testings', 'Programmer', 5555.55, 8,
                '2023-05-010', 413, @tests);

SELECT @tests;

DELETE FROM
           staff
WHERE Employee_Code = 0001 OR Employee_Code = 0003 OR Employee_Code = 0002 OR Employee_Code = 0004
   OR Employee_Code = 0005 OR Employee_Code = 0006;

SELECT * FROM staff;
SET @test1 = NULL;
SET @test2 = NULL;
SET @test3 = NULL;
SET @test4 = NULL;
SET @test5 = NULL;





SELECT @output;


-- read_staff (SELECT)


DELIMITER $$
DROP PROCEDURE IF EXISTS read_staff_dynamic $$
CREATE PROCEDURE read_staff_dynamic(IN emp_code SMALLINT UNSIGNED,
                            IN emp_name VARCHAR(25),
                            IN emp_job VARCHAR(25),
                            IN emp_start_date DATE,
                            IN sup_officer SMALLINT UNSIGNED,
                            OUT output VARCHAR(300))

COMMENT
'
Part of a CRUD. SELECT procedure that procures that data shown is correct
'

proc_label: BEGIN

    DECLARE EXIT HANDLER FOR 1054
        BEGIN
            SET output = 'Error (1054): Column/Attribute does not exist';
        END;

    DECLARE EXIT HANDLER FOR 1146
        BEGIN
            SET output = 'Error (1146): Table does not exist';
        END;

    DECLARE EXIT HANDLER FOR 1142
        BEGIN
            SET output = 'Error (1142): You do not have enough privileges to do this';
        END;

    SELECT *
    FROM staff
    WHERE
        (emp_code IS NULL OR Employee_Code = emp_code)
        AND (emp_name IS NULL OR Name = emp_name)
        AND (emp_job IS NULL OR Job = emp_job)
        AND (emp_start_date IS NULL OR Start_Date = emp_start_date)
        AND (sup_officer IS NULL OR Superior_Officer = sup_officer);

    -- The Where here is analyzing whether a parameter given is NULL or not. The 'OR' means something like
    -- "if it is NOT NULL, then do a WHERE following the syntax: WHERE Employee_Code = emp_job, and so on

END proc_label $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS read_staff $$
CREATE PROCEDURE read_staff(IN emp_code SMALLINT UNSIGNED, OUT output VARCHAR(300))

COMMENT
'
Part of a CRUD. SELECT procedure that procures that data shown is correct
'

proc_label: BEGIN

    DECLARE EXIT HANDLER FOR 1142
        BEGIN
            SET output = 'Error (1142): You do not have enough privileges to do this';
        END;

    IF emp_code IS NULL THEN
        SET output = 'The provided Employee Code cannot be NULL';
        LEAVE proc_label;
    END IF;

    IF emp_code NOT IN (
        SELECT Employee_Code
        FROM staff
        WHERE Employee_Code = emp_code
        )
    THEN
        SET output = 'The provided Employee Code is not registered';
        LEAVE proc_label;
    END IF;

    START TRANSACTION;

        SELECT *
        FROM staff
        WHERE Employee_Code = emp_code;

    COMMIT;

    SET output = 'Search has been successful';

    -- The Where here is analyzing whether a parameter given is NULL or not. The 'OR' means something like
    -- "if it is NOT NULL, then do a WHERE following the syntax: WHERE Employee_Code = emp_job, and so on

END proc_label $$
DELIMITER ;


-- update_staff (UPDATE)


DELIMITER $$
DROP PROCEDURE IF EXISTS update_staff $$
CREATE PROCEDURE update_staff(IN emp_code SMALLINT UNSIGNED,
                              IN emp_name VARCHAR(25),
                              IN emp_job VARCHAR(25),
                              IN emp_salary DECIMAL(7,2),
                              IN dp_code SMALLINT UNSIGNED,
                              IN emp_start_date DATE,
                              IN sup_officer SMALLINT UNSIGNED,
                              OUT output VARCHAR(300))

COMMENT
'
Part of a CRUD. UPDATE procedure that procures that the parameters given to UPDATE a certain tuple are valid
'

proc_label: BEGIN

    DECLARE max_salary INT;
    DECLARE min_salary INT;

    -- First of all, HANDLERS for some common ERROR CODES

    DECLARE EXIT HANDLER FOR 1048 -- Prevents violations of NOT NULL attributes
        BEGIN
            SET output = 'Error (1048): Mandatory data was not given';
        END;

    DECLARE EXIT HANDLER FOR 1054
        BEGIN
            SET output = 'Error (1054): Column/Attribute does not exist';
        END;

    DECLARE EXIT HANDLER FOR 1062
        BEGIN
            SET output = 'Error (1062): Duplicate values';
        END;

    DECLARE EXIT HANDLER FOR 1142
        BEGIN
            SET output = 'Error (1142): You do not have enough privileges to do this';
        END;

    DECLARE EXIT HANDLER FOR SQLSTATE '23000' -- Instead of adding error codes one by one, they have like a 'group' that they belong to
        BEGIN
            SET output = 'Error Group (23000): Referential Integrity was compromised';
        END;

    DECLARE EXIT HANDLER FOR 1265 -- Values that are too big
        BEGIN
            SET output = 'Error (1265): Values given are too big';
        END;

    IF emp_code NOT IN (
        SELECT Employee_Code
        FROM staff
        WHERE Employee_Code = emp_code
    )
    THEN
        SET output = 'The provided Employee Code is not registered';
        LEAVE proc_label;
    END IF;

    IF emp_job NOT IN (
        SELECT Job
        FROM staff
        WHERE Job = emp_job
    )
    THEN
        SET output = 'Error. The Job does not exist'; -- Like this we will make sure a Job Value is properly introduced
        LEAVE proc_label;
    END IF;

    IF emp_start_date IS NULL THEN
        SET emp_start_date = curdate(); -- This solves the premise of "Start Date taking current date"
        SET output = 'Start Date added as of TODAY ';
    END IF;

    CALL min_max_salary(min_salary, max_salary);
    IF emp_salary < min_salary THEN
        SET emp_salary = min_salary;
        SET output = 'The Salary has been adjusted to the minimum possible ';
    ELSEIF emp_salary > max_salary THEN
        SET emp_salary = max_salary;
        SET output = 'The Salary has been adjusted to the maximum possible ';
    END IF;

    IF emp_salary IS NULL THEN
        SET output = 'Salary has not been introduced. Please, update later on ';
    END IF;

    -- If everything is OK until now, THEN we do the INSERT

    START TRANSACTION;

    UPDATE staff
    SET
        Name = emp_name,
        Job = emp_job,
        Salary = emp_salary,
        Department_Code = dp_code,
        Start_Date = emp_start_date,
        Superior_Officer = sup_officer
    WHERE Employee_Code = emp_code;

    IF output IS NOT NULL THEN
        SET output = concat(output,'| Update of the Employee Successful');
    ELSE
        SET output = 'Update of the Employee Successful';
    END IF;

    COMMIT;

END proc_label $$
DELIMITER ;

SELECT * FROM staff;

CALL update_staff(6, 'NewName', 'Programmer', 6666, 8, NULL, 413, @outs);
CALL crea_staff(2, 'Boss', 'Head', 9700, 12, '2023-04-02', 2, @outs2);
CALL crea_staff(3, 'Boss', 'Head', 9700, 12, '2023-04-02', 3, @outs3);
CALL crea_staff(4, 'Boss', 'Head', 9700, 12, '2023-04-02', 4, @outs4);

CALL update_staff(4, 'TESTS', 'Programmer', 2, 5, NULL, 368, @outs4);

SELECT @outs;
SELECT @outs2;
SELECT @outs2;
SELECT @outs4;


-- delete_staff (DELETE)

DELIMITER $$
DROP PROCEDURE IF EXISTS delete_staff $$
CREATE PROCEDURE delete_staff(IN emp_code SMALLINT UNSIGNED, OUT output VARCHAR(300))

COMMENT
'
Part of a CRUD. DELETE procedure that makes sure Referential Integrity is not compromised and proper values are deleted
'

proc_label: BEGIN


    DECLARE EXIT HANDLER FOR 1142
        BEGIN
            SET output = 'Error (1142): You do not have enough privileges to do this';
        END;

    DECLARE EXIT HANDLER FOR SQLSTATE '23000' -- Instead of adding error codes one by one, they have like a 'group' that they belong to
        BEGIN
            SET output = 'Error Group (23000): Referential Integrity was compromised ';
        END;

    IF emp_code IS NULL THEN
        SET output = 'The provided Employee Code cannot be NULL';
        LEAVE proc_label;
    END IF;

    IF emp_code NOT IN (
        SELECT Employee_Code
        FROM staff
        WHERE Employee_Code = emp_code
    )
    THEN
        SET output = 'The provided Employee Code is not registered';
        LEAVE proc_label;
    END IF;

    START TRANSACTION;

        DELETE
        FROM staff
        WHERE Employee_Code = emp_code;

    COMMIT;

    SET output = concat('Deletion of Employee Code number ', emp_code, ' has been successful');

END proc_label $$
DELIMITER ;

SELECT * FROM staff;
SET FOREIGN_KEY_CHECKS = 1;
CALL delete_staff(3, @deletes);
CALL delete_staff(5, @deletes);
CALL crea_staff(5, 'BossSon', 'Programmer', 8700, 8, '2023-04-02', 4, @outs5);
SELECT @deletes;
SELECT @outs5;