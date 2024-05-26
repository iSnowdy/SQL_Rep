
-- ------------------------------------------------------
-- CESUR - Bases de Datos 2023/24
-- TEMA-6 Construcción de Guiones 
-- -------------------------------------------------------
-- C:\...\Work\CESUR\0484 Bases de Datos\#BBDD-UNED\Tema06 Construcción de Guiones\Ejemplos\Guiones.sql
-- ---------------------------------------------------------

-- PROCEDIMIENTOS 

/*
1 CREATE
2 [DEFINER = user]
3 PROCEDURE sp_name ([proc_parameter[,...]])
4 [characteristic ...] routine_body
5
6 CREATE
7 [DEFINER = user]
8 FUNCTION sp_name ([func_parameter[,...]])
9 RETURNS type
10 [characteristic ...] routine_body
11
12 proc_parameter:
13 [ IN | OUT | INOUT ] param_name type
14
15 func_parameter:
16 param_name type
17
18 type:
19 Any valid MySQL data type
20
21 characteristic: {
22 COMMENT 'string'
23 | LANGUAGE SQL
24 | [NOT] DETERMINISTIC
25 | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
26 | SQL SECURITY { DEFINER | INVOKER }
27 }
28
29 routine_body:
30 Valid SQL routine statement
*/

/*
-- Parámetros de entrada, salida y entrada/salida

tres tipos de parámetros:
• Entrada: IN delante del nombre del parámetro.
	no pueden cambiar su valor dentro del procedimiento
	En programación sería equivalente al paso por valor de un parámetro.
• Salida: OUT delante del nombre del parametro. 
	cambian su valor dentro del procedimiento. 
	En programación sería equivalente al paso por referencia de un parámetro.
• Entrada/Salida: combinación de los tipos IN y OUT. 
	se indican poniendo la palabra reservada IN/OUT delante del nombre del parámetro.

*/ 

delimiter ; 
use employees; -- Las funciones y procedimientos se crearán dentro de esta DDBB


-- Ejemplo de Procedimiento Almacenado 

 -- Es necesario para poder incluir el símbolo ";" en la creación del procedimiento

delimiter //
drop procedure if exists listar_todos_empleados //
create procedure listar_todos_empleados ()
begin 
	start transaction; 
		select e.* 
		from employees e; 
	commit; 
end //
delimiter ; 

-- -- Para hacer la llamada a un procedimiento almacenado se utiliza la palabra reservada CALL.
call listar_todos_empleados(); 



-- Ejemplo de procedimiento con IN parámetros de entrada

select * from EMPLOYEES.employees e ; 
desc employees; 

delimiter //
drop procedure if exists listar_empleados //
create procedure listar_empleados(IN nombre varchar(14))
begin 
	start transaction; 
		select * 
		from employees e
		where e.first_name like nombre
		order by e.last_name; 
	commit; 
end //
delimiter ; 

-- Para hacer la llamada a un procedimiento almacenado se utiliza la palabra reservada CALL.
-- No olvidar el/los parámetro/s de entrada
call listar_empleados('Georgi'); 


-- Hacemos otro ejemplo con IN parámetro de entrada

delimiter //
drop procedure if exists contar_empleados //
create procedure contar_empleados(IN nombre varchar(14))
begin 
	start transaction; 
		select count(*) 
		from employees e
		where e.first_name like nombre;
	commit; 
end //
delimiter ; 

call contar_empleados('Chirstian'); 


-- Ejemplo con IN OUT parámetro de entrada y salida
select * from salaries s ; 
desc salaries;  -- vemos que salary es un int. 

delimiter $$
drop procedure if exists contar_nombre_empleado $$
create procedure contar_nombre_empleado(in nombre varchar(14), out total INT unsigned)
begin
	start transaction;
		select count(*) into total -- Resultado dentro de la variable OUT
		from employees e
		where e.first_name = nombre;
	commit; 
end $$
delimiter ; 

call contar_nombre_empleado ('Chirstian', @total); 
select @total; 

-- Escribir un procedimiento que devuelve
-- Salario máximo, salario mínimo y salario medio

