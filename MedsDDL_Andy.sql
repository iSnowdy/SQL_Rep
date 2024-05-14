SHOW WARNINGS;

DROP SCHEMA IF EXISTS `DISTRIBUCIÓN_MEDICAMENTOS`;
CREATE SCHEMA IF NOT EXISTS `DISTRIBUCIÓN_MEDICAMENTOS` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `DISTRIBUCIÓN_MEDICAMENTOS`;

DROP TABLE IF EXISTS `MEDICAMENTOS`;
CREATE TABLE IF NOT EXISTS `MEDICAMENTOS` (
	`CodMedicamento` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(25) NOT NULL,
    `Descripción` VARCHAR(200),
    `Precio` DECIMAL(6, 2) NOT NULL,
    `Stock` INT DEFAULT 0,
    CONSTRAINT PK_CodMedicamento PRIMARY KEY (`CodMedicamento`),
    -- CONSTRAINT CHK_CodMedicamento CHECK (`CodMedicamento` >= 0), no hace falta porque el AUTO-INCREMENT ya controla que se empiece por un valor positivo (1 by default)
    CONSTRAINT CHK_Precio CHECK (`Precio` BETWEEN 0.01 AND 9999.99),
    CONSTRAINT CHK_Stock CHECK (`Stock` BETWEEN 0 AND 9999))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `FARMACIAS`;
CREATE TABLE IF NOT EXISTS `FARMACIAS` (
	`CodFarmacia` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(25) NOT NULL,
    `Dirección` VARCHAR(100),
    `Provincia` VARCHAR(20),
    `AnioApertura` INT,
    CONSTRAINT PK_CodFarmacia PRIMARY KEY (`CodFarmacia`),
    -- CONSTRAINT CHK_CodFarmacia CHECK (`CodFarmacia` >= 0),
    CONSTRAINT CHK_AnioApertura CHECK (`AnioApertura` BETWEEN 1800 AND 2200))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `REPARTIDORES`;
CREATE TABLE IF NOT EXISTS `REPARTIDORES` (
	`NIF` VARCHAR(12) NOT NULL,
    `Nombre` VARCHAR(25) NOT NULL,
    `Apellido1` VARCHAR(25) NOT NULL,
    `Apellido2` VARCHAR (25),
    `FechaNacimiento` DATE,
    `Dirección` VARCHAR(100), 
    `Provincia` VARCHAR(20) NOT NULL,
    `Sueldo` DECIMAL(6, 2) NOT NULL,
    CONSTRAINT PK_NIFRepartidores PRIMARY KEY (`NIF`),
    CONSTRAINT CHK_Sueldo CHECK (`Sueldo` BETWEEN 100.00 AND 9999.99))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `REPARTOS`;
CREATE TABLE IF NOT EXISTS `REPARTOS` (
	`NIF_Repartidor` VARCHAR(12) NOT NULL,
    `CodFarmacia` INT NOT NULL,
    `CodMedicamento` INT NOT NULL,
    `Fecha` DATE NOT NULL,
    `Cantidad` INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_FechaRepartos PRIMARY KEY (`Fecha`),
    CONSTRAINT FK_NIFRepartidorRepartos FOREIGN KEY (`NIF_Repartidor`) REFERENCES `REPARTIDORES`(`NIF`),
    CONSTRAINT FK_CodFarmaciaRepartos FOREIGN KEY (`CodFarmacia`) REFERENCES `FARMACIAS`(`CodFarmacia`),
    CONSTRAINT FK_CodMedicamento FOREIGN KEY (`CodMedicamento`) REFERENCES `MEDICAMENTOS`(`CodMedicamento`),
    CONSTRAINT CHK_Cantidad CHECK (`Cantidad` BETWEEN 1 AND 9999))
ENGINE = InnoDB;

-- 1. Introducir los datos mostrados

INSERT INTO `FARMACIAS` (`Nombre`, `Dirección`, `Provincia`, `AnioApertura`)
VALUES
('Gamo', NULL, 'MADRID', 2000),
('LDO. GARCÍA PÉREZ', NULL, 'BARCELONA', 1880),
('LDO.VARGAS', NULL, 'ALMERIA', 1986),
('PÉREZ E HIJOS', NULL, 'MÁLAGA', 1930),
('VDA. DE LORENZO E HIJOS', NULL, 'MADRID', 1896);

