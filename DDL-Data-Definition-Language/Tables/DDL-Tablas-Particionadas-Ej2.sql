USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Tablas-Particionadas-Ej2
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		20-11-2019
-- Descripcion: Sentencias CREATE para la definicion de tablas particionadas en SQL Server.
-- Crearemos una tabla particionada con un campo tipo entero, la tabla se llama Productos
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
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperProductos1;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperProductos1, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperProductos2;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperProductos2, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperProductos3;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperProductos3, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperProductos4;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperProductos4, YA EXISTE';
END CATCH
GO
-- ASIGNAMOS UN ARCHIVO A CADA GRUPO CREADO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperProductos1, filename = 'C:\Databases\Data\DeveloperProductos1.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperProductos1;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos1, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperProductos2, filename = 'C:\Databases\Data\DeveloperProductos2.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperProductos2;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos2, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperProductos3, filename = 'C:\Databases\Data\DeveloperProductos3.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperProductos3;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos3, YA EXISTE';
END CATCH
GO
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperProductos4, filename = 'C:\Databases\Data\DeveloperProductos4.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperProductos4;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperProductos4, YA EXISTE';
END CATCH
GO
-- =============================================
-- 2. Crear una funcion de particion que asigna las filas de una tabla o un índice a particiones segun los valores de una columna especificada
-- CREAMOS LA FUNCION QUE ASIGNARA LA INFORMACION PARA CADA ARCHIVO
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'ParticionProductosId')
BEGIN
	CREATE PARTITION FUNCTION ParticionProductosId(BIGINT)
	AS RANGE LEFT
	FOR VALUES(10, 100, 1000);
	-- Lo que significa:
	-- ID <= 10
	-- ID > 10 <= 100
	-- ID > 100  <= 1000
	-- ID > 1000
END
-- =============================================
-- 3. Crear un esquema de particion que asigna las particiones de una tabla o índice con particiones a los nuevos grupos de archivos.
-- CREAMOS EL ESQUEMA DE LA PARTICION PARA QUE EL REPARTA LOS DATOS
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'EsquemaProductosId')
BEGIN
	CREATE PARTITION SCHEME EsquemaProductosId
	AS PARTITION ParticionProductosId
	TO(GrupoDeveloperProductos1, GrupoDeveloperProductos2, GrupoDeveloperProductos3, GrupoDeveloperProductos4);
END
GO
-- =============================================
-- 4. Crear o modificar una tabla o un indice y especificar el esquema de particion como ubicacion de almacenamiento.
-- CREAMOS LA TABLA PARTICIONADA
-- =============================================
IF (OBJECT_ID('Productos', 'U') IS NOT NULL)
	DROP TABLE Productos;
GO
CREATE TABLE Productos
(
	idProducto BIGINT PRIMARY KEY NOT NULL,
	Producto VARCHAR(100),
	Precio DECIMAL(22,6),
	UnidadDeMedida VARCHAR(50)--,
	--CONSTRAINT PK_Productos_idProducto PRIMARY KEY(idProducto)
)
ON EsquemaProductosId(idProducto);
GO
-- =============================================
-- INSERTAMOS UNOS REGISTROS
-- =============================================
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(1, 'Churros azucarados', 7.00, 'Pieza');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(9, 'Chocolate clasico', 25.00, 'Pieza');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(10, 'Sandwich de helado', 20.00, 'Pieza');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(67, 'Torta de tamal', 20.00, 'Pieza');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(1002, 'Jugo antigripal', 30.00, 'Litro');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(2001, 'Pastel de chocolate', 300.00, 'Pieza');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(254, 'Malteada de galleta', 35.00, 'Pieza');
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(1011111, 'Atole varios sabores', 19.00, 'Litro');
GO
-- =============================================
-- CONSULTA PARA VER EN QUE FILEGROUP SE ALMACENA CADA REGISTRO
-- =============================================
SELECT *
	, $PARTITION.ParticionProductosId(idProducto) AS NumeroDeParticion
FROM Productos;
GO
-- =============================================
-- MODIFICACION DE PARTICIONAMIENTO
-- =============================================
BEGIN TRY
	ALTER DATABASE Developer ADD FILEGROUP GrupoDeveloperProductos5;
END TRY
BEGIN CATCH
	PRINT 'EL FILEGROUP GrupoDeveloperProductos5 YA EXISTE';
END CATCH
BEGIN TRY
	ALTER DATABASE Developer
		ADD FILE (name = DeveloperProductos5, filename = 'C:\Databases\Data\DeveloperProductos5.ndf', SIZE = 15MB, FILEGROWTH = 25%)
		TO FILEGROUP GrupoDeveloperProductos5;
END TRY
BEGIN CATCH
	PRINT 'EL FILENAME DeveloperPersonas4, YA EXISTE';
END CATCH
GO
-- =============================================
-- MODIFICAR SCHEME AGREGANDO EL FILESHARE
-- =============================================
ALTER PARTITION SCHEME EsquemaProductosId NEXT USED GrupoDeveloperProductos5;
GO
-- =============================================
-- MODIFICAR PATITION FUNCTION
-- =============================================
BEGIN TRY
	ALTER PARTITION FUNCTION ParticionProductosId() SPLIT RANGE(10000);
END TRY
BEGIN CATCH
	PRINT 'LA PARTICION ParticionProductosId, ya contiene este valor';
END CATCH 
GO
-- =============================================
-- INSERTAMOS REGISTRO
-- =============================================
INSERT INTO Productos(idProducto, Producto, Precio, UnidadDeMedida) VALUES(10001, 'Banquete cena de fin se anio', 10310.00, 'Paquete');
GO
-- =============================================
-- CONSULTA PARA VER EN QUE FILEGROUP SE ALMACENA CADA REGISTRO
-- =============================================
SELECT *
	, $PARTITION.ParticionProductosId(idProducto) AS NumeroDeParticion
FROM Productos;
GO
-- =============================================
-- DROP PARTICIONAMIENTO
-- NOTA: Recuerda que para la eliminacion de esyos objetos no deben de tener dependencias, si se elimnan la secuencia seria la siguiente
-- =============================================
DROP TABLE Productos;
DROP PARTITION SCHEME EsquemaProductosId;
DROP PARTITION FUNCTION ParticionProductosId;
GO
-- =============================================
-- Si de dese eliminar los FILEs y FILESGROUPS, seria de la manera siguiente, igualmente no debe de haber dependencias
-- =============================================
ALTER DATABASE Developer REMOVE FILE DeveloperProductos1;
ALTER DATABASE Developer REMOVE FILE DeveloperProductos2;
ALTER DATABASE Developer REMOVE FILE DeveloperProductos3;
ALTER DATABASE Developer REMOVE FILE DeveloperProductos4;
ALTER DATABASE Developer REMOVE FILE DeveloperProductos5;
GO
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperProductos1;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperProductos2;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperProductos3;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperProductos4;
ALTER DATABASE Developer REMOVE FILEGROUP GrupoDeveloperProductos5;
GO