delimiter $$
drop procedure if exists calcula_max_min_media $$
create procedure calcula_max_min_media (out maximo int, out minimo int, out media decimal(8,2))
begin 
	start transaction; 
		select max(salary), min(salary), avg(salary) 
		into maximo, minimo, media
		from employees.salaries s; 
	commit;  
end $$
delimiter ; 

call calcula_max_min_media(@maximo, @minimo, @media); 
select @maximo, @minimo, @media; 


-- FUNCIONES
-- Una función puede tener cero o muchos parámetros de entrada y siempre devuelve un único valor,
-- asociado al nombre de la función.

/*
CREATE
	[DEFINER = { user | CURRENT_USER }]
	FUNCTION sp_name ([func_parameter[,...]])
	RETURNS type
	[characteristic ...] routine_body

func_parameter:
	param_name type
	
type:
	Any valid MySQL data type

characteristic:
	COMMENT 'string'
	| LANGUAGE SQL
	| [NOT] DETERMINISTIC
	| { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
	| SQL SECURITY { DEFINER | INVOKER }

routine_body:
	Valid SQL routine statement

*/ 

-- Parámetros de entrada
-- todos los parámetros son de entrada, y no será necesario utilizar IN delante de los parámetros.

-- Hacemos un ejemplo con funciones que ya proporciona el propio MySQL
select version(); 
select current_user(); 

-- Primer ejemplo 

delimiter $$
drop function if exists version_MySQL$$
create function version_MySQL() returns VARCHAR(25)
reads sql data
begin
	declare versionMysql varchar(25); 
	select version() into versionMysql; 
	return versionMysql; 
	-- return(select version()); 
end$$
delimiter ; 

select version_MySQL(); 

-- Segundo ejemplo, ahora con código refactorizado

delimiter $$
drop function if exists user_MySQL$$
create function user_MySQL() returns VARCHAR(25)
reads sql data
begin
	return(select current_user()); 
end$$
delimiter ; 

select user_MySQL(); 

-- Ejemplo de función con parámetros
-- al ser una función son todos IN no hay que especificarlo

delimiter $$
drop function if exists contar_empleados$$
create function contar_empleados (nombre varchar(14)) returns int unsigned
reads sql data
begin
	declare total int unsigned;
	select count(*) into total
	from employees e
	where e.first_name like nombre;
	return total; 
end $$
delimiter ; 

select contar_empleados('Chirstian'); 


-- ------------------------------------------ Estructuras de control

-- IF-THEN-ELSE

/*
IF search_condition THEN statement_list
	[ELSEIF search_condition THEN statement_list] ...
	[ELSE statement_list]
END IF

*/ 

-- CASE 

/*
CASE case_value
	WHEN when_value THEN statement_list
	[WHEN when_value THEN statement_list] ...
	[ELSE statement_list]
END CASE
o
CASE
	WHEN search_condition THEN statement_list
	[WHEN search_condition THEN statement_list] ...
	[ELSE statement_list]
END CASE
*/ 

-- LOOP 

/*
[begin_label:] LOOP
	statement_list
END LOOP [end_label]
*/ 

-- REPEAT
/* 
[begin_label:] REPEAT
	statement_list
UNTIL search_condition
END REPEAT [end_label]
*/ 

-- WHILE
/*
[begin_label:] WHILE search_condition DO
	statement_list
END WHILE [end_label]
*/ 


-- EJEMPLOS DE PROGRAMACIÓN EN SQL 
-- Añadiendo estructura de control a los procedimientos y funciones almacenados
-- podemos añadir "inteligencia" al SQL 

--- Ejemplo
-- Determinar si existen empleados con sueldo igual a 
-- minimo | media |  máximo
-- Si existen, entonces que devuelva cuántos y cuál es minimo | media |  máximo
-- Si no existen, que devuelva 0 y cuál es media | máximo | mínimo 

-- Lo hacemos con minim (basta cambiar min por max o avg para obtener los otros valores)
delimiter $$
drop procedure if exists empleado_salario_medio $$
create procedure empleado_salario_medio(out cuantos int, out valor decimal(8,2))
begin 
	start transaction;
		-- obtenemos el valor
		select min(s.salary) into valor
		from employees.salaries s; 
	
		-- contamos cuántos tienen valor
		select count(*) into cuantos
		from salaries s
		where s.salary = valor; 
	commit; 
