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

SELECT * FROM CURSOS;
SELECT * FROM EMPLEADOS;
SELECT * FROM EDICIONES;
SELECT * FROM TELEFONOS;
SELECT * FROM CAPACITACIONES;
SELECT * FROM PRERREQUISITOS;
SELECT * FROM MATRICULACIONES;
-- SELECT * FROM MATRICULAS;

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

-- Hacemos que uno de los empleados haya impartido 10 cursos o más

INSERT INTO EDICIONES VALUES
(105, 2, '1990-01-01', 'CESUR', 666, '563124853S'),
(106, 2, '1992-05-02', 'CESUR', 5864, '563124853S'),
(107, 2, '1999-01-05', 'CESUR', 6663, '563124853S'),
(108, 2, '1998-11-12', 'CESUR', 6544, '563124853S'),
(109, 2, '1997-12-04', 'CESUR', 3213, '563124853S'),
(110, 4, '1996-11-12', 'CESUR', 545, '563124853S'),
(111, 2, '1995-05-24', 'CESUR', 2342, '563124853S'),
(112, 2, '1994-06-25', 'CESUR', 212, '563124853S'),
(113, 2, '1993-07-15', 'CESUR', 111, '563124853S'),
(114, 2, '1992-08-14', 'CESUR', 222, '563124853S'),
(115, 3, '1991-09-12', 'CESUR', 414, '563124853S');

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


-- 10. Aumentar en 10 horas la duración de los cursos en cuyo título aparece “BASES DE DATOS”
-- 100 / 60 -> 110 / 70

UPDATE CURSOS
SET Duracion = Duracion + 10
WHERE Titulo LIKE '%BASES DE DATOS';


-- 11. Aumentar el sueldo en un 10% a los empleados que han impartido más de diez cursos (pueden ser de ediciones diferentes),
-- a. Utiliza GROUP BY en la tabla Ediciones para saber qué NIF_Docente ha impartido 2 o más cursos.
-- Luego aplica el UPDATE con un sub SELECT de lo anterior.

SELECT NIF_Docente
FROM EDICIONES
GROUP BY NIF_Docente
HAVING count(RefCurso) > 10;

UPDATE EMPLEADOS
SET Salario = Salario * 1.1
WHERE NIF IN (
    SELECT NIF_Docente
    FROM EDICIONES
    GROUP BY NIF_Docente
    HAVING count(RefCurso) > 10
    );

-- 12. Eliminar los cursos que no tienen ninguna edición (tiene que haber, al menos una eliminación)
-- a. Emplea NOT IN (SELECT … FROM Ediciones)

SELECT * FROM CURSOS;
SELECT EDICIONES.RefCurso FROM EDICIONES;

SELECT RefCurso
FROM CURSOS
WHERE RefCurso NOT IN (
    SELECT RefCurso
    FROM EDICIONES
    ); -- 1 y 5

/*
Vemos que el Curso 1, uno de los cursos que no se imparten, es un prerrequisito obligatorio en la relación
PRERREQUISITOS. Por tanto por la integridad referencial nos da un error por FK.
Pero esto realmente no nos influye en nada realmente por ahora. El curso luego se podría volver a añadir cuando
se imparta. No hace falta eliminar la tupla de PRERREQUISITOS. Pero algo debemos hacer para tratar con la integridad
referencial.

Hay varias formas de aplacar este problema. Entre ellas:

1. Hacer un ALTER TABLE a PRERREQUISITOS, DROP a la FK que nos está dando problemas y luego otro
ALTER TABLE para modificar la FK de forma que haga un ON DELETE CASCADE
2. Hacer un SET 0 y 1 a la FOREIGN KEY. Esto, a diferencia de la forma previa, desactivará TODAS las FK
de la base de datos; no sólo la de PRERREQUISITOS
3. Borrar la tupla conflictiva de PRERREQUISITOS

Optaremos por la opción 1. La opción 2 es un overkill. No necesitamos realmente desactivar TODAS las FK
para hacer un único DELETE. La opción 3 en este caso a lo mejor sí es posible, pero con mayores cantidades
de datos es muy impráctico. También hemos de estar 100% seguros de cuál es la tupla conflictiva. Además por lo general
en una base de datos nunca se recomienda eliminar datos

La opción 1 es la más válida y correcta en este caso. Para añadir una capa extra de seguridad, envolveremos las Querys
en una transacción. Esto nos asegurará que todas las Querys dentro de la misma se ejecuten correctamente o no se ejecute
ninguna. Además es posible hacerle un ROLLBACK.

*/

