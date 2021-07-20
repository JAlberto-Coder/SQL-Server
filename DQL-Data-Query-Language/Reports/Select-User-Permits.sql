USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-User-Permits.sql
-- Referencia:	https://sqlrd.blogspot.com/2015/04/scripts-para-obtener-la-informacion-de.html?m=1
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		15-11-2019
-- Descripcion: Consultas para saber los permisos de cada usuario
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
GO
-- ==================================================
-- CONSULTA DE USUARIOS CON EL ROL O ROLES DEFINIDOS A NIVEL DE SERVER
-- ==================================================
SELECT @@SERVERNAME AS instance_name
	, sp.name AS login_name
	, sp.type_desc AS login_type
	, CASE
		WHEN sl.sysadmin = 1 THEN 'sysadmin'
		WHEN sl.securityadmin = 1 THEN 'securityadmin'
		WHEN sl.serveradmin = 1 THEN 'serveradmin'
		WHEN sl.setupadmin = 1 THEN 'setupadmin'
		WHEN sl.processadmin = 1 THEN 'processadmin'
		WHEN sl.diskadmin = 1 THEN 'diskadmin'
		WHEN sl.dbcreator = 1 THEN 'dbcreator'
		WHEN sl.bulkadmin = 1 THEN 'bulkadmin'
		ELSE 'public' 
	  END AS server_role
	, sp.default_database_name AS [default_database]
	, sp.is_disabled AS login_disabled
	, sl.denylogin AS deny_login
	, sl.hasaccess AS [has_access]
	, CONVERT(VARCHAR(15), sl.createdate, 103) AS create_date
	, CONVERT(VARCHAR(15), sl.updatedate, 103) AS update_date
	, CASE sp.name 
		WHEN 'NT AUTHORITY\SYSTEM' THEN 'Cuenta integrada para SQL Server, para validar logins de usuario.'
		WHEN 'NT Service\MSSQLSERVER' THEN 'Cuenta integrada para SQL Server, para levantar servicios de SQL Server.'
		WHEN 'NT SERVICE\SQLSERVERAGENT' THEN 'Cuenta integrada para SQL Server, para levantar especificamente el agente de SQL Server.'
		WHEN 'NT SERVICE\SQLTELEMETRY' THEN 'Cuenta integrada para SQL Server, para el uso de eventos extendidos.'
		WHEN 'NT SERVICE\SQLWriter' THEN 'Cuenta integrada para SQL Server, que ayuda a la generación de backups y restauraciones de BD.'
		WHEN 'NT SERVICE\Winmgmt' THEN 'Cuenta integrada para SQL Server, que ayuda para el uso de WMI.'
		WHEN 'sa' THEN 'Usuario integrado para SQL Server como Administrador del sistema.'
		ELSE ''
	  END AS [description]
FROM sys.server_principals sp
INNER JOIN sys.syslogins sl ON sp.sid = sl.sid
WHERE sp.type <> 'R'
	AND sp.name NOT LIKE '##%'
ORDER BY login_name;
GO
-- ==================================================
-- CONSULTA DE USUARIOS POR BASE DATOS Y ROLES ASIGNADOS, SIN TOMAR EN CUENTA(master, msdb, model y tempdb)
-- ==================================================
DECLARE @vSentencia VARCHAR(4000);
DECLARE @TblUsuariosXBD TABLE(DBName VARCHAR(200), UserName VARCHAR(250), LoginType VARCHAR(500), AssociatedRole VARCHAR(200));

SELECT @vSentencia = 'SELECT ''?'' AS database_name,a.name AS Name,a.type_desc AS LoginType,USER_NAME(b.role_principal_id) AS AssociatedRole 
FROM [?].sys.database_principals a
LEFT OUTER JOIN [?].sys.database_role_members b ON a.principal_id=b.member_principal_id
WHERE a.sid NOT IN (0x01,0x00) 
	AND a.sid IS NOT NULL 
	AND a.type NOT IN (''C'') 
	AND a.is_fixed_role <> 1 
	AND a.name NOT LIKE ''##%'' 
	AND ''?'' NOT IN(''master'',''msdb'',''model'',''tempdb'') 
ORDER BY Name';

INSERT @TblUsuariosXBD
EXEC sp_MSforeachdb @command1 = @vSentencia;

SELECT @@SERVERNAME AS instance_name
	, UserName AS [user_name]
	, DBName AS [database_name]
	, LoginType AS [login_type]
	, AssociatedRole AS database_role
FROM @TblUsuariosXBD
ORDER BY [user_name], [database_name];
GO
-- ==================================================
-- CONSULTA DE PERMISOS A NIVEL OBJETO POR USUARIO Y BASE DE DATOS
-- ==================================================
DECLARE @vSentencia VARCHAR(2000);
DECLARE @TblObjetos TABLE (DBName VARCHAR(200), UserName VARCHAR(250), ObjectName VARCHAR(500), Permission VARCHAR(200));

SELECT @vSentencia = 'SELECT ''?'' AS DBName,U.name AS UserName,O.name AS ObjectName,permission_name AS Permission 
FROM ?.sys.database_permissions
INNER JOIN ?.sys.sysusers U ON grantee_principal_id = uid 
INNER JOIN ?.sys.sysobjects O ON major_id = id 
WHERE ''?'' NOT IN(''master'',''msdb'',''model'',''tempdb'')
ORDER BY U.name';

INSERT @TblObjetos
EXEC sp_msforeachdb @command1 = @vSentencia;

SELECT @@SERVERNAME AS instance_name, UserName AS user_name, DBName AS database_name, ObjectName AS object_name, Permission AS permission
FROM @TblObjetos;
GO
