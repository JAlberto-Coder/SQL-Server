USE [master]
GO

-- =================================================================
-- Version:		1.0.0
-- Archivo:		Select-SQL-Server-Data.sql
-- =================================================================
-- Autor:		JAlberto-Coder
-- Fecha:		12-08-2021
-- Description: Consultas diseñadas para recolectar información en el momento, y poder generar algún reporte de utilidad
-- =================================================================
SET NOCOUNT ON;
GO

-- =================================================================
-- DATACOLLECTOR SERVER_CPU
-- Muestra el porcentaje de uso de CPU, separando el motor del demás uso
-- =================================================================
DECLARE @ms_now BIGINT;

SELECT @ms_now = ms_ticks FROM sys.dm_os_sys_info;

;WITH CTE 
AS 
(
	SELECT TOP(1) record.value('(./Record/@id)[1]', 'int') AS record_id
		, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle
		, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization
		, [timestamp] AS [timestamp]
	FROM 
	(
		SELECT [timestamp] AS [timestamp]
			, CONVERT(XML, record) AS record
		FROM sys.dm_os_ring_buffers
		WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			AND record LIKE '%<SystemHealth>%'
	) AS dmorb
)
SELECT DATEADD(ms, -1 * (@ms_now - [timestamp]), GETDATE()) AS fecha
	, record_id AS id_registro
	, SQLProcessUtilization AS cpu_sql
	, SystemIdle AS proceso_idle
	, 100 - SystemIdle - SQLProcessUtilization AS cpu_otros
FROM CTE
ORDER BY record_id DESC;
GO

-- =================================================================
-- DATACOLLECTOR SERVER_MEMORY
-- Muestra la cantidad de memoria utilizada por el servidor en MB
-- =================================================================
SELECT GETDATE() AS fecha
	, counter_name AS contador
	, cntr_value / 1024 AS tamanio_mb
FROM sys.dm_os_performance_counters
WHERE (counter_name LIKE '%Total Server%' OR counter_name LIKE '%Target Server%');
GO
-- =================================================================
-- DATACOLLECTOR BUF_CACHEHIT_RATIO
-- Muestra el porcentaje de páginas encontradas en la memoria caché
-- =================================================================
SELECT GETDATE() AS fecha
	, CONVERT(DECIMAL(18, 2), (dopc.cntr_value * 1.0 / dopc_b.cntr_value) * 100.0) AS buffer_cache_hit_ratio
FROM sys.dm_os_performance_counters dopc
INNER JOIN 
(
	SELECT cntr_value,OBJECT_NAME 
	FROM sys.dm_os_performance_counters  
	WHERE counter_name = 'Buffer cache hit ratio base'
			AND OBJECT_NAME = 'SQLServer:Buffer Manager'
) dopc_b ON dopc.OBJECT_NAME = dopc_b.OBJECT_NAME
WHERE dopc.counter_name = 'Buffer cache hit ratio'
	AND dopc.OBJECT_NAME = 'SQLServer:Buffer Manager';
GO

-- =================================================================
-- DATACOLLECTOR IO
-- Muestra las lecturas y escrituras, que se tienen por base de datos, y el tiempo en milisegundos
-- =================================================================
;WITH CTE 
AS 
(
	SELECT GETDATE() AS fecha
		, mf.database_id AS id_base_datos
		, DB_NAME(mf.database_id) AS base_datos
		, mf.file_id AS id_archivo
		, mf.name AS archivo
		, mf.type_desc AS tipo
		, fs.num_of_reads AS numero_lecturas
		, (fs.num_of_bytes_read / 1024 / 1024) AS tamanio_lecturas_mb
		, fs.io_stall_read_ms AS tiempo_lecturas_ms
		, fs.num_of_writes AS numero_escrituras
		, (fs.num_of_bytes_written  / 1024 / 1024) AS tamanio_escrituras_mb
		, fs.io_stall_write_ms AS tiempo_escrituras_ms
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) fs
	INNER JOIN sys.master_files mf ON fs.database_id = mf.database_id AND fs.file_id = mf.file_id
)
SELECT GETDATE() AS fecha
	, id_base_datos
	, base_datos
	, SUM(numero_lecturas) AS numero_lecturas
	, SUM(tamanio_lecturas_mb) AS tamanio_lecturas_mb
	, SUM(tiempo_escrituras_ms) AS tiempo_escrituras_ms
	, SUM(numero_escrituras) AS numero_escrituras
	, SUM(tamanio_escrituras_mb) AS tamanio_escrituras_mb
	, SUM(tiempo_escrituras_ms) AS tiempo_escrituras_ms
FROM CTE
GROUP BY id_base_datos
	, base_datos;
GO
-- =================================================================
-- DATACOLLECTOR LOGIN_COUNT
-- Muestra el número de usuario que tienen una conexión abierta
-- =================================================================
SELECT des.login_time AS fecha_login
	, des.host_name AS hostname
	, des.login_name AS [user]
	, db.name AS base_datos
	, des.program_name AS programa
	, GETDATE() AS fecha
FROM sys.dm_exec_sessions des
INNER JOIN sys.sysprocesses sp ON des.session_id = sp.spid
LEFT OUTER JOIN sys.databases db ON sp.dbid = db.database_id
WHERE des.session_id >= 50 
	AND des.login_name NOT LIKE 'NT%';
GO