end$$
delimiter ; 

call empleado_salario_medio (@cuantos, @valor); 
select @cuantos, @valor; 


-- Pasar un salario a un procedimiento para saber cuántos lo tienen
-- Si no lo tiene ninguno o más de uno
-- 		devolvemos null en el nombre
-- Si lo tiene uno
-- 		devolver su nombre

use employees; 
delimiter $$
drop procedure if exists empleado_salario $$
create procedure empleado_salario(in salario int, out cuantos int, out nombre varchar(14))
begin 
	-- Declaramos variables
	declare empleado_no int; -- número de empleado
	
	start transaction;
		-- comprobamos si alguno tiene el salario
		select count(*) into cuantos
		from salaries s 
		where s.salary = salario; 
	
		if cuantos = 1 then
			-- obtenemos el número de empleado
			select s.emp_no into empleado_no
			from salaries s 
			where s.salary = salario; 
		
			-- obtenemos el nombre del empleado
			select first_name into nombre
			from employees e 
			where emp_no = empleado_no; 
		else
			set nombre = null; 
		end if; 
	commit; 

end$$
delimiter ; 

-- select * from salaries s order by s.salary desc; 

set @salario = 157821; 
call empleado_salario(@salario, @cuantos, @nombre);
select @salario, @cuantos, @nombre; 

-- Podemos utilizar el procedimiento anterior para el obtener salario máximo | min | avg

select max(s.salary) from salaries s into @smaximo; 
call empleado_salario(@smaximo, @cuantos, @nombre);
select @smaximo, @cuantos, @nombre; 

select min(s.salary) from salaries s into @sminimo; 
call empleado_salario(@sminimo, @cuantos, @nombre);
select @sminimo, @cuantos, @nombre; 



-- EJERCICIOS

-- EJERCICIO A
-- Crear un procedimiento almacenado que nos ofrezca la funcionalidad de insertar una tupla
-- debe implementar controles tal que:
-- 		Comprobar que los datos obligatorios han sido aportados
-- 		Comprobar que se respeta la integridad referencial (FKs son correctas)
-- 		Comprobar que la tupla a insertar no existe
-- 		Cualquier otro control que se considere adecuado
--		Si pasa los controles se inserta la tupla y se devuelve un mensaje de información
--		Si no supera algún control (método cascada) no se inserta y se devuelve un mensaje con el error


-- Para hacer el ejercicio utilizaremos la DDBB t5_employees y deseamos insertar la tupla en la tabla Staff
use t5_employees; 
desc staff ; 

/* 
Field           |Type             |Null|Key|Default|Extra|
----------------+-----------------+----+---+-------+-----+
Employee_Code   |smallint unsigned|NO  |PRI|       |     |
Name            |varchar(25)      |NO  |   |       |     |
Job             |varchar(25)      |NO  |   |       |     |
Salary          |decimal(7,2)     |YES |   |       |     |
Department_Code |smallint unsigned|YES |MUL|       |     |
Start_Date      |date             |NO  |   |       |     |
Superior_Officer|smallint unsigned|NO  |MUL|       |     |
*/

-- Lo haremos mediante versiones, o sucesivos refinamientos
-- Inicialmente, solamente comprobaremos si se aportan los datos obligatorios

-- Versión 1

-- select t5_employees.staff; 
-- select current_date();
delimiter $$
drop procedure if exists crea_staff$$
create procedure crea_staff(in employee_code smallint unsigned, 
							in employee_name varchar(25),
							in employee_job varchar(25),
							in salary decimal(7,2),
							in deparment_code smallint unsigned,
							in start_date date,
							in superior_officer smallint unsigned,
							out error_message varchar(255))
							
comment 'Inserta tupla en t5_employees.staff
		Control sobre datos obligatorios
		Control integridad referencial
		Control inserción duplicada
		Permite Start_Date is null con current_date()'

