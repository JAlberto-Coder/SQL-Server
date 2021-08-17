-- =======================================================
-- Version:		1.0.0
-- Archivo:		XE-Deadlocks-Monitor.sql
-- =======================================================
-- Autor:		JAlberto-Coder
-- Fecha:		06-08-2021
-- Descripcion:	Evento extendido para detectar sesiones que llega a tener un DEADLOCK
-- 
-- =======================================================
-- CREACIÓN DE LA SESIÓN DEADLOCKS_MONITOR, Tomando esta creación de la página: https://datoptim.com/monitor-deadlock/
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
-- SE INICIALIZA LA SESIÓN DEL EVENTO
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

SELECT EventDateTime_UTC = SessionEvents.SessionEventData_XML.value(N'(@timestamp)[1]', N'DATETIME2(7)')
	, EventName = SessionEvents.SessionEventData_XML.value(N'(@name)[1]', 'VARCHAR(50)')
	, SQLTextProcessVictim = REPLACE(SessionEvents.SessionEventData_XML.value(N'(/event/data/value/deadlock/process-list/process/executionStack/frame)[1]', 'VARCHAR(MAX)'), '  ', ' ')
	, SQLTextProcess2 = REPLACE(SessionEvents.SessionEventData_XML.value(N'(/event/data/value/deadlock/process-list/process/executionStack/frame)[2]', 'VARCHAR(MAX)'), '  ', ' ')
	, SQLTextProcess3 = REPLACE(SessionEvents.SessionEventData_XML.value(N'(/event/data/value/deadlock/process-list/process/executionStack/frame)[3]', 'VARCHAR(MAX)'), '  ', ' ')
	, SQLTextResource1 = REPLACE(SessionEvents.SessionEventData_XML.value(N'(/event/data/value/deadlock/resource-list/keylock/@objectname)[1]', 'VARCHAR(MAX)'), '  ', ' ')
	, SQLTextResource2 = REPLACE(SessionEvents.SessionEventData_XML.value(N'(/event/data/value/deadlock/resource-list/keylock/@objectname)[2]', 'VARCHAR(MAX)'), '  ', ' ')
	, SQLTextResource3 = REPLACE(SessionEvents.SessionEventData_XML.value(N'(/event/data/value/deadlock/resource-list/keylock/@objectname)[3]', 'VARCHAR(MAX)'), '  ', ' ')
	, EventXML = SessionEventData.EventData_XML
FROM 
(
    SELECT CAST(event_data AS XML) AS EventData_XML
    FROM sys.fn_xe_file_target_read_file
	(
		N'C:\MSSQL\Extended Events\Deadlocks_Monitor*.xel', NULL, NULL, NULL
	)
)
AS SessionEventData
CROSS APPLY SessionEventData.EventData_XML.nodes(N'//event') AS SessionEvents (SessionEventData_XML)
ORDER BY EventDateTime_UTC, EventName;
GO
-- =======================================================
-- SE FINALIZA LA SESIÓN
-- =======================================================
ALTER EVENT SESSION Deadlocks_Monitor ON SERVER
	STATE = STOP;
GO
-- =======================================================
-- OPCIONALMENTE SE ELIMINA LA SESIÓN
-- =======================================================
DROP EVENT SESSION Deadlocks_Monitor ON SERVER;
GO
