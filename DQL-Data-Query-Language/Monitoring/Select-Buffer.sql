USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Buffer.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		15-11-2019
-- Descripcion: Consultas utiles para saber como y quien esta utilizando la memoria del Buffer de nuestro servidor
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
-- =============================================
-- CONSULTA QUE DEVUELVE INFORMACION SOBRE LA MEMORIA ACTUAL QUE SE ENCUENTRA ASIGNADA
-- =============================================
SELECT (physical_memory_in_use_kb/1024) AS Memory_used_by_Sqlserver_MB
	, (locked_page_allocations_kb/1024) AS Locked_pages_used_Sqlserver_MB
	, (total_virtual_address_space_kb/1024) AS Total_VAS_in_MB
	, process_physical_memory_low
	, process_virtual_memory_low
FROM sys.dm_os_process_memory;
GO
-- =============================================
-- CONSULTA DE LA MEMORIA DEL BUFFER POR CADA USUARIO
-- =============================================
DECLARE @total_buffer INT;
SET @total_buffer = (SELECT cntr_value FROM sys.dm_os_performance_counters WHERE RTRIM([object_name]) LIKE'%Buffer Manager' AND counter_name = 'Total Pages');

WITH CTE_BufferConteo AS
(
	SELECT database_id, COUNT_BIG(1) AS db_buffer_pages
	FROM sys.dm_os_buffer_descriptors
	WHERE database_id BETWEEN 5 AND 32766
	GROUP BY database_id
)
SELECT [Database_Name] = 
	CASE [database_id] 
		WHEN 32767 THEN'MSSQL System Resource DB'
		ELSE DB_NAME([database_id]) 
	END
	, [Database_ID]
	, db_buffer_pages AS [Buffer Count (8KB Pages)]
	, db_buffer_pages / 128 AS [Buffer Size (MB)]
	, CONVERT(DECIMAL(6,3), db_buffer_pages * 100.0 / @total_buffer) AS [Buffer Size (%)]
FROM CTE_BufferConteo
ORDER BY [Buffer Size (MB)] DESC;
GO
-- =============================================
-- CONSULTA PARA MOSTRAR EL USO DEL BUFFER MOSTRANDO SOLO A LOS USUARIOS QUE MAS LA UTILIZAN
-- =============================================
SELECT mg.session_id
	, mg.requested_memory_kb
	, mg.granted_memory_kb
	, mg.used_memory_kb
	, t.text, qp.query_plan
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
ORDER BY 1 DESC OPTION (MAXDOP 1);
GO
-- =============================================
-- CONSULTA DEL ESTADO ACTUAL DEL USO DE LA MEMORIA EN SQL SERVER
-- =============================================
SELECT (physical_memory_kb/1024) AS physical_memory_MB -- Memoria física total instalada en el servidor
	, (virtual_memory_kb/1024) AS virtual_memory_MB --Cantidad total de memoria virtual disponible para SQL Server
	, (committed_kb/1024) AS committed_MB--La cantidad de memoria actualmente asignada por la cache del búfer para el uso por paginas de base de datos
	, (committed_target_kb/1024) AS committed_target_MB--Esta es la cantidad de memoria que la cache del búfer quiere usar
FROM sys.dm_os_sys_info;
GO
-- =============================================
-- CONSULTA QUE MUESTRA COMO SE EMPLEA LA MEMORIA
-- =============================================
SELECT TOP(20) [type] AS [Memory Clerk Name]
	, SUM(pages_kb) AS [SPA Memory (KB)]
	, SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY SUM(pages_kb) DESC;
GO
-- =============================================
-- COMANDO PARA MOSTRAR EL ESTATUS DE LA MEMORIA
-- =============================================
DBCC memorystatus;
GO