SHOW WARNINGS;

-- 1. Creamos la DB y modificamos el charset para admitir acentos etc

DROP SCHEMA IF EXISTS `TELEFONIA`;
CREATE SCHEMA IF NOT EXISTS `TELEFONIA` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `TELEFONIA`;

-- 2. Creación de tablas

DROP TABLE IF EXISTS `USUARIOS`;
CREATE TABLE IF NOT EXISTS `USUARIOS` (
    `NIF` VARCHAR(9) NOT NULL, 
    `Nombre` VARCHAR(20) NOT NULL,
    `Apellido1` VARCHAR(20) NOT NULL,
    `Apellido2` VARCHAR(20),
    `Fec_Nacim` DATE,
    CONSTRAINT PK_NIF PRIMARY KEY (`NIF`),
    CONSTRAINT CHK_Fec_Nacim CHECK (`Fec_Nacim` >= '1900-01-01')) -- De esta forma sólo admitirá valores después de dicha fecha
ENGINE = InnoDB;

DROP TABLE IF EXISTS `COMPANIAS`;
CREATE TABLE IF NOT EXISTS `COMPANIAS` (
	`ID_Compania` INT NOT NULL,
    `Nombre` VARCHAR(20) NOT NULL,
    `Anio_Fundacion` INT NOT NULL,
    CONSTRAINT PK_IDCompania PRIMARY KEY (`ID_Compania`),
    CONSTRAINT CHK_ID_Compania CHECK (`ID_Compania` BETWEEN 0 AND 9999), -- Solo enteros entre 0 y 9999
    CONSTRAINT CHK_Anio_Fundacion CHECK (`Anio_Fundacion` BETWEEN 1900 AND 2010))
ENGINE = InnoDB;


