USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Tablas-Particionadas-Ej3
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		20-11-2019
-- Descripcion: Sentencias CREATE para la definicion de tablas particionadas en SQL Server.
-- Crearemos una tabla particionada con un campo datetime, la tabla se llama Ordenes
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
-- CREAMOS 4 GRUPOS
-- =============================================
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_01;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_01, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_02;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_02, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_03;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_03, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_04;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_04, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_05;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_05, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_06;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_06, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_07;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_07, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_08;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_08, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_09;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_09, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_10;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_10, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_11;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_11, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2019_12;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2019_12, YA EXISTE';
END CATCH
GO
-- ASIGNAMOS UN ARCHIVO A CADA GRUPO CREADO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_01, filename = 'C:\Databases\Data\DeveloperOrdenes2019_01.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_01;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_01, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_02, filename = 'C:\Databases\Data\DeveloperOrdenes2019_02.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_02;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_02, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_03, filename = 'C:\Databases\Data\DeveloperOrdenes2019_03.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_03;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_03, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_04, filename = 'C:\Databases\Data\DeveloperOrdenes2019_04.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_04;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_04, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_05, filename = 'C:\Databases\Data\DeveloperOrdenes2019_05.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_05;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_05, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_06, filename = 'C:\Databases\Data\DeveloperOrdenes2019_06.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_06;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_06, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_07, filename = 'C:\Databases\Data\DeveloperOrdenes2019_07.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_07;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_07, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_08, filename = 'C:\Databases\Data\DeveloperOrdenes2019_08.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_08;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_08, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_09, filename = 'C:\Databases\Data\DeveloperOrdenes2019_09.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_09;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_09, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_10, filename = 'C:\Databases\Data\DeveloperOrdenes2019_10.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_10;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_10, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_11, filename = 'C:\Databases\Data\DeveloperOrdenes2019_11.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_11;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_11, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2019_12, filename = 'C:\Databases\Data\DeveloperOrdenes2019_12.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2019_12;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2019_12, YA EXISTE';
END CATCH
GO
-- =============================================
-- 2. Crear una funcion de particion que asigna las filas de una tabla o un índice a particiones segun los valores de una columna especificada
-- CREAMOS LA FUNCION QUE ASIGNARA LA INFORMACION PARA CADA ARCHIVO
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'ParticionOrdenesFecha')
BEGIN
	CREATE PARTITION FUNCTION ParticionOrdenesFecha(DATETIME)
	AS RANGE RIGHT
	FOR VALUES
		(
			'20190201', '20190301', '20190401',
            '20190501', '20190601', '20190701', '20190801',
            '20190901', '20191001', '20191101', '20191201'
		);
END
-- =============================================
-- 3. Crear un esquema de particion que asigna las particiones de una tabla o índice con particiones a los nuevos grupos de archivos.
-- CREAMOS EL ESQUEMA DE LA PARTICION PARA QUE EL REPARTA LOS DATOS
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'EsquemaOrdenesFecha')
BEGIN
	CREATE PARTITION SCHEME EsquemaOrdenesFecha
	AS PARTITION ParticionOrdenesFecha
	TO
	(
		GrupoDeveloperOrdenes2019_01, GrupoDeveloperOrdenes2019_02, GrupoDeveloperOrdenes2019_03, GrupoDeveloperOrdenes2019_04, GrupoDeveloperOrdenes2019_05, GrupoDeveloperOrdenes2019_06,
		GrupoDeveloperOrdenes2019_07, GrupoDeveloperOrdenes2019_08, GrupoDeveloperOrdenes2019_09, GrupoDeveloperOrdenes2019_10, GrupoDeveloperOrdenes2019_11, GrupoDeveloperOrdenes2019_12
	);
END
GO
-- =============================================
-- 4. Crear o modificar una tabla o un indice y especificar el esquema de particion como ubicacion de almacenamiento.
-- CREAMOS LA TABLA PARTICIONADA
-- =============================================
IF (OBJECT_ID('Ordenes', 'U') IS NOT NULL)
	DROP TABLE Ordenes;
