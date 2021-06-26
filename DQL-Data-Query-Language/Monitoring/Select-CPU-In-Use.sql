USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-CPU-In-Use.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-12-2019
-- Descripcion: Consulta de Uso de CPU durante los ultimos 30 minutos
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
 
DECLARE @ticsCPU BIGINT;
SET @ticsCPU = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info);

SELECT TOP(30) 'CPU%' AS CPU
	, DATEADD(ms, -1 * (@ticsCPU - [timestamp]), GETDATE()) AS Hora
	, SQLProcessUtilization AS [Procesos en CPU de SQL Server]
FROM 
(
	SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
		, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle]
		, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization]
		, [timestamp]
	FROM
	(
		SELECT [timestamp]
			, CONVERT(XML, record) AS [record]
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			AND record LIKE '%<SystemHealth>%'
	) AS a
) AS b
ORDER BY Hora DESC;
GO

SET NOCOUNT OFF;
GO