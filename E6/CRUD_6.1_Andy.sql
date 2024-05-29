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
    Salary, but he/she cannot filter by Job? <-- Too complex for MySQL programming. Leave it to an upper layer (Java)

update_staff (UPDATE)

    * Parameters must be positive.
    * Validate dates. Just like in crea_staff.
    * Referential Integrity.
    * Check if the IN parameter actually exists in the table.
    * Adjust the Salary.
    * Concurrency! Try to handle this shit with TRANSACTIONS.
    * Also add a way to get a message to show what changes were actually made (TRIGGER?)

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
DROP PROCEDURE IF EXISTS Salarios_Empleados $$
CREATE PROCEDURE Salarios_Empleados(OUT output VARCHAR(666))
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

CALL Salarios_Empleados(@resultado);
SELECT @resultado;


-- ----------------------------------------------------------------
-- CRUD
-- ----------------------------------------------------------------


-- create_staff (INSERT)


DESC department;
DESC staff;

DELIMITER $$
DROP PROCEDURE IF EXISTS Min_Max_Salary $$
CREATE PROCEDURE Min_Max_Salary(OUT min_salary DECIMAL(7,2), OUT max_salary DECIMAL(7,2))
BEGIN

    START TRANSACTION;

        SELECT min(Salary) INTO min_salary
        FROM staff;
        SELECT max(Salary) INTO max_salary
        FROM staff;

    COMMIT ;

END $$
DELIMITER ;

CALL Min_Max_Salary(@min, @max);
SELECT @min, @max;

