SHOW WARNINGS;

-- 1. Crear DB

DROP SCHEMA IF EXISTS `FORMACION_EMPLEADOS`;
CREATE SCHEMA IF NOT EXISTS `FORMACION_EMPLEADOS` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `FORMACION_EMPLEADOS`;

-- 2. Crear relaciones/tablas

DROP TABLE IF EXISTS `CURSOS`;
CREATE TABLE IF NOT EXISTS `CURSOS` (
	`RefCurso` INT NOT NULL,
    `Duracion` INT NOT NULL,
    `Descripcion` VARCHAR(200) NOT NULL,
    CONSTRAINT PK_RefCurso PRIMARY KEY (`RefCurso`),
    CONSTRAINT CHK_RefCurso CHECK (`RefCurso` >= 0),
    CONSTRAINT CHK_Duracion CHECK (`Duracion` BETWEEN 1 AND 2000))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `EMPLEADOS`;
CREATE TABLE IF NOT EXISTS `EMPLEADOS` (
	`NIF` VARCHAR(12) NOT NULL,
    `Nombre` VARCHAR(25) NOT NULL,
    `Apellido1` VARCHAR(25) NOT NULL,
    `Apellido2` VARCHAR(25),
    `FecNacimiento` DATE, 
    `Salario` DECIMAL (6, 2) NOT NULL,
    `Sexo` ENUM('HOMBRE', 'MUJER') NOT NULL,
    `Nacion` VARCHAR(50) DEFAULT 'ESPAÑA',
    `Firma` VARCHAR(200), -- Para hacerlo con imagen sería el tipo de dato BLOB. Luego con un INSERT INTO se metería la imagen. Los valores para la imagen van dentro de un <binary data>
    CONSTRAINT PK_NIF PRIMARY KEY (`NIF`),
    CONSTRAINT CHK_Salario CHECK (`Salario` BETWEEN 100.00 AND 9999.99))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `EDICIONES`;
CREATE TABLE IF NOT EXISTS `EDICIONES` (
	`CodEdicion` INT NOT NULL,
    `RefCurso` INT NOT NULL,
    `Fecha` DATE NOT NULL,
    `Lugar` VARCHAR(100) NOT NULL,
    `Coste` DECIMAL (7, 2)  NOT NULL, -- 7 + 2 digitos (decimales)
    `NIF_Docente` VARCHAR(12) NOT NULL,
    CONSTRAINT PK_CodEdicion PRIMARY KEY (`CodEdicion`),
    CONSTRAINT FK_NIFDocenteEdiciones FOREIGN KEY (`NIF_Docente`) REFERENCES `EMPLEADOS`(`NIF`),
    CONSTRAINT FK_RefCursoEdiciones FOREIGN KEY (`RefCurso`) REFERENCES `CURSOS`(`RefCurso`),
    CONSTRAINT CHK_CodEdicion CHECK (`CodEdicion` >= 0),
    CONSTRAINT CHK_Coste CHECK (`Coste` BETWEEN 0 AND 99999.99))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `TELEFONOS`;
