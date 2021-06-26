USE [master]
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Bases-De-Datos.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		14-11-2019
-- Descripcion: Sentencias CREATE, ALTER y DROP para la Definicion de una base de datos
-- =============================================
-- 10-02-2020 | JAlberto-Coder | Se agregan sentencias para modificar las propiedades, consultar las bd y restauracion de BDs
-- =============================================
-- DEFINICIONES
--		MDF: PRIMARY DATA FILE
--		NDF: SECONDARY DATA FILES
--		LOG: LOG FILES
-- =============================================
-- PREMISAS 
--		* Para esto generaremos las carpetas necesarias en nuestro sistema de archivos de la unidad C
-- =============================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO
xp_cmdshell 'MKDIR "C:\Databases\Data"';
GO
xp_cmdshell 'MKDIR "C:\Databases\Log"';
GO
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO
-- =============================================
-- CREACION DE UNA BASE DE DATOS
-- =============================================
IF NOT EXISTS(SELECT TOP(1) 1 FROM sys.databases WHERE [name] = 'BDEjemplo') -- Validacion de existencia de BD
BEGIN
	CREATE DATABASE BDEjemplo
	ON PRIMARY
	(
		name = BDEmjemploPrimary,
		filename = 'C:\Databases\Data\BDEjemplo.mdf',
		size = 8MB, -- (Puedes poner como minimo 512KB)
		filegrowth = 25%
	)
	LOG ON
	(
		name = BDEjemploLog,
		filename = 'C:\Databases\Log\BDEjemploLog.ldf',
		size = 8MB, -- (Puedes poner como minimo 512KB)
		filegrowth = 25%
	);
END
GO
-- =============================================
-- MODIFICAR BASE DE DATOS
-- =============================================
ALTER DATABASE BDEjemplo
	SET CURSOR_CLOSE_ON_COMMIT ON; -- COMANDO PARA QUE LA BD CIERRA EL CURSOR AUTOMATICAMENTE
GO
-- =============================================
-- MODIFICAR UNA BASE DE DATOS, AGREGANDO FILEGROUP
-- =============================================
ALTER DATABASE BDEjemplo
	ADD FILEGROUP [Secondary]; -- SE AGREGA UN NUEVO GRUPO DE ALMACENAMIENTO
GO
-- =============================================
-- MODIFICAR UNA BASE DE DATOS, CREAR FILE
-- =============================================
ALTER DATABASE BDEjemplo
	ADD FILE -- ASIGNAMOS UN ARCHIVO .NDF AL GRUPO CREADO
	(
		name = BDEjemploSecondary,
		filename = 'C:\Databases\Data\BDEjemploSecondary.ndf',
		size = 8MB, -- (Puedes poner como minimo 512KB)
		filegrowth = 25%
	)
	TO FILEGROUP [Secondary];
GO
-- =============================================
-- MODIFICAR UN FILEGROUP DE UNA BASE DE DATOS
-- =============================================
ALTER DATABASE BDEjemplo
	MODIFY FILEGROUP [Secondary] DEFAULT; -- DEJAMOS QUE EL FILEGROUP PRIMARY SEA DONDE SE ALMACENE LA INFORMACION POR DEFECTO
GO
ALTER DATABASE BDEjemplo
	MODIFY FILEGROUP [PRIMARY] DEFAULT; -- DEJAMOS QUE EL FILEGROUP PRIMARY SEA DONDE SE ALMACENE LA INFORMACION POR DEFECTO
GO
-- =============================================
-- ELIMINAR UN FILE DE UNA BASE DE DATOS
-- =============================================
ALTER DATABASE BDEjemplo
	REMOVE FILE BDEjemploSecondary;
GO
-- =============================================
-- ELIMINAR UN FILEGROUP DE UNA BASE DE DATOS
-- =============================================
ALTER DATABASE BDEjemplo
	REMOVE FILEGROUP [Secondary];
