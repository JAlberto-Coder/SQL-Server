USE Developer;
GO
-- ==================================================
-- Versión:		1.0.0
-- Archivo:		Select-Percent-Backup-Restore.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		07-10-2020
-- Descripción:	Script que determina le porcentaje de avance para procesos de generación de backup y restauración de estos
-- ==================================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT r.session_id AS IdSesion
	, r.command AS Comando
	, aa.[text] AS Sentencia
	, r.start_time AS HoraInicio
	, r.percent_complete AS PorcentajeCompletado
	, DATEADD(SECOND, r.estimated_completion_time / 1000, GETDATE()) AS TiempoEstimadoDeFinalizacion
	, DATEDIFF(HOUR, r.start_time, GETDATE()) AS TiempoEnHoras
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) aa
WHERE r.command IN('BACKUP DATABASE','RESTORE DATABASE');
GO