CREATE TABLE IF NOT EXISTS `TELEFONOS` (
	`NIF_Empleado` VARCHAR(12) NOT NULL,
    `Telefono` VARCHAR(11) NOT NULL,
    CONSTRAINT PK_TelefonoNIFEmpleado PRIMARY KEY (`Telefono`, `NIF_Empleado`),
    CONSTRAINT FK_NIFEmpleadoTelefonos FOREIGN KEY (`NIF_Empleado`) REFERENCES `EMPLEADOS`(`NIF`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `CAPACITACIONES`;
CREATE TABLE IF NOT EXISTS `CAPACITACIONES` (
	`RefCurso` INT NOT NULL,
    `NIF_Empleado` VARCHAR(12) NOT NULL,
    CONSTRAINT PK_RefCursoNIFEmpleado PRIMARY KEY (`RefCurso`, `NIF_Empleado`),
    CONSTRAINT FK_RefCursoCapacitaciones FOREIGN KEY (`RefCurso`) REFERENCES `CURSOS`(`RefCurso`),
    CONSTRAINT FK_NIFEmpleadoCapacitaciones FOREIGN KEY (`NIF_Empleado`) REFERENCES `EMPLEADOS`(`NIF`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `PRERREQUISITOS`;
CREATE TABLE IF NOT EXISTS `PRERREQUISITOS` (
	`RefCursoARealizar` INT NOT NULL,
    `RefCursoARequisito` INT NOT NULL,
    `Tipo` VARCHAR(15) NOT NULL,
    CONSTRAINT PK_RefCursoARealizar PRIMARY KEY (`RefCursoARealizar`, `RefCursoARequisito`),
    CONSTRAINT FK_RefCursoARealizarPrerrequisitos FOREIGN KEY (`RefCursoARealizar`) REFERENCES `CURSOS`(`RefCurso`),
    CONSTRAINT FK_RefCursoARequisitoPrerrequisitos FOREIGN KEY (`RefCursoARequisito`) REFERENCES `CURSOS`(`RefCurso`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `MATRICULAS`;
CREATE TABLE IF NOT EXISTS `MATRICULAS` (
	`NIF_Alumno` VARCHAR(12) NOT NULL,
    `CodEdicion` INT NOT NULL,
    CONSTRAINT PK_NIFAlumno PRIMARY KEY (`NIF_Alumno`, `CodEdicion`),
    CONSTRAINT FK_NIF_AlumnoMatriculas FOREIGN KEY (`NIF_Alumno`) REFERENCES `EMPLEADOS`(`NIF`),
    CONSTRAINT FK_CodEdicionMatriculas FOREIGN KEY (`CodEdicion`) REFERENCES `EDICIONES`(`CodEdicion`))
ENGINE = InnoDB;

-- Comprobación de CHECKs

/*

NOTA: no funcionarán si no se añade el atributo del punto 3

INSERT INTO `CURSOS` VALUES (-1, 'Informática', 500, 'DAW');
INSERT INTO `CURSOS` VALUES (1, 'Informática', 0, 'DAW');

INSERT INTO `EMPLEADOS` VALUES ('789456123S', 'Dana', 'Nanai', NULL, '1990-05-21', 542.42, 'MUJER', 'DANANANA'); -- Decimal funciona. Importante: si no se ejecuta primero el DROP `Nacion` dará error :D
SELECT * FROM `EMPLEADOS`;

-- SERT INTO `EMPLEADOS` VALUES ('123456789H', 'Adana', 'Aanai', NULL, '1990-05-21', 15, 'MUJER', 'DANANANA');

INSERT INTO `CURSOS` VALUES (1, 'Informática', 500, 'DAW');
INSERT INTO `CURSOS` VALUES (2, 'Higiene Buco Dental', 550, 'HBC');
SELECT * FROM `CURSOS`;

INSERT INTO `PRERREQUISITOS` VALUES (1, 2, 'ACONSEJABLE');
SELECT * FROM `PRERREQUISITOS`;
INSERT INTO `PRERREQUISITOS` VALUES (1, 1, 'OBLIGATORIO'); CHECK != funciona

*/

-- 3. En CURSOS añadir un nuevo ATRIBUTO como se describe. Después de RefCurso

ALTER TABLE `CURSOS`
ADD COLUMN `Titulo` VARCHAR(25) AFTER `RefCurso`;

-- 4. MATRICULAS -> MATRICULACIONES

ALTER TABLE `MATRICULAS`
RENAME `MATRICULACIONES`;

-- 5. En PRERREQUISITOS, ATRIBUTO RefCursoaRequisito -> RefCursoRequisito

ALTER TABLE `PRERREQUISITOS`
CHANGE `RefCursoARequisito` `RefCursoRequisito` INT NOT NULL;

-- 6. En PRERREQUISITOS, añadir restricción para que el ATRIBUTO Tipo solo pueda tener los valores: 'ACONSEJABLE', 'OBLIGATORIO'

ALTER TABLE `PRERREQUISITOS`
MODIFY `Tipo` ENUM('ACONSEJABLE', 'OBLIGATORIO') NOT NULL;

-- 7. En PRERREQUISITOS, añadir una restricción para que un curso no pueda ser prerrequisito de él mismo

ALTER TABLE `PRERREQUISITOS`
ADD CONSTRAINT CHK_NoMismoCurso CHECK (`RefCursoARealizar` != `RefCursoRequisito`); -- Al parecer MySQL admite tanto <> como != como operators. De hecho en la información de la tabla luego modifica != -> <>

-- 8. En EMPLEADOS eliminar el ATRIBUTO Nacion

ALTER TABLE `EMPLEADOS`
DROP `Nacion`;

-- 9. Reverse Engineer la DB para obtener el diagrama

-- 10. Eliminar todas las relaciones de la base de datos

SET FOREIGN_KEY_CHECKS = 0;
COMMIT;

DROP TABLE `CAPACITACIONES`, `CURSOS`, `EDICIONES`, `EMPLEADOS`, `MATRICULACIONES`, `PRERREQUISITOS`, `TELEFONOS`;

-- 11. Eliminar la base de datos

DROP DATABASE `FORMACION_EMPLEADOS`; -- Goodbye!
