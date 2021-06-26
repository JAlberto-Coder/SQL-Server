USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Tablas-Particionadas-Ej1
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		20-11-2019
-- Descripcion: Sentencias CREATE para la definicion de tablas particionadas en SQL Server.
-- En el ejemplo se particiona una tabla llamada Personas en 3 filegroups por el campo Apellidos un campo tipo varchar
-- =============================================
-- DEFINICION: Las tablas particionadas son tablas que estan separadas logicamente en diferentes grupos de archivos, la particion se define en una columna.
-- La columna puede ser de cualquier tipo de datos excepto text, ntext, image, xml, timestamp, varchar(max) , nvarchar(max) , varbinary(max).
-- Esto ayuda a que tablas que son demasiado grandes sean mas escalables y faciles de administrar.
-- =============================================
-- PREMISAS:
--		* Para la creacion de los archivos necesitaremos crear unas carpetas en nuestra unidad C
--		* La creacion de las tablas particionadas consiste en 4 pasos, cada paso estara enumerado
-- =============================================
-- CREACION DE CARPETAS EN NUESTRA UNIDAD C
-- =============================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO
xp_cmdshell 'MKDIR "C:\Databases\Data"';
GO
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO
-- =============================================
-- 1. Crear un grupo o grupos de archivos y los archivos correspondientes que contendran las particiones especificadas por el esquema de particion
-- CREAMOS 3 GRUPOS
-- =============================================
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloper1;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloper1, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloper2;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloper2, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloper3;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloper3, YA EXISTE';
END CATCH
GO
-- ASIGNAMOS UN ARCHIVO A CADA GRUPO CREADO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperPersonas1, filename = 'C:\Databases\Data\DeveloperPersonas1.ndf', SIZE = 15MB, FILEGROWTH = 25%) 
		TO FILEGROUP GrupoDeveloper1;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperPersonas1, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperPersonas2, filename = 'C:\Databases\Data\DeveloperPersonas2.ndf', SIZE = 15MB, FILEGROWTH = 25%) 
		TO FILEGROUP GrupoDeveloper2;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperPersonas2, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperPersonas3, filename = 'C:\Databases\Data\DeveloperPersonas3.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloper3;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperPersonas3, YA EXISTE';
END CATCH
GO
-- =============================================
-- 2. Crear una funcion de particion que asigna las filas de una tabla o un índice a particiones segun los valores de una columna especificada
-- CREAMOS LA FUNCION QUE ASIGNARA LA INFORMACION PARA CADA ARCHIVO
-- =============================================
IF NOT EXISTS (SELECT TOP(1) 1 FROM sys.partition_functions WHERE name = 'ParticionEmpleados')  
BEGIN
	CREATE PARTITION FUNCTION ParticionEmpleados(VARCHAR(150))
	AS RANGE RIGHT
	FOR VALUES ('I','Q');
END
GO
-- =============================================
-- 3. Crear un esquema de particion que asigna las particiones de una tabla o índice con particiones a los nuevos grupos de archivos.
-- CREAMOS EL ESQUEMA DE LA PARTICION PARA QUE EL REPARTA LOS DATOS
-- =============================================
IF NOT EXISTS (SELECT TOP(1) 1 FROM sys.partition_schemes WHERE name = 'EsquemaEmpleadosApellidos')
BEGIN
	CREATE PARTITION SCHEME EsquemaEmpleadosApellidos
	AS PARTITION ParticionEmpleados
	TO(GrupoParticion1, GrupoParticion2, GrupoParticion3);
END
GO
-- =============================================
-- 4. Crear o modificar una tabla o un indice y especificar el esquema de particion como ubicacion de almacenamiento.
-- CREAMOS LA TABLA PARTICIONADA
-- =============================================
IF (OBJECT_ID('Personas', 'U') IS NOT NULL)
	DROP TABLE Personas;
GO
CREATE TABLE Personas
(
	idPersona INT IDENTITY(1,1) NOT NULL,
	Nombres VARCHAR(150),
	Apellidos VARCHAR(150),
	CONSTRAINT PK_Personas_idPersona PRIMARY KEY NONCLUSTERED (idPersona, Apellidos) 
)
ON EsquemaEmpleadosApellidos(Apellidos); -- Se indica el esquema de particion
GO
-- =============================================
-- INSERTAMOS UNOS REGISTROS
-- =============================================
INSERT INTO Personas(Nombres, Apellidos) VALUES('Steve', 'Jobs');
INSERT INTO Personas(Nombres, Apellidos) VALUES('Hermann', 'Hesse');
INSERT INTO Personas(Nombres, Apellidos) VALUES('Steve', 'Prefontaine');
INSERT INTO Personas(Nombres, Apellidos) VALUES('Jorge', 'Ramirez');
INSERT INTO Personas(Nombres, Apellidos) VALUES('Andaba', 'Xola');
GO
-- =============================================
-- CONSULTA PARA VER EN QUE FILEGROUP SE ALMACENA CADA REGISTRO
-- =============================================
SELECT *
	, $PARTITION.ParticionEmpleados(Apellidos) AS NumeroDeParticion
FROM Personas WITH(NOLOCK);
GO
-- =============================================
-- MODIFICACION DE PARTICIONAMIENTO
-- =============================================
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloper4;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloper4 YA EXISTE';
END CATCH
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperPersonas4, filename = 'C:\Databases\Data\DeveloperPersonas4.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloper4;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperPersonas4, YA EXISTE';
END CATCH
GO
-- =============================================
-- MODIFICAR SCHEME AGREGANDO EL FILESHARE
-- =============================================
ALTER PARTITION SCHEME EsquemaEmpleadosApellidos NEXT USED GrupoDeveloper4;
GO
-- =============================================
-- MODIFICAR PATITION FUNCTION
-- =============================================
BEGIN TRY
	ALTER PARTITION FUNCTION ParticionEmpleados() SPLIT RANGE('X');
END TRY
BEGIN CATCH
	PRINT 'LA PARTICION ParticionEmpleados, ya contiene este valor';
END CATCH 
GO
-- =============================================
-- INSERTAMOS REGISTRO
-- =============================================
INSERT INTO Personas(Nombres, Apellidos) VALUES('Vanesa', 'Zamora');
GO
-- =============================================
-- CONSULTA PARA VER EN QUE FILEGROUP SE ALMACENA CADA REGISTRO
-- =============================================
SELECT *
	, $PARTITION.ParticionEmpleados(Apellidos) AS NumeroDeParticion
FROM Personas;
GO
-- =============================================
-- DROP PARTICIONAMIENTO
-- NOTA: Recuerda que para la eliminacion de esyos objetos no deben de tener dependencias, si se elimnan la secuencia seria la siguiente
-- =============================================
DROP TABLE Personas;
DROP PARTITION SCHEME EsquemaEmpleadosApellidos;
DROP PARTITION FUNCTION ParticionEmpleados;
GO
-- =============================================
-- Si de dese eliminar los FILEs y FILESGROUPS, seria de la manera siguiente, igualmente no debe de haber dependencias
-- =============================================
ALTER DATABASE Developer REMOVE FILE DeveloperPersonas1;
ALTER DATABASE Developer REMOVE FILE DeveloperPersonas2;
ALTER DATABASE Developer REMOVE FILE DeveloperPersonas3;
ALTER DATABASE Developer REMOVE FILE DeveloperPersonas4;
GO
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloper1;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloper2;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloper3;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloper4;
GO