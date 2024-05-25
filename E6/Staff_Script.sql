-- Staff Example --

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

SHOW warnings;

DROP SCHEMA IF EXISTS `Staff_Example`;
CREATE SCHEMA IF NOT EXISTS `Staff_Example` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE `Staff_Example`;

-- ----------------------------------------------------------------
-- Table Department
-- ----------------------------------------------------------------

DROP TABLE IF EXISTS `DEPARTMENT` ;
CREATE TABLE IF NOT EXISTS `DEPARTMENT` (
    `Department_Code` SMALLINT UNSIGNED NOT NULL,
    `Department_Name` VARCHAR(15) NOT NULL,
    `City` VARCHAR(15) NOT NULL,
    CONSTRAINT PK_DEPARTMENT PRIMARY KEY(`Department_Code`))
ENGINE = InnoDB;

-- ----------------------------------------------------------------
-- Table Staff
-- ----------------------------------------------------------------
DROP TABLE IF EXISTS `STAFF` ;
CREATE TABLE IF NOT EXISTS `STAFF` (
    `Employee_Code` SMALLINT UNSIGNED NOT NULL,
    `Name` VARCHAR(25) NOT NULL,
    `Job` VARCHAR(25) NOT NULL,
    `Salary` DECIMAL(7,2),
    `Department_Code` SMALLINT UNSIGNED,
    `Start_Date` DATE NOT NULL,
    `Superior_Officer` SMALLINT UNSIGNED NOT NULL COMMENT 'Head is him/herself',
    CONSTRAINT PK_Staff PRIMARY KEY(`Employee_Code`),
    CONSTRAINT FK_Staff FOREIGN KEY(`Superior_Officer`)
    REFERENCES Staff(`Employee_Code`),
    CONSTRAINT `FK_Codes`
    FOREIGN KEY (`Department_Code`)
    REFERENCES `DEPARTMENT` (`Department_Code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

INSERT INTO DEPARTMENT VALUES
(12, 'Direction', 'Palma'),
(05, 'Analysis', 'Barcelona'),
(08, 'Programming', 'Maó'),
(10, 'Control', 'Eivissa');

SELECT DATE_FORMAT(CURDATE(), '%d/%m/%Y') TODAY;

SELECT DATE_FORMAT(`Start_Date`, '%d %m %Y') FROM `STAFF`;

INSERT INTO STAFF
VALUES (0368, 'Almonacid', 'Head', 9700, 12, '2022-12-20', 0368); -- references itself because its the boss and the data cannot be null

INSERT INTO STAFF VALUES
(0413, 'Alonso', 'Analyst', 6000, 05, '2023-06-01', 1008),
(0545, 'Arnaiz', 'Analyst', 5600, 05, '2022-11-01', 1008),
(0552, 'Balmaseda', 'Analyst', 5500, 05, '2023-10-15', 1190),
(0663, 'Barcelo', 'Analyst', 6700, 05, '2023-01-02', 1190),
(0765, 'Bauza', 'Programmer', 3800, 08, '2023-06-01', 0413),
(0998, 'Belando', 'Programmer', 4300, 08, '2023-01-01', 0413),
(1003, 'Busuioc', 'Analyst', 6600, 05, '2023-01-12', 1190),
(1008, 'Carpio', 'Project Manager', 7800, 10, '2023-05-15', 0368),
(1087, 'Catalan', 'Programmer', 4000, 08, '2023-02-01', 1003),
(1190, 'Ciriano', 'Project Manager', 8000, 10, '2022-09-01', 0368);

SELECT * FROM STAFF;
SELECT * FROM DEPARTMENT;