DROP TABLE IF EXISTS `TELEFONOS`;
CREATE TABLE IF NOT EXISTS `TELEFONOS` (
	`Numero` VARCHAR(13) UNIQUE NOT NULL,
    `NIF_Usuario` VARCHAR(20) NOT NULL,
    `ID_Compania` INT NOT NULL,
    CONSTRAINT PK_Numero PRIMARY KEY (`Numero`),
    CONSTRAINT FK_USUARIOS FOREIGN KEY (`NIF_Usuario`) REFERENCES `USUARIOS`(`NIF`),
    CONSTRAINT FK_ID_Compania FOREIGN KEY (`ID_Compania`) REFERENCES `COMPANIAS`(`ID_Compania`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `LLAMADAS`;
CREATE TABLE IF NOT EXISTS `LLAMADAS` (
	`Num_Llamante` VARCHAR(13) NOT NULL,
    `Num_Llamado` VARCHAR(13) NOT NULL,
    `Fecha` DATETIME,
    `Tiempo` INT NOT NULL,
    CONSTRAINT PK_NumLlamadas_Fecha PRIMARY KEY (`Num_Llamante`, `Num_Llamado`, `Fecha`),
    CONSTRAINT FK_Num_Llamante FOREIGN KEY (`Num_Llamante`) REFERENCES `TELEFONOS`(`Numero`),
    CONSTRAINT FK_Num_Llamado FOREIGN KEY (`Num_Llamado`) REFERENCES `TELEFONOS`(`Numero`),
    CONSTRAINT CHK_Fecha CHECK (`Fecha` >= '1900-01-01 00:00:00'), -- Obligamos a que adopte valores sólo a partir del 1 de Enero de 1900 y que además se tenga que introducir la hora (DATETIME)
    CONSTRAINT CHK_Tiempo CHECK (`Tiempo` >= 0 AND `Tiempo` <= 9999999))
ENGINE = InnoDB;

INSERT INTO `Usuarios`
VALUES

('555999222', 'Andy', 'López', 'Rey', '1999-09-05'),
('231589456', 'Pepe', 'Heym', 'Nova', '1969-02-05'),
('123456789', 'Cristian', 'García', 'Kasa', '2001-02-06'),
('987654321', 'Juán', 'Armin', 'Petreo', '1989-01-02');

SELECT * FROM `Usuarios`;

-- INSERT INTO `Usuarios` VALUES ('555999222', 'Andy', 'López', 'Rey', '1000-01-01'); 
-- Comprobamos que la constraint funcione :)

INSERT INTO `COMPANIAS`
VALUES

(1, 'Cesur', 2000),
(2, 'Borja Moll', 1985);

SELECT * FROM `COMPANIAS`;

-- INSERT INTO `COMPANIAS` VALUES (3, 'CISC', 2024); 
-- Comprobamos que funciona la constraint :D

INSERT INTO `TELEFONOS` 
VALUES

('658452369', '555999222', 1),
('545987256', '231589456', 2),
('789456123', '123456789', 1);

SELECT * FROM `TELEFONOS`;

INSERT INTO `LLAMADAS` VALUES ('658452369', '545987256', '2024-01-01 02:05:01', 54);
SELECT * FROM `LLAMADAS`;

/*
INSERT INTO `LLAMADAS` VALUES ('789456123', '545987256', '1899-01-01 02:05:01', 54);
INSERT INTO `LLAMADAS` VALUES ('789456123', '545987256', '2024-02-21 02:05:01', -5);
Ambos CHECK funcionan :D
*/

-- 3. Modificar en TELEFONOS el atributo Numero para que admita como maximo 11 caracteres

SET FOREIGN_KEY_CHECKS = 0;
COMMIT; -- Es buena práctica añadir COMMIT después de hacer ALTER TABLE de KEYS

ALTER TABLE `TELEFONOS`
MODIFY `Numero` VARCHAR(11) UNIQUE NOT NULL;

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;

/* 
Explicación:

No podemos modificar el atributo numero debido a que es una FK de otra tabla. Por tanto hemos de desactivar las FK antes.
InnoDB no deja desactivar FK usando ALTER TABLE table_name DISABLE KEYS; y luego habilitandola (ALTER TABLE table_name ENABLE KEYS).
Por tanto lo debemos hacer con un SET.
Es muy importante volver a activar las KEYS una vez terminado el proceso si no queremos comprometer la integridad referencial.
*/

-- 4. Añadir a USUARIOS un nuevo ATRIBUTO llamado DIRECCION después de APELLIDO2. Máximo 100 caracteres y puede estar vacío

ALTER TABLE `Usuarios`
ADD COLUMN `Direccion` VARCHAR(100) AFTER `Apellido2`; -- Default es Null no hay que especificarlo

-- 5. USUARIOS -> CLIENTES

ALTER TABLE `USUARIOS`
RENAME `CLIENTES`;

-- 6. Apellido1 y Apellido2 -> Ap 1 y Ap2 de CLIENTES

ALTER TABLE `CLIENTES`
CHANGE `Apellido1` `Ap1` VARCHAR(20) NOT NULL,
CHANGE `Apellido2` `Ap2` VARCHAR(20);

-- 7. CLIENTES -> USUARIOS

ALTER TABLE `CLIENTES`
RENAME `USUARIOS`;

-- 8. Ap1 y Ap2 -> Apellido1 y Apellido2 (really?)

ALTER TABLE `USUARIOS`
CHANGE `Ap1` `Apellido1` VARCHAR(20) NOT NULL,
CHANGE `Ap2` `Apellido2` VARCHAR(20);

-- 9. En LLAMADAS añadir una restricción para que un número no se pueda llamar a sí mismo

ALTER TABLE `LLAMADAS`
ADD CONSTRAINT CHK_NoSelfCall CHECK (`Num_Llamante` <> `Num_Llamado`);

-- 10. En USUARIOS, eliminar el atributo DIRECCION

ALTER TABLE `USUARIOS`
DROP `Direccion`;

-- 11. Eliminar todas las relaciones de TELEFONIA

DROP TABLE `Llamadas`;
DROP TABLE `Telefonos`;
DROP TABLE `Companias`;
DROP TABLE `Usuarios`;

-- Nota: el orden en el que se elimina es relevante si antes no se desactivan todas las FK (tal y como tuvimos que hacer en el punto 3). De lo contrario 
-- por la integridad referencial no nos dejaría eliminar las tablas.

-- 12. Eliminar la base de datos TELEFONIA

DROP DATABASE TELEFONIA; -- See you later alligator
