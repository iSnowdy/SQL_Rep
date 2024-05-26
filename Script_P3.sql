-- CURSORES --

USE staff_example;

DELIMITER $$
DROP PROCEDURE IF EXISTS `OUR_DEPARTMENT` $$
CREATE PROCEDURE `OUR_DEPARTMENT`() -- El orden ha de ser: declaraciones, cursor, handler, loop
BEGIN
	DECLARE Dpt_Code SMALLINT UNSIGNED;
    DECLARE Dpt_Name VARCHAR(15);
    
    DECLARE cursor_department CURSOR FOR
		SELECT `Department Code`, `Department_Name` FROM department; -- El cursor es esto. En este caso un SELECT
	
    DECLARE EXIT handler
    FOR NOT FOUND
    BEGIN
		CLOSE cursor_department;
	END;
    
    OPEN cursor_department;
    LOOP -- Es un loop infinito que se ejecutará hasta que de error. Dicho error está tratado por el HANDLER previamente definido
		FETCH cursor_department INTO Dpt_Code, Dpt_Name;
        SELECT concat(Dpt_Code, ' ', Dpt_Name) AS resultado;
	END LOOP;
END $$;
DELIMITER ;

-- Vemos la dIFerencia entre un SELECT con CURSOR y otro sin
CALL `OUR_DEPARTMENT`();
SELECT * FROM Department;

DELIMITER $$
DROP PROCEDURE IF EXISTS `Our_Department_Staff` $$
-- En MySQL no se puede devolver información compleja como tablas en procedimientos de almacenado. Sólo estructuras de datos simples de MySQL
CREATE PROCEDURE `Our_Department_Staff` (OUT resultado VARCHAR(1024)) -- Un cursor que vaya a cada departamento, y de cada departamento saque a los empleados de él
BEGIN
	DECLARE Dpt_Code SMALLINT UNSIGNED;
    DECLARE Dpt_Name VARCHAR(15);
    DECLARE Staff_Code SMALLINT UNSIGNED;
    DECLARE Staff_Name VARCHAR(15);
    DECLARE Cursor_Not_Found BIT DEFAULT 0;
    DECLARE Dpt_Staff VARCHAR(1024) DEFAULT 'Departamentos y Staff :';
    
    DECLARE Cursor_Department CURSOR FOR
		SELECT d.`Department Code`, d.Department_Name
        FROM Department d;
	DECLARE Cursor_Staff CURSOR FOR
		SELECT s.`Employee Code`, s.Staff_Name
		FROM Staff s
        WHERE s.`Department Code` = Dpt_Code;
        
	DECLARE CONTINUE HANDLER
    FOR NOT FOUND
    BEGIN
		SET Cursor_Not_Found = 1;
	END;
    
    OPEN Cursor_Department;
    loop_cursor_department: loop
		FETCH Cursor_Department INTO Dpt_Code, Dpt_Name;
        IF (Cursor_Not_Found = 1) THEN
			CLOSE Cursor_Department;
            LEAVE loop_cursor_department;
		ELSE
			SELECT concat_ws('-', Dpt_Staff, Dpt_Code, Dpt_Name) INTO Dpt_Staff;
		END IF;
        
        OPEN Cursor_Staff;
        loop_cursor_staff: loop
			FETCH Cursor_Staff INTO Staff_Code, Staff_Name;
            IF (Cursor_Not_Found = 1) THEN
				SET Cursor_Not_Found = 0;
                CLOSE Cursor_Staff;
                LEAVE loop_cursor_staff;
			ELSE
				SELECT concat_ws('/', Dpt_Staff, Staff_Code, Staff_Name) into Dpt_Staff;
			END IF;
		END LOOP loop_cursor_staff;
        END LOOP loop_cursor_department;
        
	SET resultado = Dpt_Staff; -- No haría falta. Probablemente
END $$
DELIMITER ;
    
CALL `Our_Department_Staff`(@resultado);
SELECT @resultado;




-- JSON + SQL --

SELECT json_object('id', 1, 'name', 'Tomeu', 'surname', 'Sabater', 'birthday', curdate());
SELECT json_object('id', 1, 'name', 'Tomeu', 'surname', 'Sabater', 'birthday', curdate()) INTO @j_resultado;
SELECT @j_resultado;

-- También se podría hacer un SET en vez de un SELECT para meter el JSON en una variable

SET @jrray_resultado = json_array(json_object('id', 2, 'name', 'Andreu', 'surname', 'Nonor'), json_object('id', 3, 'name', 'Tomeu', 'surname', 'Sabater'));
SELECT @jrray_resultado;