START TRANSACTION;

    ALTER TABLE PRERREQUISITOS
    DROP FOREIGN KEY FK_RefCursoARequisitoPrerrequisitosCursos; -- Desactivamos la FK primero

    ALTER TABLE PRERREQUISITOS
    ADD CONSTRAINT FK_ONDELETE_RefCursoARequisitoPrerrequisitosCursos
    FOREIGN KEY (RefCursoARealizar)
    REFERENCES CURSOS(RefCurso)
    ON DELETE CASCADE; -- Ahora si se hace un DELETE que hace referencia aquí, arrastra consigo la tupla

    DELETE
    FROM CURSOS
    WHERE RefCurso NOT IN (
        SELECT RefCurso
        FROM EDICIONES
        ); -- el DELETE en sí

COMMIT;

-- 13. Aumentar el sueldo en un 15% a los empleados que han impartido cursos en cuyo título aparece “BASES DE DATOS”
-- (tiene que haber al menos una actualización)
-- a. Identifica los NIF_Docente que han impartido este curso con un SELECT de dos tablas (Cursos y Ediciones) y un LIKE
-- b. Aplica UPDATE con un WHERE NIF IN (SELECT de lo anterior)

SELECT NIF, Salario
FROM EMPLEADOS
WHERE NIF IN (
    SELECT NIF_Docente
    FROM EDICIONES
    WHERE RefCurso = (
        SELECT RefCurso
        FROM CURSOS
        WHERE Titulo LIKE '%BASES DE DATOS'
        )
    ); -- 100 y 7162.29 antes

-- Seguimos el camino que podemos ver claramente en el diagrama generado por MySQL Workbench:
    -- Nos interesa el NIF de la tabla Empleados. Pues es donde está el salario y de donde haremos el UPDATE.
    -- A partir de aquí vemos cómo podemos enlazar las condiciones que nos piden: que haya impartido cursos con título
    -- 'bases de datos'. Para poder llegar a los títulos, tendremos que terminar en la relación Cursos. Y la forma de
    -- conectar EMPLEADOS con CURSOS es a través de Ediciones

-- Tengo que bajarle el salario a uno de los NIF porqué sobrepasa el límite aaaaaaa

UPDATE EMPLEADOS
SET Salario = Salario - 2000
WHERE NIF = '563124853S'; -- 5164 ahora no debería dar out of range al modificar otra vez el salario abajo

UPDATE EMPLEADOS
SET Salario = Salario * 1.5
WHERE NIF IN (
    SELECT NIF_Docente
    FROM EDICIONES
    WHERE RefCurso IN (
        SELECT RefCurso
        FROM CURSOS
        WHERE Titulo LIKE '%BASES DE DATOS'
    )
);

-- 14. Eliminar los cursos que en estos 10 años (WHERE Fecha >='2006-03-01' AND Fecha <= '2016-03-01') no se han
-- celebrado ninguna edición. (puede no haber ninguna eliminación)
-- a. Identifica los cursos con ediciones en esas fechas
-- b. Elimínalos con NOT IN (SELECT de lo anterior)

SELECT DISTINCT RefCurso -- El DISTINCT a lo mejor no hace falta? Porque lo que hace es evitar repeticiones
FROM EDICIONES
WHERE Fecha >= '2006-03-01' AND FECHA <= '2016-03-01';

-- El DELETE nos da error por integridad referencial de la relación CAPACITACIONES. Podríamos volver a aplicar
-- el método del ALTER TABLE de antes, o bien hacerlo de otra forma. Una forma más "bruta", que es setteando la FK
-- a 0, es decir, desactivándola de todas las relaciones, y luego recuperándola a 1 (activándola)

SET FOREIGN_KEY_CHECKS = 0;

DELETE
FROM CURSOS
WHERE RefCurso NOT IN (
    SELECT RefCurso
    FROM EDICIONES
    WHERE Fecha >= '2006-03-01' AND FECHA <= '2016-03-01'
    );

SET FOREIGN_KEY_CHECKS = 1;

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

-- Primero nos aseguramos de que haya varios matriculados en uno de los cursos

INSERT INTO EMPLEADOS VALUES
('875364234G', 'Joselito', 'Feix', NULL, NULL, 100, 'HOMBRE', 'ESTUDIANTE'),
('457523510P', 'Babidi', 'Lapadi', NULL, NULL, 100, 'HOMBRE', 'ESTUDIANTE');


INSERT INTO MATRICULACIONES VALUE
('875364234G', 104),
('875364234G', 101),
('457523510P', 104);


CREATE VIEW V_CursoMatriculados (RefCurso, numMatriculados) AS
SELECT RefCurso, Count(*)
FROM Matriculaciones M, Ediciones E
WHERE M.CodEdicion = E.CodEdicion
GROUP BY RefCurso; -- 4 PROGRA 300h

UPDATE CURSOS
SET Duracion = Duracion * 1.1
WHERE RefCurso IN (
    SELECT RefCurso
    FROM V_CursoMatriculados
    WHERE numMatriculados = (
        SELECT max(numMatriculados)
        FROM V_CursoMatriculados
        )
    );

DROP VIEW V_CursoMatriculados;