proc_label: begin 
	
	-- Compobación se han aportado los campos que son obligatorios
	-- Solamente Salary y Department_Code pueden ser null
	-- y también permitimos null en start_date, en tal caso, asignamos current_date
	
	if (employee_code is null or employee_name is null
		or employee_job is null or superior_officer is null) then 
		
		set error_message = 'Error: Datos obligatorios no aportados'; 
		leave proc_label;
	end if; 

	if start_date is null then
		set start_date = current_date(); 
		-- select start_date; -- traza para comprobar que genera fecha ok
	end if; 

	set error_message = 'Info: Todo OK'; 

end proc_label $$
delimiter ; 

-- Probamos el código generado 
call crea_staff(222, null, 'Profesor', null, null, null, 222, @ErrorInfo); 
select @ErrorInfo; 


-- Versión 2
-- Al código anterior le añadimos el control de integridad referencial o FKs
-- y la inserción mediante una transacción 

delimiter $$
drop procedure if exists crea_staff$$
create procedure crea_staff(in employee_code smallint unsigned, 
							in employee_name varchar(25),
							in employee_job varchar(25),
							in salary decimal(7,2),
							in deparment_code smallint unsigned,
							in start_date date,
							in superior_officer smallint unsigned,
							out error_message varchar(255))
							
comment 'Inserta tupla en t5_employees.staff
		Control sobre datos obligatorios
		Control integridad referencial
		Control inserción duplicada
		Permite Start_Date is null con current_date()'

proc_label: begin 
	
	-- Compobación se han aportado los campos que son obligatorios
	-- Solamente Salary y Department_Code pueden ser null
	-- y también permitimos null en start_date, en tal caso, asignamos current_date
	
	if (employee_code is null or employee_name is null
		or employee_job is null or superior_officer is null) then 
		
		set error_message = 'Error: Datos obligatorios no aportados'; 
		leave proc_label; -- Abandonamos el proc
	end if; 

	-- Si no se aporta fecha se asume la actual
	if start_date is null then
		set start_date = current_date(); 
	end if; 

	-- Comprobaciones de integridad referencial FK
	-- Comprobación para deparment_code si se ha aportado
	if deparment_code is not null then
	
		if not exists (select 1=1 from t5_employees.department d
		where d.Department_Code = deparment_code) then
			set error_message = 'Error: Departamento no existe';
			leave proc_label; -- Abandonamos el proc
		end if;
	
	end if; 

	-- Comprobación para superior_officer
	if not exists (select 1=1 from t5_employees.staff s 
					where s.Employee_Code = superior_officer) then 
		set error_message = 'Error: Superior Officer no existe'; 
		leave proc_label; -- Abandonamos el proc
	end if; 

	-- Comprobación ya existencia tupla
	
	if exists (select 1=1 from t5_employees.staff s 
				where s.Employee_Code = employee_code) then 
		set error_message = "Error: El empleado ya existe";
		leave proc_label; -- Abandonamos el proc
	end if; 

	-- Todo es OK, procedemos a la inserción mediante una transacción
	start transaction; 
		insert into t5_employees.staff(Employee_Code, Name, Job, Salary, Department_Code, Start_Date, Superior_Officer)
		values(employee_code, employee_name, employee_job, salary, deparment_code, start_date, superior_officer);
	commit; 

	set error_message = 'Info: Creación empleado OK'; 
		
end proc_label $$
delimiter ; 

-- Probamos el código generado 
call crea_staff(222, 'Tomeu', 'Profesor', null, 5, null, 368, @ErrorInfo); 
select @ErrorInfo; 


select * from staff s ; 

-- Comentarios al proc almacenado que acabamos de codificar
-- El código que nos permite sql en un procedimiento almacenado es muy básico, pensar que está pensado para
-- operar a nivel de DDBB, no se espera que implemente reglas de negocio ni el control de una aplicación
-- se enfoca en operaciones de DDBB. 


-- EJERCICIO B 

-- Crea una Base de Datos con una única tabla con la siguiente estructura
--	Dossier_Year year not null, -- Almacena el año de los localizadores
--	Dossier_Locator numeric(7) not null,
--	Hotel_Locator Numeric(6) not null, 
--	Flight_Locator Numeric(6) not null, 
--	Transfer_Locator Numeric(6) not null


