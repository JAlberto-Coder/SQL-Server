USE [master]
GO

-- SELECT * FROM sys.dm_server_services
-- SELECT * FROM sys.dm_server_registry
-- ==================================================
-- Fecha de instalación SQL Server
-- ==================================================
SELECT create_date
FROM sys.server_principals
WHERE sid = 0x010100000000000512000000
-- ==================================================
-- Información de las bases de datos
-- ==================================================
SELECT database_id
	, name	
	, CONVERT(VARCHAR, create_date, 103) AS create_date
	, compatibility_level
	, recovery_model_desc
	, state_desc
FROM sys.databases
GO
-- ==================================================
-- Distribución de los archivos de bases de datos
-- ==================================================
SELECT DB_NAME(database_id) AS [database]
	, name AS [file_name]
	, type_desc AS type
	, physical_name AS file_path
	, CONVERT(BIGINT, size/128.0) AS size
FROM sys.master_files
GO
-- ==================================================
-- Asignación de espacio de las bases de datos
-- ==================================================

-- ==================================================
-- Usuarios y roles
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
	, CASE WHEN sp.is_disabled = 1 OR sl.denylogin = 1 OR sl.hasaccess = 0 THEN 'No' ELSE 'Yes' END AS [has_access]
	, CONVERT(VARCHAR(15), sl.createdate, 103) AS create_date
FROM sys.server_principals sp
INNER JOIN sys.syslogins sl ON sp.sid = sl.sid
WHERE sp.type <> 'R'
	AND sp.name NOT LIKE '##%'
ORDER BY login_name;
GO
-- ==================================================
-- Servidores Vinculados
-- ==================================================
EXEC sys.sp_linkedservers
GO
-- ========================================
-- Trabajos programados
-- ========================================
USE msdb
GO

SELECT @@ServerName AS server_name
	, SJ.name AS job_name
	, COALESCE(SL.loginname, ' ') AS owner
	, SC.name AS category_name
	, CASE(SS.freq_type)
		WHEN 1 THEN 'Once'
		WHEN 4 THEN 'Daily'
		WHEN 8 THEN (CASE WHEN SS.freq_recurrence_factor > 1 THEN 'Every ' + CONVERT(VARCHAR(3), SS.freq_recurrence_factor) + ' Weeks' ELSE  'Weekly' END )
		WHEN 16 THEN (CASE WHEN SS.freq_recurrence_factor > 1 THEN 'Every ' + CONVERT(VARCHAR(3), SS.freq_recurrence_factor) + ' Months' ELSE  'Monthly' END )
		WHEN 32 THEN 'Every ' + CONVERT(VARCHAR(3), SS.freq_recurrence_factor) + ' Months'
		WHEN 64 THEN 'SQL Startup'
		WHEN 128 THEN 'SQL Idle'
		ELSE '??'
	  END AS frequency
	, CASE(SJ.enabled)
		WHEN 0 THEN 'No'
		WHEN 1 THEN 'Yes'
		ELSE '??'
	  END AS [enable]
FROM dbo.sysjobs SJ
LEFT OUTER JOIN dbo.sysjobschedules SJS ON SJ.job_id = SJS.job_id
LEFT OUTER JOIN dbo.sysschedules SS ON SS.schedule_id = SJS.schedule_id
LEFT OUTER JOIN master.dbo.syslogins SL ON SJ.owner_sid = SL.sid
LEFT OUTER JOIN dbo.syscategories SC ON SJ.category_id = SC.category_id
WHERE SJ.name <> 'syspolicy_purge_history'
ORDER BY SJ.name;
GO
-- ========================================
-- Últimos Backups
-- ========================================