SELECT json_extract(@jrray_resultado, '$[0]');
SELECT json_extract(@jrray_resultado, '$[0].id', '$[0].name');

SET @jrray_resultado2 = json_object('Dpt_Code', 1,
									'Dpt_Name', 'Contabilidad',
									'Dpt_Staff', json_array(json_object('id', 2, 'name', 'Andreu', 'surname', 'Nonor'), json_object('id', 3, 'name', 'Tomeu', 'surname', 'Sabater')),
									'Dpt_StaffN', 2);
									
SELECT @jrray_resultado2;

-- Pero el formato no es el de un JSON

SELECT * FROM Department d;
SELECT json_arrayagg(json_object('Code', d.`Department Code`, 'Name', d.Department_name, 'City', d.City)) FROM Department d;
-- objeto JSON de cada una de las tuplas

SELECT json_arrayagg(json_object('Code', d.`Department Code`, 'Name', d.Department_name, 'City', d.City)) FROM Department d INTO @json_var;
SELECT @json_var;
SELECT json_extract(@json_var, '$[0].City'); -- CAP sensitive

SELECT json_arrayagg(json_object('Code', d.`Department Code`, 'Name', d.Department_name, 'City', d.City))
FROM Department d
INNER JOIN Staff s
ON d.`Department Code` = s.`Department Code`
INTO @json_var;
SELECT @json_var;
    
    -- Procedimiento para construir un JSON --
    
DELIMITER $$
DROP PROCEDURE IF EXISTS `Our_JSON_Department_Staff` $$
-- En MySQL no se puede devolver información compleja como tablas en procedimientos de almacenado. Sólo estructuras de datos simples de MySQL
CREATE PROCEDURE `Our_JSON_Department_Staff` (OUT j_resultado json) -- Un cursor que vaya a cada departamento, y de cada departamento saque a los empleados de él
BEGIN
	SELECT json_arrayagg(json_object('Code', d.`Department Code`, 'Name', d.Department_name, 'City', d.City))
    FROM Department d
    INNER JOIN Staff s
    ON d.`Department Code` = s.`Department Code`
    INTO @j_resultado;
END $$
DELIMITER ;

CALL `Our_JSON_Department_Staff`(@j_resultado);
SELECT @j_resultado;


-- TRIGGERS --

/*
Estructura
 
1 CREATE
2 [DEFINER = { user | CURRENT_USER }]
3 TRIGGER [IF NOT EXISTS] trigger_name
4 trigger_time trigger_event
5 ON tbl_name FOR EACH ROW --> se define sobre una tabla (eventos que puede hacer: cuando se declare INSERT, UPDATE, DELETE sobre una tabla)
6 [trigger_order]
7 trigger_body
8
9 trigger_time: { BEFORE | AFTER }
10
11 trigger_event: { INSERT | UPDATE | DELETE }
12
13 trigger_order: { FOLLOWS | PRECEDES } other_trigger_name
 
*/
USE `Staff_Example`;
desc staff;
 
 
DELIMITER $$
DROP TRIGGER IF EXISTS `check_salario` $$
CREATE TRIGGER `check_salario`
BEFORE INSERT 
ON Staff
FOR EACH ROW -- Se ejecuta antes de un insert sobre la tabla Staff
BEGIN
	DECLARE max_salario, avg_salario, min_salario DECIMAL(7,2);
    
  -- Es necesario para cada nueva ejecución del trigger
  -- puesto que los valores pueden cambiar (con un update)
	SELECT max(s.Salary) FROM staff s into max_salario;
    SELECT avg(s.Salary) FROM staff s into avg_salario;
	SELECT min(s.Salary) FROM staff s into min_salario;
  
  -- Lógica del trigger
	IF new.Salary IS NULL THEN
		SET new.Salary = avg_salario;
	elseIF new.Salary > max_salario THEN
		SET new.Salary = max_salario;
	elseIF new.Salary < min_salario THEN
		SET new.Salary = min_salario;
	END IF;
 
END $$
DELIMITER ;

delimiter $$
drop trigger if exists check_salario$$
create trigger check_salario
before insert -- Se ejecuta antes de un insert
on staff for each row -- Se ejecuta sobre la tabla Staff
begin
	-- declaración de variables locales
	declare max_salario, avg_salario, min_salario decimal(7,2);
	
	-- Es necesario para cada nueva ejecución del trigger
	-- puesto que los valores pueden cambiar (con un update)
	SELECT max(Salary) FROM staff  into max_salario;
	SELECT avg(s.Salary) FROM staff s into avg_salario;
	SELECT min(s.Salary) FROM staff s into min_salario;
	
	-- Lógica del trigger
	if new.Salary is NULL then
		SET new.Salary = avg_salario;
	elseif new.Salary > max_salario then
		SET new.Salary = max_salario;
	elseif new.Salary < min_salario then
		SET new.Salary = min_salario;
	end if;
 