-- Esta tabla almacena el siguiente número de reserva:
-- 	Dossier_locator contiene el siguiente número de expediente.
-- 	El expediente está compuesto por reservas de hotel, de vuelo y de transfer
-- 	cada reserva tiene su propio número y los número deben ser consecutivos. 
-- Al número de expediente o de reserva se le añade el año. 
-- Por ejemplo: 
-- Expedientes: 2024/0000001, 2024/0000002, 2024/0000003, etc. 
-- Vuelos | Hotel | Transfer: 2024/000001, 2024/000002, etc.
-- No tenemos que implementar la estructura de expedientes y reservas 
-- solamente la tabla que gestiona el siguiente número de reserva

-- Crear un procedimiento almacenado que nos proporcione:
-- El siguiente número de Expediente y de reserva. 
-- Por ejemplo: 
-- Get_Next_Locator(IN Hotel, IN Vuelo, IN Transfer, OUT Dossier_Locator, OUT Hotel_Locator, OUT Flight_Locator, OUT Tranfer_Locator)

-- Si Hotel = 1 entonces se requiere localizador de hotel (el expediente tiene Hotels)
-- Si Vuelo = 1 entonces se requiere localizador de vuelo (el expediente tiene Vuelos)
-- Si Transfer = 1 entonces se requiere localizador de transfer (el expediente tiene transfers)
-- Siempre se devolverá el Dossier_Locator 

-- Notas: 
-- La inclusión de año debe hacerla el procedimiento almacenado
-- No puede ser que devolvamos un 2024/xxxxxx para el expediente y un 2025/xxxxx para item del expediente
-- Hay que asegurar que sean consecutivos (pista: usar una transacción) 

-- Creamos la DDBB y la tabla

drop database Reservas; 
create database Reservas charset utf8mb4 collate utf8mb4_spanish2_ci;

use Reservas; 

drop table locators; 
create table locators (
	Dossier_Year year not null, -- Almacena el año de los localizadores
	Dossier_Locator decimal(7,0) unsigned not null, -- Localizador para expediente
	Hotel_Locator decimal(6,0) unsigned not null, -- Localizador para hotel
	Flight_Locator decimal(6,0) unsigned not null, -- Localizador para vuelo
	Transfer_Locator decimal(6,0) unsigned not null) -- localizador para transfer
	engine=InnoDB; 

desc locators; 

-- Inicializamos los valores de la tabla 
insert into locators(Dossier_Year, Dossier_Locator, Hotel_Locator, Flight_Locator, Transfer_Locator)
values (2023, 1,1,1,1); 

-- Comprobamos 
select * from locators; 

-- Haremos el procedimiento almacenado 

delimiter $$
drop procedure if exists Get_Next_Locator $$
create procedure Get_Next_Locator(in Hotel bit(1), 
								in Vuelo bit(1), 
								in Transfer bit(1),
								out Dossier_Locator char(12), 
								out Hotel_Locator char(11),
								out Flight_Locator char(11),
								out Transfer_Locator char(11),
								out Info_Error_Message varchar(255))
								
								
comment 'Proporciona el siguiente localizador
		para Hotel, y para Vuelo, y para Transfer según se solicite
		se acompaña siempre de localizador de Expediente'

proc_label: begin 
	
	declare current_year year;
 	declare dossier_number decimal(7,0);
	declare hotel_number, flight_number, transfer_number decimal(6,0);

	-- Comprobamos si se han proporcionado algún valor para los IN
	if (Hotel = null and Vuelo = null and Transfer = null) then 
		set Info_Error_Message = 'No se especifica ningún item para el localizador';
		leave proc_label; 
	end if; 

