USE master
GO
-- ==================================================
-- Version:		1.0.1
-- Archivo:		Select-Monitoring-Of-Instance.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		07-10-2020
-- Descripcion:	Script con consultas para monitorear la instancia de la base de datos
-- ==================================================
-- ServeName and start time of instance
-- ==================================================
SELECT GETDATE() AS [date]
	, SERVERPROPERTY('MachineName') AS hostname
	, SERVERPROPERTY('ServerName') AS instance
	, @@VERSION AS [version]
	, SERVERPROPERTY('productversion') AS product_version
	, SERVERPROPERTY ('productlevel') AS product_level
	, SERVERPROPERTY ('edition') AS edition
	, sqlserver_start_time AS sqlserver_start
FROM sys.dm_os_sys_info;
GO
-- ==================================================
-- SQL Total Ram Memory, 
-- ==================================================
DECLARE @TotalServerMemorySQL DECIMAL(10,2)
	, @ServerMemory DECIMAL(10,2)
	, @ServerMemoryAvailable DECIMAL(10,2);

SELECT @ServerMemoryAvailable = (available_physical_memory_kb / 1024) / 1024 
FROM sys.dm_os_sys_memory;

SELECT @TotalServerMemorySQL = cntr_value / 1024
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Total Server Memory (KB)';

SELECT @TotalServerMemorySQL = CAST(@TotalServerMemorySQL / 1024 AS DECIMAL(10, 2));

-- For SQL Server versions 2005 and 2008
--SELECT @ServerMemory = CEILING(((CONVERT(FLOAT(2), physical_memory_in_bytes)) / 1024) / 1024 / 1024) FROM sys.dm_os_sys_info;
-- For SQL Server versions 2012 up
SELECT @ServerMemory = ((physical_memory_kb / 1024) / 1024) FROM sys.dm_os_sys_info;

SELECT @ServerMemory AS total_server_memory_GB
	, @TotalServerMemorySQL AS server_bd_memory_usage_GB
	, CEILING(CONVERT(DECIMAL(10, 2), (@TotalServerMemorySQL * 100) / @ServerMemory)) AS server_bd_memory_usage_percentaje
	, @ServerMemoryAvailable AS total_server_memory_available_GB;
GO
-- ==================================================
-- SQL Data File Size And Log File Size
-- ==================================================
WITH CTE
AS
(
    SELECT database_id
		, type
		, size * 8.0 / 1024 AS size
    FROM sys.master_files
)
SELECT TOP(10) name AS [database_name]
	, (SELECT SUM(size) FROM CTE WHERE type = 0 AND CTE.database_id = db.database_id) AS data_file_size_MB
    , (SELECT SUM(size) FROM CTE WHERE type = 1 AND CTE.database_id = db.database_id) AS log_file_size_MB
	, (SELECT SUM(size) FROM CTE WHERE type = 0 AND CTE.database_id = db.database_id) / 1024 AS data_file_size_GB
	, (SELECT SUM(size) FROM CTE WHERE type = 1 AND CTE.database_id = db.database_id) / 1024 AS log_file_size_GB
FROM sys.databases db
--WHERE database_id > 4
ORDER BY data_file_size_MB DESC;
GO
-- ==================================================
-- SQL Number Dead Locks
-- ==================================================
SELECT counter_name
	, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Number of Deadlocks/sec' 
	-- AND instance_name = 'Database';
GO
-- ==================================================
-- SQL Proccess Bloked
-- ==================================================
SELECT counter_name
	, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Processes bloked';
GO
-- ==================================================
-- SQL_USERCONNECTIONS
-- ==================================================
SELECT counter_name
	, cntr_value
FROM sys.dm_os_performance_counters
WHERE Counter_name = '';
GO