end$$
delimiter ;

-- Tabla auditoria --

DROP TABLE IF EXISTS salary_audit;
CREATE TABLE salary_audit (
  audit_user varchar(50) not NULL, -- Usuario que modificó el salario  
  audit_time datetime not NULL, -- Momento de la modificació
  employee_code smallint unsigned not NULL, -- Empleado modificado
  old_employee_name varchar(25) not NULL, -- A partir de aquí valores originales
  old_job varchar(25) not NULL,
  old_salary decimal(7,2),
  old_department_code smallint unsigned,
  old_start_date date not NULL,
  old_employee_superior_Officer smallint unsigned not NULL,
  new_employee_name varchar(25) not NULL, -- A partir de aquí valores nuevos
  new_job varchar(25) not NULL,
  new_salary decimal(7,2),
  new_department_code smallint unsigned,
  new_start_date date not NULL,
  new_employee_superior_Officer smallint unsigned not NULL
);

DESC salary_audit;

DELIMITER $$
DROP TRIGGER IF EXISTS `salary_audit_trigger` $$
CREATE TRIGGER `salary_audit_trigger`
AFTER UPDATE
ON `Staff` 
FOR EACH ROW
BEGIN
	DECLARE audit_user VARCHAR(25);
    DECLARE audit_time DATETIME;
    
    IF (new.salary != old.salary) THEN
		SELECT current_user() INTO audit_user;
        SELECT curdate() INTO audit_time;
        
        INSERT INTO salary_audit
        VALUES
        (audit_user, audit_time, old.Employee_Code); -- Y el resto de cosas me da pereza
	END IF;
END $$
DELIMITER ;


DROP TABLE IF EXISTS `Salary_History`;
CREATE TABLE `Salary_History` (
	`Employee_Code` SMALLINT NOT NULL,
    `Date_New_Salary` DATE NOT NULL,
    `Salary` DECIMAL (7,2) NOT NULL,
    CONSTRAINT PK_SalaryHistory PRIMARY KEY (`Employee_Code`, `Date_New_Salary`),
    CONSTRAINT FK_Employee FOREIGN KEY (`Employee_Code`) REFERENCES `Staff`(`Employee Code`))
ENGINE = InnoDB;

DESC Staff;

-- Se deberán de hacer 2 TRIGGERS para la misma tabla. Uno de un INSERT para la prmera tupla, y ya luego un UPDATE para las actualizaciones

DELIMITER $$
DROP TRIGGER IF EXISTS `Salary_History_Create` $$
CREATE TRIGGER `Salary_History_Create`
AFTER INSERT
ON `Staff`
FOR EACH ROW
BEGIN
	INSERT INTO `Salary_History` VALUES(Employee_Code, now(), new.salary);
END $$
DELIMITER ;

SELECT * FROM Staff;
INSERT INTO Staff VALUES(333, 'Juan', 'Analyst', 6000, 5, now(), 368);
SELECT * FROM Salary_History;

DELIMITER $$
DROP TRIGGER IF EXISTS `Salary_History_Update` $$
CREATE TRIGGER `Salary_History_Update`	
AFTER UPDATE
ON `Staff`
FOR EACH ROW
BEGIN
	DECLARE employee_code VARCHAR(25);
    DECLARE audit_time DATETIME;
    DECLARE new_salary DECIMAL(7,2);
    
    IF (new.salary != old.salary) THEN
        INSERT INTO `Salary_History`
        VALUES
        (new.employee_code, now(), new.salary); -- Y el resto de cosas me da pereza
	END IF;
END $$
DELIMITER ;		

UPDATE `Staff` SET Salary = 6500 WHERE Staff.`Employee Code` = 222;

DELIMITER $$
DROP TRIGGER IF EXISTS `Salary_History_Delete` $$
CREATE TRIGGER `Salary_History_Delete`
BEFORE DELETE
ON `Staff`
FOR EACH ROW
BEGIN
	DELETE FROM 
    WHERE `Salary_History`.`Employee_Code` = old.

END $$
DELIMITER ;

-- EVENTS --
USE `Staff_Example`;

show events;

DROP TABLE IF EXISTS `test_event`;
CREATE TABLE `test_event` (
	`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Fecha` DATETIME
);

DROP EVENT `insert_event`;
CREATE EVENT `insert_event`
ON SCHEDULE AT current_time() + interval 1 minute
DO
	INSERT INTO `test_event`(`Fecha`) VALUES(now()); -- Como no es un evento periódico, se borrará al completarse