start transaction; -- Es necesario que el código de este procedimiento sea atómico 

	-- Comprobamos el año, si no es correcto lo ajustamos y reseteamos los localizadores
	-- El reseteo es correcto puesto que se almacena el siguiente localizador, nunca el actual.

	-- Obtenemos el año 
	select l.Dossier_Year from locators l into current_year; 

	-- Comprobamos si es correcto
	if (current_year != year(curdate())) then 

		-- hay que cambiar año y resetear los contadores
		-- reseteamos a los primeros válidos para nuevo año
		update locators l
		set l.Dossier_Year = year(curdate()),
			l.Dossier_Locator = 1,
			l.Hotel_Locator = 1,
			l.Flight_Locator = 1,
			l.Transfer_Locator = 1; 
	end if; 

	-- En una lectura obtenemos los localizadores actuales para operar con ellos 
	select * from locators l 
	into current_year, dossier_number, hotel_number, flight_number, transfer_number;

	-- Generamos el Dossier_Locator
	select concat(current_year, '/', dossier_number) into Dossier_Locator; 
	set dossier_number = dossier_number + 1; 
	set Info_Error_Message = 'Info: Dossier Locator generated';

	-- Generamos el Hotel_Locator
	if (hotel) then
		select concat(current_year, '/', hotel_number) into Hotel_Locator; 
		set hotel_number = hotel_number + 1; 
		select concat(Info_Error_Message, ' ', 'Info: Hotel Locator generated') into Info_Error_Message;
	else
		set Hotel_Locator = null; 
	end if; 

	-- Generamos el Flight_Locator
	if (Vuelo) then 
		select concat(current_year, '/', flight_number) into Flight_Locator; 
		set flight_number = flight_number + 1; 
		select concat(Info_Error_Message, ' ', 'Info: Flight Locator generated') into Info_Error_Message;
	else
		set Flight_Locator = null; 
	end if; 

	-- Generamos el Transfer_Locator
	if (Transfer) then 
		select concat(current_year, '/', transfer_number) into Transfer_Locator; 
		set transfer_number = transfer_number + 1; 
		select concat(Info_Error_Message, ' ', 'Info: Transfer Locator generated') into Info_Error_Message;
	else
		set Transfer_Locator = null; 
	end if; 

	-- Finalmente generamos los siguientes localizadores
	update locators l
	set l.Dossier_Locator = dossier_number,
		l.Hotel_Locator = hotel_number,
		l.Flight_Locator = flight_number,
		l.Transfer_Locator = transfer_number; 

commit; 
	
end proc_label$$
delimiter ; 

call Get_Next_Locator(1,1,1, @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message); 
select @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message; 

call Get_Next_Locator(1,0,0, @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message); 
select @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message; 

call Get_Next_Locator(0,1,0, @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message); 
select @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message; 

call Get_Next_Locator(0,0,1, @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message); 
select @Dossier_Locator, @Hotel_Locator, @Flight_Locator, @Transfer_Locator, @Info_Error_Message; 

select * from locators l;

show procedure status; 

-- -----------------------------------------------------------------GESTION DE EXCEPCIONES EN SQL 
-- Hasta ahora hemos visto una programación proactiva, es decir:
-- 		Aplicamos controles para evitar que se produzca el error. 
-- Pero también podemos aplicar una programación reactiva, es decir:
-- 		No aplicar controles, dejar que se produzca el error, capturarlo y reaccionar
--		En este caso, podemos definir gestores de errores o handlers en los procedimientos almacenados
--		Cada error en MySQL genera un código
--		ejemplo:
insert into locators values (null, 5, 5, 5, 5);
show errors; 
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE;
SELECT  @sqlstate; 

-- 		Ha generado un SQL Error [1048] [23000]: Column 'Dossier_Year' cannot be null
--		El error está codificado, podemos tener la referencia de todos los errores en la doc oficial de MySQL
--		El error, en MySQL contiene 3 códigos;  
--			error code: Propio de MySQL en el ejemplo [1048]
--			SQLSTATE value: Pretende ser una codificación estándard para los errores SQL, por tanto, independiente de la DDBB
--			message string: La descripción del error 

-- Declaración de un handler
/*
DECLARE handler_action HANDLER
    FOR condition_value [, condition_value] ...
    statement

handler_action: {
    CONTINUE
  | EXIT
  | UNDO
}

condition_value: {
    mysql_error_code
  | SQLSTATE [VALUE] sqlstate_value
  | condition_name
  | SQLWARNING
  | NOT FOUND
  | SQLEXCEPTION
}
*/ 