DELIMITER $$
DROP PROCEDURE IF EXISTS Crea_Staff $$
CREATE PROCEDURE Crea_Staff(IN emp_code SMALLINT UNSIGNED,
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

    CALL Min_Max_Salary(min_salary, max_salary);
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

/*CALL Crea_Staff(0001, 'MartínezTest', 'Programmer',
                5555.55, 08, '2024-05-25', 0413, @test1);
SELECT @test1;
SELECT * FROM staff;*/


-- read_staff (SELECT)


DELIMITER $$
DROP PROCEDURE IF EXISTS Read_Staff $$
CREATE PROCEDURE Read_Staff(INOUT emp_code SMALLINT UNSIGNED,
                            OUT emp_name VARCHAR(25),
                            OUT emp_job VARCHAR(25),
                            OUT emp_salary DECIMAL(7,2),
                            OUT dp_code SMALLINT UNSIGNED,
                            OUT emp_start_date DATE,
                            OUT sup_officer SMALLINT UNSIGNED,
                            OUT output VARCHAR(300))

COMMENT
'
Part of a CRUD. SELECT procedure that procures that data shown is correct and stores it
in multiple variables
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

        SELECT * INTO emp_code, emp_name, emp_job, emp_salary, dp_code, emp_start_date, sup_officer
        FROM staff
        WHERE Employee_Code = emp_code;

    COMMIT;

    SET output = 'Search has been successful';

END proc_label $$
DELIMITER ;

/*SET @code = 69;
CALL Read_Staff(@code, @emp_name, @emp_job, @emp_salary, @dp_code, @emp_start_date, @sup_officer, @output);
SELECT @code, @emp_name, @emp_job, @emp_salary, @dp_code, @emp_start_date, @sup_officer, @output;*/

-- update_staff (UPDATE)

-- https://stackoverflow.com/questions/6296313/mysql-trigger-after-update-only-if-row-has-changed
/*

Ook lets do some shenanigans here :) I don't want that the UPDATE procedure for the CRUD
only modifies the table. I also want a way to register what has been changed, store those
changes somewhere and then call from within the UPDATE procedure those changes and show it
to the user by storing it in a variable.

For this I think the best way would be to do something similar to what the Task 6.2 asks us.
An audit table with a TRIGGER attached to it. This way the TRIGGER will fire if there are
any changes ON UPDATE of the Staff table. Then it proceeds to store those changes in a new table
created.

However I think creating a whole new table is kind of an overkill for this. Soo instead I will
just store the changes into a variable. Then call this variable from within the UPDATE procedure
itself. That might work.

*/

DELIMITER $$
DROP TRIGGER IF EXISTS staff_update_trigger $$
CREATE TRIGGER Staff_Update_Trigger
AFTER UPDATE
ON staff FOR EACH ROW
BEGIN

    DECLARE changesString VARCHAR(666);
    SET changesString = '';
    -- This caused me a few problems :D Unlike Java, if you don't start the SET it is empty when concatenated

    -- Update Checkers
    IF NEW.Employee_Code != OLD.Employee_Code THEN
        SET changesString = concat(changesString, 'Employee Code changed from ', OLD.Employee_Code, ' to ', NEW.Employee_Code, '; ');
    END IF;
    IF NEW.Name != OLD.Name THEN
        SET changesString = concat(changesString, 'Name changed from ', OLD.Name, ' to ', NEW.Name, '; ');
    END IF;
    IF NEW.Job != OLD.Job THEN
        SET changesString = concat(changesString, 'Job changed from ', OLD.Job, ' to ', NEW.Job, '; ');
    END IF;
    IF NEW.Salary != OLD.Salary THEN
        SET changesString = concat(changesString, 'Salary changed from ', OLD.Salary, ' to ', NEW.Salary, '; ');
    END IF;
    IF NEW.Department_Code != OLD.Department_Code THEN
        SET changesString = concat(changesString, 'Department Code changed from ', OLD.Department_Code, ' to ', NEW.Department_Code, '; ');
    END IF;
    IF NEW.Start_Date != OLD.Start_Date THEN
        SET changesString = concat(changesString, 'Start Date changed from ', OLD.Start_Date, ' to ', NEW.Start_Date, '; ');
    END IF;
    IF NEW.Superior_Officer != OLD.Superior_Officer THEN
        SET changesString = concat(changesString, 'Superior Officer changed from ', OLD.Superior_Officer, ' to ', NEW.Superior_Officer, '; ');
    END IF;

    SET @changes = changesString;

END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS Update_Staff $$
CREATE PROCEDURE Update_Staff(IN emp_code SMALLINT UNSIGNED,
                              IN emp_name VARCHAR(25),
                              IN emp_job VARCHAR(25),
                              IN emp_salary DECIMAL(7,2),
                              IN dp_code SMALLINT UNSIGNED,
                              IN emp_start_date DATE,
                              IN sup_officer SMALLINT UNSIGNED,
                              OUT output VARCHAR(300),
                              OUT changes VARCHAR(666))

COMMENT
'
Part of a CRUD. UPDATE procedure that procures that the parameters given to UPDATE a certain tuple are valid.
It also gives 2 OUT messages. One to inform of possible errors or if the UPDATE was successful and then the second one
shows the user what was exactly changed thanks to a TRIGGER attached to Staff that SETs a global variable and then
is called from this procedure
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

    CALL Min_Max_Salary(min_salary, max_salary);
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

    -- If everything is OK until now, THEN we do the UPDATE

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
    
    SET changes = @changes;

    COMMIT;

END proc_label $$
DELIMITER ;

/*SELECT * FROM staff;

SELECT @changes;

CALL Update_Staff(1, 'Ferreiro', 'Analyst', 6666,
                  8, NULL, 413, @outs, @results);
CALL Crea_Staff(1, 'Tests', 'Head', 9100,
                12, '2023-04-02', 368, @outs2);

SELECT @outs2;
SELECT @outs;
SELECT @results;*/


-- delete_staff (DELETE)


DELIMITER $$
DROP PROCEDURE IF EXISTS Delete_Staff $$
CREATE PROCEDURE Delete_Staff(IN emp_code SMALLINT UNSIGNED, OUT output VARCHAR(300), OUT record VARCHAR(666))

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

        SET @emp_code = emp_code;
        CALL Read_Staff(@emp_code, @emp_name, @emp_job, @emp_salary,
                        @dp_code, @emp_start_date, @sup_officer, @output);

        SET record = '';
        -- \n when MySQL please
        SET record = concat('Deleted Employee Information ---> ',
                            'Employee Code: ', @emp_code, ', ',
                            'Name: ', @emp_name, ', ',
                            'Job: ', @emp_job, ', ',
                            'Salary: ', @emp_salary, ', ',
                            'Department_Code: ', @dp_code, ', ',
                            'Start_Date: ', @emp_start_date, ', ',
                            'Superior_Officer: ', @sup_officer);

        DELETE
        FROM staff
        WHERE Employee_Code = emp_code;

    COMMIT;

    SET output = concat('Deletion of Employee Code number ', emp_code, ' has been successful');

END proc_label $$
DELIMITER ;

/*SELECT * FROM staff;
CALL Crea_Staff(1, 'Tests', 'Head', 9100,
                12, '2023-04-02', 368, @outs2);
SET FOREIGN_KEY_CHECKS = 1;
CALL Delete_Staff(1, @deletes, @record);

SELECT @deletes;
SELECT @record;*/