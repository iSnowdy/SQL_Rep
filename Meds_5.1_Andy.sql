SHOW WARNINGS;

-- 1. DDL / INSERT's

DROP SCHEMA IF EXISTS `MEDS_5_1`;
CREATE SCHEMA IF NOT EXISTS `MEDS_5_1` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `MEDS_5_1`;

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
-- INSERT INTO se especifique que no se quieren introducir datos en ella.

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

-- 2. Modificar el sueldo de los repartidores de Madrid, asignándoles un sueldo de 1200 euros

UPDATE REPARTIDORES
SET Sueldo = 1200.00
WHERE Provincia = 'MADRID'; -- RIP Luis

SELECT * FROM REPARTIDORES;

-- 3. Eliminar las farmacias a las que no se les ha hecho ningún reparto

-- Se han repartido a las farmacias con código 4, 5 y 2. Se tendrían que eliminar: 1, 3

DELETE
FROM FARMACIAS
WHERE CodFarmacia NOT IN (
    SELECT CodFarmacia
    FROM REPARTOS
    );

-- 4. Aumentar el sueldo un 10% a los repartidores que han repartido más de 10 medicamentos en el último mes.
-- Cuándo: WHERE Fecha BETWEEN '2016/02/01' AND '2016/02/28')
-- Aplica la siguiente estrategia:
    -- Identificamos los repartos del último mes
    -- Agrupamos por NIF y contamos número de medicamentos
    -- Filtra el resultado para más de 10 medicamentos
    -- Aplica el UPDATE usando el SUB SELECT confeccionado anterior

SELECT NIF_Repartidor, sum(Cantidad) AS 'Medicamentos_Total'
FROM REPARTOS
WHERE Fecha BETWEEN '2016-02-01' AND '2016-02-28'
GROUP BY NIF_Repartidor
HAVING Medicamentos_Total > 10;

-- Query que busca por NIF los repartidores que hayan repartido entre esa fecha, los agrupa (para evitar repeticiones)
-- y aplica otro filtro luego para que sólo aparezcan aquellos que han repartido más de 10 medicamentos en total

-- Ahora procederíamos a aplicar el UPDATE sobre el salario pero usando la SELECT anterior. No directamente sobre el NIF ese
-- 2B

UPDATE REPARTIDORES
SET Sueldo = Sueldo * 1.1
WHERE NIF IN (
    SELECT NIF_Repartidor
    FROM REPARTOS
    WHERE Fecha BETWEEN '2016-02-01' AND '2016-02-28'
    GROUP BY NIF_Repartidor
    HAVING sum(Cantidad) > 10
    );

-- Aquí utilizamos la Query anterior para hacer el UPDATE. No incluímos en el select el sum(Cantidad) no sólo porque
-- realmente no nos interesa (no lo veremos por pantalla), sino también porque estaríamos haciendo un SELECT de 2
-- columnas

-- 5. Aumentar en un 15% el precio del medicamento que más se ha repartido. Estrategia:
    -- Creamos una vista con la cantidad de repartos de cada medicamentos (GROUP BY)
    -- Identificamos, con la vista, el máximo de unidades que se han repartido (MAX())
    -- Identificamos los medicamentos que coincidan con el máximo que se ha repartido
    -- Aplicamos el UPDATE con lo anterior
    -- Borra la vista

CREATE VIEW Vista_Repartos (CodMedicamento, Unidades) AS
SELECT CodMedicamento, sum(Cantidad)
FROM REPARTOS
GROUP BY CodMedicamento;

-- Vista que nos muestra el código del medicamento y cuántas veces se ha repartido

SELECT max(Unidades) AS Max_Unidades
FROM Vista_Repartos;

SELECT CodMedicamento
FROM Vista_Repartos
WHERE Unidades = 10; -- 2 y 3. Precios OG: 5, 2

UPDATE MEDICAMENTOS
SET Precio = Precio * 1.5
WHERE CodMedicamento = 2 OR CodMedicamento = 3;

DROP VIEW Vista_Repartos;

-- 6. Registrar el reparto de un pedido realizado por el repartidor con el NIF 1A a la farmacia con código
-- 2 de 20 unidades del medicamento con código 3. El reparto se hace en la fecha de hoy. Se debe registrar de forma
-- que la base de datos quede coherente

SELECT * FROM REPARTOS;
SELECT * FROM FARMACIAS;
SELECT * FROM MEDICAMENTOS;
SELECT * FROM REPARTIDORES;

INSERT INTO REPARTOS VALUES
('1A', 2, 3, curdate(), 20);

UPDATE MEDICAMENTOS
SET Stock = Stock - 20
WHERE CodMedicamento = 3;

-- Actualizamos el stock de medicamentos de la base de datos ya que se han repartido 20 a una farmacia