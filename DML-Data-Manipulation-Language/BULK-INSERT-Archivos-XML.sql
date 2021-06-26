USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		BULK-INSERT-Archivos-XML.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-11-2019
-- Descripcion: Sentencia BULK INSERT de ejemplo, cargaremos un archivo con un bulk inserta a una tabla
-- =============================================
-- Sentencias para crear un archivo en nuestra unidad C
-- =============================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO
xp_cmdshell 'IF NOT EXIST "C:\Repositorio" ( MKDIR "C:\Repositorio" )';
PRINT 'CARPETA DE EJEMPLO CREADA';
GO
xp_cmdshell 'ECHO ^<Databases^>^<Database name = "SQL Server"^>^</Database^>^<Database name = "Oracle Database"^>^</Database^>^<Database name = "MariaDB"^>^</Database^>^<Database name = "SQLite"^>^</Database^>^</Databases^> > "C:\Repositorio\Archivo1.xml"';
PRINT 'ARCHIVO DE EJEMPLO CREADO';
GO
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO
-- =============================================
-- DDL para creacion de tabla ArchivosXML
-- =============================================
IF OBJECT_ID('ArchivosXML' ,'U') IS NULL
BEGIN
	CREATE TABLE ArchivosXML
	(
		idArchivoXML INT IDENTITY(1,1) NOT NULL,
		ArchivoXML XML NOT NULL,
		CONSTRAINT PK_ArchivosXML_idArchivoXML PRIMARY KEY(idArchivoXML)
	);
	PRINT 'TABLA ArchivosXML CREADA';
END;
GO
-- =============================================
-- DML para insertar el archivo en la tabla
-- =============================================
INSERT INTO ArchivosXML(ArchivoXML) 
SELECT * FROM OPENROWSET( BULK 'C:\Repositorio\Archivo1.xml', SINGLE_BLOB) AS ArchivoXML;
GO
PRINT 'REGISTRO INSERTADO';
GO
-- =============================================
-- DQL para verificar que el archivo se haya cargado
-- =============================================
SELECT *
FROM ArchivosXML WITH(NOLOCK);
PRINT 'VERFIFICACION DE DATOS';
GO
PRINT 'FIN';
GO