GO
-- =============================================
-- MODIFICIAR LA BD PARA CERRAR CUALQUIER CURSOR AUTOMATICAMENTE
-- =============================================
ALTER DATABASE BDEjemplo
	SET AUTO_CREATE_STATISTICS OFF;
GO
-- =============================================
-- MODIFICIAR PARA ACTIVAR LA PROPIEDAD IsAutoShrink
-- =============================================
ALTER DATABASE BDEjemplo
	SET AUTO_SHRINK ON WITH NO_WAIT;
GO
-- =============================================
-- PROPIEDADES EN UNA BASE DE DATOS
--		AUTO_CLOSE
--		AUTO_CREATE_STATISTCS
--		AUTO_SHRINK
--		AUTO_UPDATE_STATISTICS
--		CURSORES
--		CORSOR_CLOSE_ON_COMMIT
-- =============================================
-- CONSULTAR PROPIEDADES (Solo se mostraran algunas)
-- =============================================
SELECT DATABASEPROPERTYEX('BDEjemplo', 'IsAutoCreateStatistics') AS Estadisticas
SELECT DATABASEPROPERTYEX('BDEjemplo','Collation') AS Collation;
SELECT DATABASEPROPERTYEX('BDEjemplo','ComparisonStyle') AS ComparisonStyle;
SELECT DATABASEPROPERTYEX('BDEjemplo','Edition') AS Edition;
SELECT DATABASEPROPERTYEX('BDEjemplo','IsAutoShrink') AS ReducirElEspacioNoUtilizadoEnBD;
SELECT DATABASEPROPERTYEX('BDEjemplo','Version') AS [Version];
-- =============================================
-- CONSULTAR INFORMACION DE LAS BD CREADAS
-- =============================================
EXEC sp_helpdb 'BDEjemplo';
GO
-- =============================================
-- REDUCIR EL TAMANIO DE LOS ARCHIVOS DE BASE DE DATOS
-- =============================================
DBCC SHRINKDATABASE('BDEjemplo', 10);		-- 10 Es el porcentaje de espacio libre que quedara
GO

USE BDEjemplo
GO

DBCC SHRINKFILE('BDEmjemploPrimary', 2);	-- Recude a 2MB el archivo de datos
GO
-- =============================================
-- VINCULAR UN ARCHIVO DE BASE DE DATOS
-- =============================================
USE master
GO
EXEC sp_attach_db 'BDEjemplo'
	, 'C:\BDEjemplo.mdf'
	, 'C:\BDEjemploLog.ldf'
	, 'C:\BDEjemploSecondary.ndf'; -- Es necesario contar con todos los archivos de la base de datos y estos deben de encontrarse en la nueva ubicacion
-- =============================================
-- CREACIONES INSTANTANEAS - SNAPSHOT
-- =============================================
EXEC sp_helpdb BDEjemplo;
GO
CREATE DATABASE DBEjemplo_20200210
ON
(
	name = BDEmjemploPrimary,
	filename = 'C:\Databases\Data\BDEjemplo_20200210.ss'
),
(
	name = BDEjemploSecondary,
	filename = 'C:\Databases\Data\BDEjemploSecondary_20200210.SS'
)
AS SNAPSHOT OF BDEjemplo;
GO
-- =============================================
-- RESTAURANDO BASE DE DATOS A PARTIR DE UN SNAPSHOT
-- =============================================
USE master;
GO
RESTORE DATABASE BDEjemplo 
FROM DATABASE_SNAPSHOT = 'DBEjemplo_20200210';
GO
-- =============================================
-- ELIMINAR UNA BASE DE DATOS
-- =============================================
USE [master];
GO
DROP DATABASE BDEjemplo; -- RECUERDA QUE ES UN COMANDO MUY RIESGOSO, DE PREFERENCIA SI ELIMINAS UNA BD REALIZA UN RESPALDO ANTES DE HACERLO
GO