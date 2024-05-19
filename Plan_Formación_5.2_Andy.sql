SHOW WARNINGS;

-- 1. Creación de la Base de Datos

DROP SCHEMA IF EXISTS `FORMACION_EMPLEADOS`;
CREATE SCHEMA IF NOT EXISTS `FORMACION_EMPLEADOS` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `FORMACION_EMPLEADOS`;

-- 2. DDL - Creación de Relaciones

DROP TABLE IF EXISTS `CURSOS`;
CREATE TABLE IF NOT EXISTS `CURSOS` (
    `RefCurso` INT NOT NULL,
    `Duracion` INT NOT NULL, -- Expresa horas. Se podría usar un TIME NOT NULL pero también expresaría minutos y no tiene sentido en el contexto (horas de duración de un curso)
    `Descripcion` VARCHAR(200) NOT NULL,
    CONSTRAINT PK_RefCursoCursos PRIMARY KEY (`RefCurso`),
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
    `Salario` DECIMAL(6,2) NOT NULL,
    `Sexo` ENUM('HOMBRE', 'MUJER') NOT NULL,
    `Nacion` VARCHAR(50) DEFAULT ('ESPAÑA'),
    `Firma` VARCHAR(200), -- Se podría usar el tipo de dato BLOB (MEDIUMBLOB, LONGBLOB; dependiendo del tamaño de la imagen) pero habría que convertir la imagen en Bytes y luego descifrarla para mostrarla
    CONSTRAINT PK_NIFEmpleados PRIMARY KEY (`NIF`),
    CONSTRAINT CHK_SalarioEmpleados CHECK (`Salario` BETWEEN 100.00 AND 9999.99))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `EDICIONES`;
CREATE TABLE IF NOT EXISTS `EDICIONES` (
    `CodEdicion` INT NOT NULL, -- PK > 0. NOT NULL no haría falta ya que se definirá como una PK de todas formas
    `RefCurso` INT NOT NULL, -- -> CURSOS(RefCurso)
    `Fecha` DATE NOT NULL,
    `Lugar` VARCHAR(100) NOT NULL,
    `Coste` DECIMAL(7,2) NOT NULL,
    `NIF_Docente` VARCHAR(12) NOT NULL, -- -> EMPLEADOS(NIF)
    CONSTRAINT PK_CodEdicionEdiciones PRIMARY KEY (`CodEdicion`),
    CONSTRAINT FK_RefCursoEdicionesCursos FOREIGN KEY (`RefCurso`) REFERENCES `CURSOS`(`RefCurso`),
    CONSTRAINT FK_NIFDocenteEdiciones FOREIGN KEY (`NIF_Docente`) REFERENCES `EMPLEADOS`(`NIF`),
    CONSTRAINT CHK_CodEdicion CHECK (`CodEdicion` >= 0),
    CONSTRAINT CHK_RefCursoEdiciones CHECK (`RefCurso` >= 0),
    CONSTRAINT CHK_Coste CHECK (`Coste` BETWEEN 0.00 AND 99999.99))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `TELEFONOS`;
