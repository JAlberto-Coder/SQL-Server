USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Properties-Of-Instance.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		27-11-2019
-- Descripcion: Sentencias SELECT, con variables relevantes configuradas que tiene nuestra instancia con sus respectivas descripciones
-- =============================================
SELECT SERVERPROPERTY('MachineName') AS ComputerName
	, SERVERPROPERTY('ServerName') AS InstanceName
	, SERVERPROPERTY('Edition') AS Edition
	, CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) AS ProductVersion
	, SERVERPROPERTY('ProductLevel') AS ProductLevel;
SELECT @@DBTS AS [timestamp], 'Devuelve el ultimo valor de marca de tiempo de la base de datos actual que se ha usado'  AS Descripcion;
SELECT @@LANGID AS [Language ID];
SELECT @@LANGUAGE AS [Language Name], 'Devuelve el idioma de la sesion actual'AS Descripcion;
SELECT @@LOCK_TIMEOUT AS [Lock Timeout], 'devuelve un valor de -1 si SET LOCK_TIMEOUT aun no se ha ejecutado en la sesion actual.' AS Descripcion;
SELECT @@MAX_CONNECTIONS AS [Max Conections], 'Devuelve el numero maximo de coneiones de usuario simltaneas que se permiten en una instancia de SQL Server' AS Descripcion;
SELECT @@MAX_PRECISION AS [Max Precision], 'Devuelve el nivel de precision usado por los tipos de datos decimales y numericos segun la configuracion actual del servidor.' AS Descripcion;
SELECT @@NESTLEVEL AS [NESTLEVEL], 'Devuelve el nivel de anidamiento de la ejecucion del procedimiento almacenado actual (inicialmente 0) en el servidor local.' AS Descripcion;
SELECT @@OPTIONS AS [OPTIONS], 'Devuelve informacion acerca de las opciones SET actuales.' AS Descripcion;
SELECT @@REMSERVER AS [REMSERVER],'Devuelve el nombre del servidor de base de datos remoto de SQL Server, tal y como aparece en el registro de inicio de sesion.' AS Descripcion;
SELECT @@SERVERNAME AS [SERVERNAME],'Devuelve el nombre de la instancia conectada' AS Descripcion;
SELECT @@SERVICENAME AS [SERVICENAME],'Devuelve el nombre de la clave del Registro bajo la cual se ejecuta SQL Server.' AS Descripcion;
SELECT @@SPID AS [SPID],'Se puede usar para identificar el proceso de usuario actual en la salida de sp_who' AS Descripcion;
SELECT @@TEXTSIZE AS [TEXTSIZE],'Devuelve el valor actual de la opcion TEXTSIZE' AS Descripcion;
SELECT @@VERSION AS [VERSION],'Devuelve informacion del sistema y la compilacion para la instalacion actual de SQL Server.' AS Descripcion;
GO