DROP EVENT `insert_event_minute`;
CREATE EVENT `insert_event_minute`
ON SCHEDULE EVERY 2 MINUTE STARTS now()
DO
	INSERT INTO `test_event`(`Fecha`) VALUES(now()); 
    -- Se recomienda que en el cuerpo del evento se introduzan procedimientos de almacenado, no código como tal

SHOW events;
    
SELECT * FROM performance_schema.processlist WHERE db = `Staff_Example`;
SELECT * FROM `test_event`;

ALTER EVENT `insert_event_minute` DISABLE; -- Desactiva
ALTER EVENT `insert_event_minute` ENABLE; -- Lo activa

DROP TABLE IF EXISTS `Staff_Event`;
CREATE TABLE `Staff_Event` (
	`Fecha` DATE NOT NULL, 
    `Employee_Code` SMALLINT UNSIGNED NOT NULL,
    `Name` VARCHAR(25) NOT NULL,
    `Salary` DECIMAL(7,2) NOT NULL
);
-- Solo funciona para casos donde haya sólo una persona con un salario máximo. Si hay
-- más de uno, ya habría que hacer un cursor para que funcionase
DELIMITER $$ 
DROP EVENT `max_salary_every_minute` $$
CREATE EVENT `max_salary_every_minute`
ON SCHEDULE EVERY 1 MINUTE STARTS now()
DO
	BEGIN
		DECLARE max_salary DECIMAL(7,2);
        DECLARE cuantos SMALLINT;
        DECLARE e_code SMALLINT;
        DECLARE e_name VARCHAR(25);
        DECLARE e_salary DECIMAL(7,2);
        
        SELECT max(salary) FROM Staff INTO max_salary;
        SELECT count(*) INTO cuantos FROM Staff WHERE salary = max_salary;
        
        IF (cuantos = 1) THEN
			SELECT s.`Employee Cod`, s.`Staff_Name`, s.`Salary`
            INTO e_code, e_name, e_salary
            FROM Staff s WHERE s.Salary = max_salary;
            
			INSERT INTO `Staff_Event` VALUES(now(), e_code, e_name, e_salary);
		END IF;
END $$
DELIMITER ;

SELECT * FROM `Staff`;
SELECT max(s.Salary) FROM Staff s;
SELECT * FROM `Staff_Event`;

-- Creación de un procedimiento para llamarlo con Java. Sobre Staff --

USE staff_example;

DELIMITER $$
DROP PROCEDURE IF EXISTS read_staff_java$$
CREATE PROCEDURE read_staff_java
(INOUT employee_code SMALLINT,
OUT employee_name VARCHAR(25), OUT employee_job VARCHAR(25), OUT employee_salary DECIMAL(7,2),
OUT department_code SMALLINT, OUT start_date DATE, OUT superior_officer SMALLINT,
OUT status SMALLINT UNSIGNED, OUT error_message VARCHAR(255))

COMMENT 
'
Obtiene un Staff específico de staff_example.staff
Status = 0 --> error_message = "Info: Staff econtrado, se devuelve su info"
Status = 1 --> error_message = "Error: Staff no econtrado"
Status = 2 --> error_message = "Error: Falta algún dato obligatorio, no se apora employee_code"
'

proc_label: BEGIN
	IF employee_code IS NULL THEN
		SET status = 2;
        SET error_message = 'Error: Falta algún dato obligatorio, no se aporta employee_code';
        LEAVE proc_label;
	END IF;
	
    IF NOT EXISTS (SELECT 1 = 1 FROM staff_example.staff s
		WHERE s.`Employee Code` = employee_code) THEN
        SET status = 1;
        SET error_message = 'Error: Staff no econtrado';
        LEAVE proc_label;
	END IF;
    
    SELECT * INTO employee_code, employee_name, employee_job, employee_salary, department_code, start_date, superior_officer
    FROM staff s
    WHERE s.`Employee Code` = employee_code;
    
    SET status = 1;
    SET error_message = 'Info: Staff econtrado, se devuelve su info';
    
END proc_label $$
DELIMITER ;

SET @code = 333;
SET @name = NULL;  
SET @job = NULL;  ;
SET @salary = NULL;   
SET @depto = NULL;  
SET @sdate = NULL;
SET @superior = NULL;
 
CALL read_staff_java(@code, @name, @job, @salary, @depto, @sdate, @superior, @status, @info_error_message);
SELECT @code, @name, @job, @salary, @depto, @sdate, @superior, @status, @info_error_message;
SELECT * FROM staff; 