CREATE TABLE IF NOT EXISTS `TELEFONOS` (
    `NIF_Empleado` VARCHAR(12) NOT NULL, -- -> EMPLEADOS(NIF) ha de tener la misma longitud que la FK en EMPLEADOS
    `Telefono` VARCHAR(11) NOT NULL,
    CONSTRAINT PK_TelefonoNIFTelefonos PRIMARY KEY (`NIF_Empleado`, `Telefono`),
    CONSTRAINT FK_NIF_EmpleadoTelefonosEmpleados FOREIGN KEY (`NIF_Empleado`) REFERENCES `EMPLEADOS`(`NIF`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `CAPACITACIONES`;
CREATE TABLE IF NOT EXISTS `CAPACITACIONES` (
    `RefCurso` INT NOT NULL, -- -> CURSOS(RefCurso)
    `NIF_Empleado` VARCHAR(12) NOT NULL, -- -> EMPLEADOS(NIF)
    CONSTRAINT PK_RefCursoCapacitaciones PRIMARY KEY (`RefCurso`, `NIF_Empleado`),
    CONSTRAINT FK_RefCursoCapacitacionesCursos FOREIGN KEY (`RefCurso`) REFERENCES `CURSOS`(`RefCurso`),
    CONSTRAINT FK_NIF_EmpleadoCapacitacionesEmpleados FOREIGN KEY (`NIF_Empleado`) REFERENCES `EMPLEADOS`(`NIF`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `MATRICULAS`;
CREATE TABLE IF NOT EXISTS `MATRICULAS` (
    `NIF_Alumno` VARCHAR(12) NOT NULL, -- -> EMPLEADOS(NIF)
    `CodEdicion` INT NOT NULL, -- -> EDICIONES(CodEdicion)
    CONSTRAINT PK_NIF_AlumnoMatriculas PRIMARY KEY (`NIF_Alumno`, `CodEdicion`),
    CONSTRAINT FK_NIF_AlumnoMatriculasEmpleados FOREIGN KEY (`NIF_Alumno`) REFERENCES `EMPLEADOS`(`NIF`),
    -- De aquí deducimos que tanto estudiantes como profesores se agrupan en EMPLEADOS. De ahí que no se especifique de quién es el NIF en EMPLEADOS
    CONSTRAINT FK_CodEdicionMatriculasEdiciones FOREIGN KEY (`CodEdicion`) REFERENCES `EDICIONES`(`CodEdicion`))
ENGINE = InnoDB;

DROP TABLE IF EXISTS `PRERREQUISITOS`;
CREATE TABLE IF NOT EXISTS `PRERREQUISITOS` (
    `RefCursoARealizar` INT NOT NULL, -- -> CURSOS(RefCurso)
    `RefCursoARequisito` INT NOT NULL, -- -> CURSOS(RefCurso)
    `Tipo` VARCHAR(15) NOT NULL,
    CONSTRAINT PK_RefCursoARealizar PRIMARY KEY (`RefCursoARealizar`, `RefCursoARequisito`),
    CONSTRAINT FK_RefCursoARealizarPrerrequisitosCursos FOREIGN KEY (`RefCursoARealizar`) REFERENCES `CURSOS`(`RefCurso`),
    CONSTRAINT FK_RefCursoARequisitoPrerrequisitosCursos FOREIGN KEY (`RefCursoARequisito`) REFERENCES `CURSOS`(`RefCurso`))
ENGINE = InnoDB;

-- 3. En la relación CURSOS, después de RefCurso, añadir un nuevo atributo cuya descripción sea la siguiente:
-- Título | VARCHAR | max 25


ALTER TABLE CURSOS
ADD COLUMN Titulo VARCHAR(25) AFTER RefCurso;

-- 4. En la relación MATRICULAS, cambiar su identificador (MATRICULAS) por MATRICULACIONES

ALTER TABLE MATRICULAS
RENAME MATRICULACIONES;

-- 5. En la relación PRERREQUISITOS cambiar el identificador del atributo RefCursoARequisito por RefCursoRequisito

ALTER TABLE PRERREQUISITOS
CHANGE RefCursoARequisito RefCursoRequisito INT NOT NULL;

-- 6. En la relación PRERREQUISITOS añadir una restricción para que el atributo Tipo únicamente pueda tener los valores
-- ACONSEJABLE y OBLIGATORIO.

ALTER TABLE PRERREQUISITOS
MODIFY Tipo ENUM('ACONSEJABLE', 'OBLIGATORIO'); -- No comenta que ha de ser NOT NULL

-- 7. En la relación PRERREQUISITOS añadir una restricción para que un curso no pueda ser prerrequisito de él mismo

ALTER TABLE PRERREQUISITOS
ADD CONSTRAINT CHK_NoMismoCurso CHECK(RefCursoARealizar != RefCursoRequisito);

-- 8. En la relación EMPLEADOS eliminar el atributo Nacion

ALTER TABLE EMPLEADOS
DROP Nacion;

-- 9. Introducir, como mínimo, dos tuplas en cada tabla.
-- Para la tabla Cursos, debes introducir también estas tuplas:
-- INSERT INTO Cursos VALUES (1, 'GESTIÓN DE BASES DE DATOS', 100, 'GESTIÓN DE BASES DE DATOS');
-- INSERT INTO Cursos VALUES (2,'SISTEMAS OPERATIVOS',200,'IMPLANTACIÓN DE SISTEMAS OPERATIVOS');
-- INSERT INTO Cursos VALUES (3,'ADMON DE BASES DE DATOS',60,'ABD');



-- Orden para no comprometer la integridad referencial:
-- (1) Cursos, (2) Empleados, (3) Ediciones, (4) Teléfonos, (5) Capacitaciones, (6) Prerrequisitos, (7) Matriculas

INSERT INTO CURSOS VALUES
(1, 'GESTIÓN DE BASES DE DATOS', 100, 'GESTIÓN DE BASES DE DATOS'),
(2, 'SISTEMAS OPERATIVOS', 200, 'IMPLANTACIÓN DE SISTEMAS OPERATIVOS'),
(3, 'ADMIN DE BASES DE DATOS', 60, 'ABD'),
(4, 'PROGRAMACIÓN', 300, 'PROGRAMACIÓN EN PYTHON Y JAVA'),
(5, 'LENGUAJE DE MARCAS', 150, 'HTML, CSS & XML');

INSERT INTO EMPLEADOS VALUES
('856256124B', 'Pepe', 'Rodríguez', 'Gonzáles', '1990-10-05', 3000.00, 'HOMBRE', 'PRG'),
('563124853S', 'Ana', 'Castellón', 'Máximum', '1984-01-23', 6512.99, 'MUJER', 'ACM'),
('648972123M', 'Ángel', 'Félipez', NULL, NULL, 100.00, 'HOMBRE', 'BECARIO :D');

INSERT INTO EDICIONES VALUE
(101, 2, curdate(), 'CESUR', 555.00, '563124853S'),
(103, 3, curdate(), 'CESUR', 5015.53, '648972123M'),
(104, 4, curdate(), 'CESUR', 99999.99, '856256124B');

INSERT INTO TELEFONOS VALUE
('563124853S', 681534369),
('648972123M', 680458976),
('856256124B', 687452139);

INSERT INTO CAPACITACIONES VALUE
(2, '563124853S'),
(3, '648972123M'),
(4, '856256124B');

INSERT INTO PRERREQUISITOS VALUE
(1, 3, 'OBLIGATORIO'),
(4, 5, 'ACONSEJABLE');

INSERT INTO EMPLEADOS VALUES
('546369458X', 'Anabel', 'Felicia', NULL, NULL, 100, 'MUJER', 'ESTUDIANTE'),
('876154687H', 'Miguelito', 'López', NULL, NULL, 100, 'HOMBRE', 'ESTUDIANTE');
-- Un poco raro que salario se tenga que definir como NOT NULL teniendo en EMPLEADOS tanto PROFESORES como
-- ALUMNOS

INSERT INTO MATRICULACIONES VALUE
('546369458X', 104),
('876154687H', 101);

SELECT * FROM CURSOS;
SELECT * FROM EMPLEADOS;
SELECT * FROM EDICIONES;
SELECT * FROM TELEFONOS;
SELECT * FROM CAPACITACIONES;
SELECT * FROM PRERREQUISITOS;
SELECT * FROM MATRICULACIONES;
-- SELECT * FROM MATRICULAS;

-- 10. Aumentar en 10 horas la duración de los cursos en cuyo título aparece “BASES DE DATOS”







-- 11. Aumentar el sueldo en un 10% a los empleados que han impartido más de diez cursos (pueden ser de ediciones diferentes),
-- a. Utiliza GROUP BY en la tabla Ediciones para saber qué NIF_Docente ha impartido 2 o más cursos.
-- Luego aplica el UPDATE con un sub SELECT de lo anterior.









-- 12. Eliminar los cursos que no tienen ninguna edición (tiene que haber, al menos una eliminación)
-- a. Emplea NOT IN (SELECT … FROM Ediciones)








-- 13. Aumentar el sueldo en un 15% a los empleados que han impartido cursos en cuyo título aparece “BASES DE DATOS”
-- (tiene que haber al menos una actualización)
-- a. Identifica los NIF_Docente que han impartido este curso con un SELECT de dos tablas (Cursos y Ediciones) y un LIKE
-- b. Aplica UPDATE con un WHERE NIF IN (SELECT de lo anterior)








-- 14. Eliminar los cursos que en estos 10 años (WHERE Fecha >='2006-03-01' AND Fecha <= '2016-03-01') no se han
-- celebrado ninguna edición. (puede no haber ninguna eliminación)
-- a. Identifica los cursos con ediciones en esas fechas
-- b. Elimínalos con NOT IN (SELECT de lo anterior)






-- 15. Aumentar un 10% la duración del curso en que más alumnos se han matriculado. (tiene que haber al menos una actualización).
-- a. Crea una vista de la siguiente manera:
/*
CREATE VIEW V_CursoMatriculados (RefCurso, numMatriculados) AS
SELECT RefCurso, Count(*)
FROM Matriculaciones M, Ediciones E
WHERE M.CodEdicion = E.CodEdicion
GROUP BY RefCurso;
b. Utiliza MAX(numMatriculados)
*/