SELECT * FROM `FARMACIAS`; -- Comprobamos que se haya introducido correctamente.

-- Nota: aunque se haya diseñado la columna `CodFarmacia` como AUTO-INCREMENT, MySQL aún así espera que cuando se haga un 
-- INSERT INTO se especifique que no se quieren introducir datos en ella. Por tanto, un INSERT INTO `FARMACIAS` no funcionaría

INSERT INTO `MEDICAMENTOS` (`Nombre`, `Precio`, `Stock`) -- Descripción estaba vacío. Al no especificarlo nos ahorramos el escribir NULL como antes
VALUES
('ASPIRINA', 3.00, 30),
('GELOCATIL', 5.00, 30),
('IBUPROFENO', 2.00, 60),
('CARIBAN', 2.50, 20);

SELECT * FROM `MEDICAMENTOS`;

INSERT INTO `REPARTIDORES` (`NIF`, `Nombre`, `Apellido1`, `Apellido2`, `FechaNacimiento`, `Provincia`, `Sueldo`)
VALUES
('1A', 'LUIS', 'GARCÍA', 'LÓPEZ', '1979-02-16', 'MADRID', 2000.00),
('2B', 'JUAN', 'GARCÍA', 'LÓPEZ', '1985-02-04', 'BARCELONA', 1580.00),
('3C', 'PEDRO', 'ROMANCO', 'PETRI', NULL, 'MADRID', 1000.00),
('4D', 'MARÍA', 'VÁZQUEZ', 'LÓPEZ', '1990-02-24', 'ALMERIA', 2500.00);

SELECT * FROM `REPARTIDORES`;

INSERT INTO `REPARTOS` (`NIF_Repartidor`, `CodFarmacia`, `CodMedicamento`, `Fecha`, `Cantidad`)
VALUES
('2B', 2, 1, '2016-02-08', 6),
('2B', 5, 3, '2016-02-03', 10),
('3C', 4, 2, '2015-02-08', 10);

SELECT * FROM `REPARTOS`;

-- 2. Medicamentos Precio < 3

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `Precio`  < 3.00;

-- 3. Farmacias -> Madrid

SELECT `Nombre`, `Provincia`
FROM `FARMACIAS`
WHERE `Provincia` LIKE '%Madrid';

-- 4. Repartidores Sueldo >= 1500

SELECT `Nombre`, `Sueldo`
FROM `REPARTIDORES`
WHERE `Sueldo` >= 1500.00;

-- 5. Fechas REPARTOS del REPARTIDOR Juan García López

SELECT `NIF`, `Nombre`
FROM `REPARTIDORES`
WHERE `Nombre` = 'JUAN' AND `Apellido1` = 'GARCÍA'; -- Primero buscamos su DNI para buscarlo luego en REPARTOS. Pero no es lo más óptimo

SELECT `NIF_Repartidor`, `Fecha`
FROM `REPARTOS`
WHERE `NIF_Repartidor` = (
	SELECT `NIF` 
    FROM `REPARTIDORES` 
    WHERE `Nombre` = 'JUAN' AND `Apellido1` = 'GARCÍA'); -- Es la forma más óptima de buscar el NIF

-- 6. Nombre de las FARMACIAS donde ha repartido Juan García López

SELECT `CodFarmacia`, `Nombre`
FROM `FARMACIAS`
WHERE `CodFarmacia` IN (
	SELECT `CodFarmacia` 
    FROM `REPARTOS` 
    WHERE `NIF_Repartidor` = (
		SELECT `NIF` 
        FROM `REPARTIDORES`
        WHERE `Nombre` = 'JUAN' AND `Apellido1` = 'GARCÍA')); 

