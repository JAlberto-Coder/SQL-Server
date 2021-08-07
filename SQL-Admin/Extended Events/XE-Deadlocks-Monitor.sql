-- =======================================================
-- Version:		1.0.0
-- Archivo:		XE-Deadlocks-Monitor.sql
-- =======================================================
-- Autor:		JAlberto-Coder
-- Fecha:		06-08-2021
-- Descripcion:	Evento extendido para detectar sesiones que llega a tener un DEADLOCK
-- 
-- =======================================================
-- CREACI�N DE LA SESI�N DEADLOCKS_MONITOR, Tomando esta creaci�n de la p�gina: https://datoptim.com/monitor-deadlock/
-- =======================================================
CREATE EVENT SESSION Deadlocks_Monitor ON SERVER 
ADD EVENT sqlserver.lock_deadlock
(
    ACTION(sqlos.task_time)
),
ADD EVENT sqlserver.xml_deadlock_report
(
    ACTION(sqlos.task_time)
)
ADD TARGET package0.event_file
(
	SET filename = N'C:\MSSQL\Extended Events\Deadlocks_Monitor.xel'
	, max_file_size = (10240)
)
WITH 
(
	MAX_MEMORY = 4096 KB
	, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
	, MAX_DISPATCH_LATENCY = 30 SECONDS
	, MAX_EVENT_SIZE = 0 KB
	, MEMORY_PARTITION_MODE = NONE
	, TRACK_CAUSALITY = OFF
	, STARTUP_STATE = OFF
)
GO
-- =======================================================
-- SE INICIALIZA LA SESI�N DEL EVENTO
-- =======================================================
ALTER EVENT SESSION Deadlocks_Monitor ON SERVER 
	STATE = START;
GO
-- =======================================================
-- SE CONSULTAN LOS EVENTOS REGISTRADOS
-- =======================================================
SELECT object_name AS Objeto
	, file_name AS Archivo
    , file_offset AS Desplazamiento
    , CAST(event_data AS XML) AS XML_Evento
FROM sys.fn_xe_file_target_read_file
(
    'C:\MSSQL\Extended Events\Deadlocks_Monitor*.xel', NULL, NULL, NULL
);
GO
-- =======================================================
-- SE FINALIZA LA SESI�N
-- =======================================================
ALTER EVENT SESSION Deadlocks_Monitor ON SERVER
	STATE = STOP;
GO
-- =======================================================
-- OPCIONALMENTE SE ELIMINA LA SESI�N
-- =======================================================
DROP EVENT SESSION Deadlocks_Monitor ON SERVER;
GO