-- La declaración del handler debe estar después de la declaración de las variables. 
-- El 'handler_action' indica qué acción realizar después de la ejecución del handler
--		CONTINUE: La ejecución del procedimiento continua
--		EXIT: La ejecución del procedimiento se aborta (Begin End)
--		UNDO: No admitido (deprecated)
-- El valor 'codindition_value' indica la condición específica o la clase de condiciones que activarán el controlador
-- 		mysql_error_code: string entero que indica un código de error MySQL, ejmplo
--			DECLARE CONTINUE HANDLER
--			FOR 1051
-- 			BEGIN...END
-- 		SQLSTATE [VALUE] sqlstate_value: String de 5 carácteres que indica un código de error "standard", ejemplo
--			DECLARE CONTINUE HANDLER
--			FOR SQLSTATE '42S01'
-- 			BEGIN...END
-- 			Se tendrá en cuenta que los valores SQLSTATE pueden indicar un éxito en una operación, 
-- 			por ejemplo todos aquellos que comienzan por '00' indican éxito en la operación 
--		condition_name: nombre de condición especificado previamente en DECLARE ... CONDITION 
--		SQLWARNING: Abreviatura para la clase de valores SQLSTATE que comienzan con '01', ejemplo
--			DECLARE CONTINUE HANDLER 
-- 			FOR SQLWARNING
--			BEGIN ... END
--		NOT FOUND: Abreviatura para la clase de valores SQLSTATE que comienzan por '02'. Usado sobre todo en cursores
--			DECLARE CONTINUE HANDLER
--			FOR NOT FOUND
--			BEGIN ... END 	
--		SQLEXCEPTION: Abreviatura para las clases de valores SQLSTATE que no comienzan por '00', '01' o '02'

-- Veamos un ejemplo de HANDLER para controlar el error de clave duplicada
-- Recuperamos el procedimiento almacenado que hicimos de "create procedure crea_staff"
-- y lo reescribimos utilizando handlers


-- Versión 3
-- Modificamos la Versión 2 para añadir handlers
-- Conservamos el anterior creando uno nuevo basado en Versión 2

use t5_employees; 
select * from  staff ; 

-- veamos el error que genera una inserción duplicada
insert into staff values(222, 'Tomeu', 'Profesor', null, 5, current_date(), 368);
-- SQL Error [1062] [23000]: Duplicate entry '222' for key 'staff.PRIMARY'

delimiter $$
drop procedure if exists crea_staff_handler $$
create procedure crea_staff_handler(in employee_code smallint unsigned, 
							in employee_name varchar(25),
							in employee_job varchar(25),
							in salary decimal(7,2),
							in deparment_code smallint unsigned,
							in start_date date,
							in superior_officer smallint unsigned,
							out error_message varchar(255))
							
comment 'Inserta tupla en t5_employees.staff
		Control sobre datos obligatorios
		Control integridad referencial
		Control inserción duplicada
		Permite Start_Date is null con current_date()'

proc_label: begin 
	
	-- Declaración de variables locales
	declare variables int default 0; -- ejemplo declaración variables antes de los handlers
	
	-- Declaración de handlers 
	declare exit handler 
	for 1062 -- Error number: 1062; Symbol: ER_DUP_ENTRY; SQLSTATE: 23000 Message: Duplicate entry '%s' for key %d  
	begin
		set error_message = "Error: El empleado ya existe";
	end; 
	
	-- Compobación se han aportado los campos que son obligatorios
	-- Solamente Salary y Department_Code pueden ser null
	-- y también permitimos null en start_date, en tal caso, asignamos current_date
	
	if employee_code is null or employee_name is null
		or employee_job is null or superior_officer is null then 
		
		set error_message = 'Error: Datos obligatorios no aportados'; 
		leave proc_label;
	end if; 

	-- Si no se aporta fecha se asume la actual
	if start_date is null then
		set start_date = current_date(); 
	end if; 

	-- Comprobaciones de integridad referencial FK
	-- Comprobación para deparment_code si se ha aportado
	if deparment_code is not null then
	
		if not exists (select 1=1 from t5_employees.department d
						where d.Department_Code = deparment_code) then
			set error_message = 'Error: Departamento no existe';
			leave proc_label; 
		end if;
	end if; 

	-- Comprobación para superior_officer
	if not exists (select 1=1 from t5_employees.staff s 
					where s.Employee_Code = superior_officer) then 
		set error_message = 'Error: Superior Officer no existe'; 
		leave proc_label; 
	end if; 

	-- Todo es OK, procedemos a la inserción mediante una transacción
	start transaction; 
		insert into t5_employees.staff(Employee_Code, Name, Job, Salary, Department_Code, Start_Date, Superior_Officer)
		values(employee_code, employee_name, employee_job, salary, deparment_code, start_date, superior_officer);
	commit; 

	set error_message = 'Info: Creación empleado OK'; 
		