-- De no usar el IN el subquery nos retornaría más de una fila (porque ha repartido en más de una farmacia

-- 7. Nombre de los MEDICAMENTOS que nunca se han repartido en MÁLAGA

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `CodMedicamento` NOT IN (
	SELECT `CodMedicamento`
    FROM `REPARTOS`
    WHERE `CodFarmacia` IN (
		SELECT `CodFarmacia`
        FROM `FARMACIAS` 
        WHERE `Provincia` = 'MÁLAGA')); 

-- O sea: muéstrame el nombre de los medicamentos cuyo código NO esté en la subquery de los códigos de medicamento de la tabla
-- repartos donde se haya repartido en las farmacias con el código donde la provincia sea Málaga

-- 8. Nombre de los MEDICAMENTOS que sólo se haya repartido en MÁLAGA

/*

INSERTs para comprobar que el QUERY funciona correctamente. No forman parte del ejercicio

INSERT INTO `MEDICAMENTOS` (`Nombre`, `Precio`, `Stock`)
VALUES
('ENAMPLUS', 7.00, 10);

INSERT INTO `REPARTIDORES` (`NIF`, `Nombre`, `Apellido1`, `Apellido2`, `FechaNacimiento`, `Provincia`, `Sueldo`)
VALUES
('69X', 'FRANCESC', 'MAGALLAN', 'NULL', '1989-07-21', 'MÁLAGA', 1111.11),
('19X', 'PEPE', 'BERBER', 'NULL', '1972-12-25', 'MADRID', 2222.22);

INSERT INTO `REPARTOS` (`NIF_Repartidor`, `CodFarmacia`, `CodMedicamento`, `Fecha`, `Cantidad`)
VALUES
('19X', 4, 5, '2024-05-22', 5), -- Primero sólo este valor. Debería dar Gelocatil + Enamplus
('69X', 1, 5, '2023-06-21', 6); -- Luego simulamos que también se reparte en Madrid. Debería de volver a dar sólo Gelocatil

*/

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `CodMedicamento` IN (
	SELECT `CodMedicamento`
    FROM `REPARTOS`
    WHERE `CodFarmacia` IN (
		SELECT `CodFarmacia`
        FROM `FARMACIAS` 
        WHERE `Provincia` = 'MÁLAGA') -- Hasta aquí: medicamentos repartidos en Málaga (muy similar a la anterior)
	AND `CodMedicamento` NOT IN (
		SELECT `CodMedicamento`
		FROM `REPARTOS`
		WHERE `CodFarmacia` IN (
			SELECT `CodFarmacia`
			FROM `FARMACIAS`
			WHERE `Provincia` <> 'MÁLAGA'))); -- Y además luego excluímos al resto de provincias. Así sacamos los medicamentos que sólo se hayan repartido en Málaga
            
-- 9. Nombre de los MEDICAMENTOS que se hayan repartido en MADRID y Barcelona

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `CodMedicamento` IN (
	SELECT `CodMedicamento`
    FROM `REPARTOS`
    WHERE `CodFarmacia` IN (
		SELECT `CodFarmacia`
        FROM `FARMACIAS`
        WHERE `Provincia` = 'MADRID')
	AND `CodMedicamento` IN ( -- Debemos encadenar las subquerys con un AND porque si hacemos 'MADRID' AND 'BARCELONA' siempre devolverá 0. Porque no pueden existir ambos valores a la vez en la misma tupla
		SELECT `CodMedicamento`
        FROM `REPARTOS`
        WHERE `CodFarmacia` IN (
			SELECT `CodFarmacia`
            FROM `FARMACIAS`
            WHERE `Provincia` = 'BARCELONA')));
        
-- 10. Nombre de los MEDICAMENTOS que se hayan repartido en Madrid o Barcelona

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `CodMedicamento` IN (
	SELECT `CodMedicamento`
    FROM `REPARTOS`
    WHERE `CodFarmacia` IN (
		SELECT `CodFarmacia`
        FROM `FARMACIAS` 
        WHERE `Provincia` = 'MADRID' OR `Provincia` = 'BARCELONA'));

-- Con UNION es básicamente lo mismo que se hizo antes pero AND -> UNION (y -> o). En este caso sí se puede concatenar con un OR en la misma subquery porque es uno u otro; no ambos a la vez

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `CodMedicamento` IN (
	SELECT `CodMedicamento`
    FROM `REPARTOS`
    WHERE `CodFarmacia` IN (
		SELECT `CodFarmacia`
        FROM `FARMACIAS`
        WHERE `Provincia` = 'MADRID')
	UNION (
		SELECT `CodMedicamento`
        FROM `REPARTOS`
        WHERE `CodFarmacia` IN (
			SELECT `CodFarmacia`
            FROM `FARMACIAS`
            WHERE `Provincia` = 'BARCELONA')));
        
-- 11. REPARTIDORES con el mayor Sueldo

SELECT `Nombre`, `Sueldo` as 'Sueldo Máximo'
FROM `REPARTIDORES`
WHERE `Sueldo` = (
	SELECT max(`Sueldo`) 
    FROM `REPARTIDORES`);

-- 12. Nombre de los MEDICAMENTOS que se han repartido en > 2 FARMACIAS de Almería

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE `CodMedicamento` IN (
	SELECT `CodMedicamento`
    FROM `REPARTOS`
    WHERE `CodFarmacia` IN (
		SELECT `CodFarmacia`
        FROM `FARMACIAS`
        WHERE `Provincia` = 'ALMERIA' )
	GROUP BY `CodMedicamento`
	HAVING count(DISTINCT `CodFarmacia`) > 2);

-- El DISTINCT aquí está haciendo que se busque instancias en que se han repartido medicamentos en más de 2 farmacias DIFERENTES en Almería. Por tanto aunque un medicamento se reparta en la misma farmacia 3 veces, no saldría

-- 13. Buscar el repartidor que más REPARTOS ha realizado

SELECT `NIF_Repartidor`, count(*) AS 'Nº de veces que ha repartido'
FROM `REPARTOS`
GROUP BY `NIF_Repartidor`; -- Búsqueda un poco más manual y que no da el resultado directamente

SELECT `Nombre`, `Apellido1`, `Apellido2`, `NIF`
FROM `REPARTIDORES`
WHERE `NIF` = (
	SELECT `NIF_Repartidor`
    FROM `REPARTOS`
    GROUP BY `NIF_Repartidor`
    ORDER BY count(*) DESC
    LIMIT 1); -- El LIMIT 1 se ha de poner porque de lo contrario da error (devuelve más de 1 tupla). Además, queremos el máximo, el que más

-- 14. Sueldo promedio de los repartidores de Madrid

SELECT round(avg(`Sueldo`), 2) as 'Sueldo Promedio'
FROM `REPARTIDORES`
WHERE `Provincia` = 'Madrid';  -- Importante: repartidores DE Madrid

-- 15. Nombre de los MEDICAMENTOS que se han distribuido a todas las FARMACIAS de Santander

/* 

Para buscar sólo los medicamentos que se hayan distribuido en TODAS las farmacias de Santander, tenemos que hacer una igualación en el WHERE
inicial para comparar. Tenemos 2 lados pues:

	1. Primero buscaremos los medicamentos que se han repartido en las farmacias de Santander. Es importante buscar y contar sólo las farmacias
    diferentes (de ahí el DISTINCT). El WHERE de este primer subquery busca sólo los medicamentos que coincidan tanto en medicamentos como en
    la farmacia Y que estén en Santander en la tabla FARMACIAS
    2. Luego el otro lado de la igualación lo que hace es simplemente contar la cantidad de farmacias que hay en Santander y mira si son iguales

*/

SELECT `Nombre`
FROM `MEDICAMENTOS`
WHERE (
    SELECT count(DISTINCT `CodFarmacia`)
    FROM `REPARTOS`
    WHERE `CodMedicamento` = `CodMedicamento`
    AND `CodFarmacia` IN (
        SELECT `CodFarmacia`
		FROM `FARMACIAS`
        WHERE `Provincia` = 'SANTANDER')) 
= (
    SELECT COUNT(*)
    FROM `FARMACIAS`
    WHERE `Provincia` = 'SANTANDER'); -- Está mal :(

-- 16. Valor total de la mercancía distribuída por Luis García López

SELECT * FROM `Repartos`;
SELECT * FROM `Repartidores`;










