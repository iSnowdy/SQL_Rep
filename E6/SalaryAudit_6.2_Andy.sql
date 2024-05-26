/*

DISCLAIMER: The creation of the Schema `Staff_Example` is in another .sql file; called Staff_Script and it is attached.

a) Modify the Schema T5_Employees so that it audits the changes in salaries through TRIGGERS and the table called
Salary_Audit will be in charge of recording all those changes.

b) Modify the Schema so it is capable of managing the history of salaries of the employee in a new table with a
TRIGGER. This table that will record the changes to that specific employee's salary will be called Salary_History.

Ok so first of all we must create both tables that are required to accomplish these requirements: Salary_Audit and
Salary_History.

TRIGGERS are objects of a Data Base that are associated with a table and are automatically activated when the
thing that triggers them (which is defined inside the TRIGGER itself) happens. Usually these operations are INSERTs,
UPDATEs or DELETEs.

Basically TRIGGERS make it possible to fire a response to a certain event.

We have 2 kind of TRIGGERS. BEFORE and AFTER TRIGGERS, depending when they are fired.

It is not possible to define TRIGGERS off of a single attribute in MySQL. Meaning that we can't build it only on
changes made on Salary, but the whole table.

Another thing to take into account here is the fact that we are building 2 TRIGGERS that are attached to the same
table and have kind of a similar purpose.

In MySQL to solve this concurrency of TRIGGERS we have the FOLLOWS (after X) and PRECEDES (before X) clauses.

Sources: https://dev.mysql.com/doc/refman/8.0/en/trigger-syntax.html

*/


USE `Staff_Example`;
DESC staff;
DESC department;

SELECT * FROM staff;
SELECT * FROM department;

DROP TABLE IF EXISTS `Salary_Audit`;
CREATE TABLE IF NOT EXISTS `Salary_Audit` (
    `Audit_User` VARCHAR(50) NOT NULL,
    `Audit_Time` DATETIME NOT NULL,
    `Employee_Code` SMALLINT UNSIGNED NOT NULL,
    `Old_Employee_Name` VARCHAR(25) NOT NULL,
    `Old_Job` VARCHAR(25) NOT NULL,
    `Old_Salary` DECIMAL(7,2),
    `Old_Department_Code` SMALLINT UNSIGNED,
    `Old_Start_Date` DATE NOT NULL,
    `Old_Employee_Superior` SMALLINT UNSIGNED NOT NULL,
    `New_Employee_Name` VARCHAR(25) NOT NULL,
    `New_Job` VARCHAR(25) NOT NULL,
    `New_Salary` DECIMAL(7,2),
    `New_Department_Code` SMALLINT UNSIGNED,
    `New_Start_Date` DATE NOT NULL,
    `New_Employee_Superior_Officer` SMALLINT UNSIGNED NOT NULL)
Engine = InnoDB;

DROP TABLE IF EXISTS `Salary_History`;
CREATE TABLE IF NOT EXISTS `Salary_History` (
    `Employee_Code` SMALLINT UNSIGNED NOT NULL,
    `Date_New_Salary` DATE NOT NULL,
    `Salary` DECIMAL(7,2) NOT NULL,
    CONSTRAINT PK_EmployeeCode_DateNewSalary PRIMARY KEY (`Employee_Code`, `Date_New_Salary`))
Engine = InnoDB;

DESC Salary_Audit;
DESC Salary_History;

/*

a) So, if we want to audit the changes to salaries with a TRIGGER, we have to build a TRIGGER that is fired AFTER an
UPDATE on the Salary attribute of the current Schema we are working with. Salary changes are made on the table called
`Staff`. So let's start working with that.

Luckily we are already given what kind of information is of interest. So we know exactly what information to extract
with the TRIGGER thanks to the DDL of Salary_Audit.

Also Salary_Audit is obviously not a normalized table. This is done on purpose so as to maintain simplicity and practicability.

*/


-- Salary Audit Trigger


