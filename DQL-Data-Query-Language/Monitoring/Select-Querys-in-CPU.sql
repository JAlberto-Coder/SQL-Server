USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Querys-in-CPU.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-12-2019
-- Descripcion: Consultas de Querys que estan cachecadas por el CPU
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT TOP(25) dest.[text] AS [SP Name]
	, deqs.total_worker_time AS [TotalWorkerTime]
	, deqs.total_worker_time/deqs.execution_count AS [AvgWorkerTime]
	, deqs.execution_count AS [Execution Count]
	, COALESCE(deqs.execution_count/DATEDIFF(Second, deqs.creation_time, GETDATE()), 0) AS [Calls/Second]
	, COALESCE(deqs.total_elapsed_time/deqs.execution_count, 0) AS [AvgElapsedTime]
	, deqs.max_logical_reads
	, deqs.max_logical_writes
	, DATEDIFF(Minute, deqs.creation_time, GETDATE()) AS [Age in Cache]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.[sql_handle]) AS dest
WHERE dest.[dbid] = DB_ID('Developer') -- Filtrado de la base de datos a la cual realizar la consulta
ORDER BY deqs.total_worker_time DESC OPTION (RECOMPILE);
GO