end$$
delimiter ; 

call crea_staff_handler(222, 'Tomeu', 'Profesor', null, 5, current_date(), 368, @info_error_message); 
select @info_error_message; 
select * from staff; 

-- Ejercicio:
-- Modificar el procedimiento almacenado crea_staff_handler, tal que sea completamente reactivo


-- Versión 4
-- Modificamos la Versión 3 para refactorizar el código y que sea completamente reactivo 
-- por tanto, se añadirán todos los handlers posibles. 

use employees; 

delimiter $$
drop procedure if exists crea_staff_handler $$
create procedure crea_staff_handler(in employee_code smallint unsigned, 
							in employee_name varchar(25),
							in employee_job varchar(25),
							in salary decimal(7,2),
							in deparment_code smallint unsigned,
							in start_date date,
							in superior_officer smallint unsigned,
							out error_message varchar(255))
							
comment 'Inserta tupla en t5_employees.staff
		Handler sobre datos obligatorios
		Handler integridad referencial
		Handler inserción duplicada
		Permite Start_Date is null con current_date()'

begin 
	
	-- Declaración de handlers 
	
	-- Handler para inserción con null en campo obligatorio
	declare exit handler 
	for 1048 -- Error number: 1048; Symbol: ER_BAD_NULL_ERROR; SQLSTATE: 23000 Message: Column '%s' cannot be null
	begin 
		set error_message = 'Error: Datos obligatorios no aportados'; 
	end; 
	
	-- Handler para inserción duplicada
	declare exit handler 
	for 1062 -- Error number: 1062; Symbol: ER_DUP_ENTRY; SQLSTATE: 23000 Message: Duplicate entry '%s' for key %d  
	begin
		set error_message = 'Error: El empleado ya existe';
	end; 

	declare exit handler
	for 1452 -- Error number: 1452; Symbol: ER_NO_REFERENCED_ROW_2; SQLSTATE: 23000 Message: Cannot add or update a child row: a foreign key constraint fails (%s)
	begin
		set error_message = 'Error: Integridad referencial';
	end; 
	
	-- Si no se aporta fecha se asume la actual
	if start_date is null then
		set start_date = current_date(); 
	end if; 


	-- Todo es OK, procedemos a la inserción mediante una transacción
	start transaction; 
		insert into employees(Employee_Code, Name, Job, Salary, Department_Code, Start_Date, Superior_Officer)
		values(employee_code, employee_name, employee_job, salary, deparment_code, start_date, superior_officer);
	commit; 

	set error_message = 'Info: Creación empleado OK'; 
		
end$$
delimiter ; 

call crea_staff_handler(222, 'Tomeu', 'Profesor', null, 5, current_date(), 222, @info_error_message); 
select @info_error_message; 
select * from staff; 

-- Ahora, la pregunta es:
-- Proc almacenados proactivos o reactivos?, Qué estilo de programación es mejor?
-- La respuesta correcta sería "depende" del conocimiento que tengamos del origen de los datos
-- Si el proc es llamado desde un código que controlamos, el proc puede ser reactivo
-- Si el proc puede ser llamado desde objetos sin nuestro control, se recomienda proactivo 

-- Ejercicio
-- Crear los procedimientos almacenados para CRUD (Crate, Read, Update, Delete)
-- crea_staff_handler / read_staff_handler / update_staff_handler / delete_staff_handler