GO
CREATE TABLE Ordenes
(
	idOrden BIGINT IDENTITY(1,1) NOT NULL,
	Cliente VARCHAR(150),
	Descripcion VARCHAR(100),
	UnidadDeMedida VARCHAR(50),
	Importe DECIMAL(22,6),
	FechaOrden DATETIME NOT NULL--,
	--constraint UK_Ordenes_idOrden UNIQUE(idOrden)
)
ON EsquemaOrdenesFecha(FechaOrden);
GO
-- =============================================
-- INSERTAMOS UNOS REGISTROS
-- =============================================
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-01-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-01-01 17:38:10.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-02-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-03-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-04-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-05-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-06-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-07-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-08-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-09-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-10-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-11-28 17:04:13.030');
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2019-12-28 17:04:13.030');
GO
-- =============================================
-- CONSULTA PARA VER EN QUE FILEGROUP SE ALMACENA CADA REGISTRO
-- =============================================
SELECT *
	, $PARTITION.ParticionOrdenesFecha(FechaOrden) AS NumeroDeParticion
FROM Ordenes;
GO
-- =============================================
-- MODIFICACION DE PARTICIONAMIENTO
-- =============================================
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperOrdenes2020_01;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperOrdenes2020_01 YA EXISTE';
END CATCH
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperOrdenes2020_01, filename = 'C:\Databases\Data\DeveloperOrdenes2020_01.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperOrdenes2020_01;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperOrdenes2020_01, YA EXISTE';
END CATCH
GO
-- =============================================
-- MODIFICAR SCHEME AGREGANDO EL FILESHARE
-- =============================================
ALTER PARTITION SCHEME EsquemaOrdenesFecha NEXT USED GrupoDeveloperOrdenes2020_01;
GO
-- =============================================
-- MODIFICAR PATITION FUNCTION
-- =============================================
BEGIN TRY
	ALTER PARTITION FUNCTION ParticionOrdenesFecha() SPLIT RANGE('20200101');
END TRY
BEGIN CATCH
	PRINT 'LA PARTICION ParticionOrdenesFecha, ya contiene este valor';
END CATCH 
GO
-- =============================================
-- INSERTAMOS REGISTRO
-- =============================================
INSERT INTO Ordenes(Cliente, Descripcion, UnidadDeMedida, Importe, FechaOrden) VALUES('Columpios para Volar', 'Cadena Fuerza Total', 'Pieza', 1500.00, '2020-01-28 17:04:13.030');
GO
-- =============================================
-- CONSULTA PARA VER EN QUE FILEGROUP SE ALMACENA CADA REGISTRO
-- =============================================
SELECT *
	, $PARTITION.ParticionOrdenesFecha(FechaOrden) AS NumeroDeParticion
FROM Ordenes;
GO
-- =============================================
-- DROP PARTICIONAMIENTO
-- NOTA: Recuerda que para la eliminacion de esyos objetos no deben de tener dependencias, si se elimnan la secuencia seria la siguiente
-- =============================================
DROP TABLE Ordenes;
DROP PARTITION SCHEME EsquemaOrdenesFecha;
DROP PARTITION FUNCTION ParticionOrdenesFecha;
GO
-- =============================================
-- Si de dese eliminar los FILEs y FILESGROUPS, seria de la manera siguiente, igualmente no debe de haber dependencias
-- =============================================
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_01;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_02;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_03;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_04;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_05;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_06;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_07;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_08;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_09;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_10;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_11;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2019_12;
ALTER DATABASE Developer REMOVE FILE DeveloperOrdenes2020_01;
GO
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_01;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_02;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_03;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_04;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_05;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_06;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_07;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_08;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_09;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_10;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_11;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2019_12;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperOrdenes2020_01;
GO