DELIMITER $$
DROP TRIGGER IF EXISTS Salary_Audit_Trigger $$
CREATE TRIGGER Salary_Audit_Trigger
AFTER UPDATE
ON staff FOR EACH ROW
BEGIN

    DECLARE audit_user VARCHAR(50);
    DECLARE audit_time DATETIME;

    IF (NEW.Salary != OLD.Salary) THEN
        SET audit_user = current_user;
        SET audit_time = now();

        INSERT INTO Salary_Audit VALUES
        (audit_user, audit_time,
         OLD.Employee_Code, OLD.Name, OLD.Job, OLD.Salary, OLD.Department_Code, OLD.Start_Date, OLD.Superior_Officer,
         NEW.Name, NEW.Job, NEW.Salary, NEW.Department_Code, NEW.Start_Date, NEW.Superior_Officer);
    END IF;

END $$
DELIMITER ;


/*

b) Ok so now we have to somehow manage INSERTs, UPDATEs and DELETEs made on the Staff table with a TRIGGER and
put all that data in a new table called Salary_History.

- INSERT. We must create the first tuple of the history.
- UPDATE. Upon an UPDATE on the employee's salary, we create a new tuple with this information.
- DELETE. If the employee is DELETED, then it is also deleted on the Salary_History table.

Question is. In what order should the TRIGGERS be fired?

In my opinion the Salary_Audit TRIGGER should be fired first since it has the same information that Salary_History has
and then *some* more. So I'd say it is more important to first get this information and then the TRIGGER for Salary_History.

At first glance even if we let MySQL decide the order in which these 2 TRIGGERS are fired it should not cause any kind of
issues with Data Integrity. However, you never know if it is really save. So better safe than sorry :D

*/

DESC Salary_History;

START TRANSACTION; -- Explanation on why we are doing this is later down the track (Update Trigger)

    ALTER TABLE Salary_History
    MODIFY COLUMN Date_New_Salary DATETIME;

COMMIT;


-- INSERT TRIGGER


DELIMITER $$
DROP TRIGGER IF EXISTS Salary_History_Insert $$
CREATE TRIGGER Salary_History_Insert
AFTER INSERT
ON staff FOR EACH ROW
BEGIN

    INSERT INTO Salary_History VALUES(NEW.Employee_Code, now(), NEW.Salary);

END $$
DELIMITER ;


-- UPDATE TRIGGER


DELIMITER $$
DROP TRIGGER IF EXISTS Salary_History_Update $$
CREATE TRIGGER Salary_History_Update
AFTER UPDATE
ON staff FOR EACH ROW
FOLLOWS Salary_Audit_Trigger -- Like this we will make sure it is fired AFTER the Audit TRIGGER is fired
BEGIN

    IF (NEW.Salary != OLD.Salary) THEN
        INSERT INTO Salary_History VALUES(NEW.Employee_Code, now(), NEW.Salary);
    END IF;

END $$

/*

Ok so something very important here. In the original DDL the attribute Date_New_Salary was defined as a DATE type.
However, considering that we have a PK composed of both Employee_Code and Date_New_Salary, if we do not define
the attribute Date_New_Salary as a DATETIME (therefore using now()) instead of DATE, it would not be possible to add
new tuples with UPDATES, for example. Since the Employee_Code won't change, something has. And that is the date.

It is the only way we have so that we have a proper history of the salaries, instead of just deleting old tuples.

Also another thing. The ALTER TABLE is the first thing we do because if we have data inside the table already,
it won't let us change the attribute because Referential Integrity. And even if we were to drop the PK first and then
changing the data type of the attribute, we wouldn't be able to put it back up again unless we delete everything
from the table.

*/


-- DELETE TRIGGER


/*

Ok so since we are doing a history for DELETEs, the TRIGGER must be BEFORE the actual deletion of the information.
Otherwise we would lose the information. An AFTER DELETE TRIGGER would maybe be useful if we only wanted to know
that a DELETE has happened, but that is not the case here. We are also interested in the information that was there
before the deletion, such as the Salary.

Also I think a BEFORE TRIGGER would be useful as a "if something goes wrong" mechanism. So if the DELETE query goes
wrong, the BEFORE TRIGGER can help us to recover the information that was there or maybe event prevent the DELETE
from actual happening? Not sure about this last thing.

*/

DELIMITER $$
DROP TRIGGER IF EXISTS Salary_History_Delete $$
CREATE TRIGGER Salary_History_Delete
BEFORE DELETE
ON staff FOR EACH ROW
BEGIN

    DELETE
    FROM Salary_History
    WHERE Salary_History.Employee_Code = OLD.Employee_Code;

END $$
DELIMITER ;

SHOW TRIGGERS ;