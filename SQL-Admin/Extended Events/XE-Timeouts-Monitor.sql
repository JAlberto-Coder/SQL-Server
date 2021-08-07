-- =======================================================
-- Version:		1.0.0
-- Archivo:		XE-Timeouts-Monitor.sql
-- =======================================================
-- Autor:		JAlberto-Coder
-- Fecha:		06-08-2021
-- Descripcion:	Evento extendido para detectar sesiones que llega a tener un TIMEOUT, 
-- 				tomando esta plantilla de https://www.linkedin.com/pulse/how-monitor-client-timeouts-sql-server-guy-glantser/
-- =======================================================
-- CREACIÓN DE LA SESIÓN TIMEOUTS_MONITOR
-- =======================================================
CREATE EVENT SESSION Timeouts_Monitor ON SERVER
ADD EVENT sqlserver.attention
(
	ACTION
    (
        sqlserver.client_app_name
        , sqlserver.client_hostname
        , sqlserver.client_pid
        , sqlserver.database_name
        , sqlserver.server_principal_name
        , sqlserver.session_id
        , sqlserver.sql_text
    )
)
ADD TARGET package0.event_file 
(
	SET filename = N'C:\MSSQL\Extended Events\Timeouts_Monitor.xel'
	, max_file_size=(10240)
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
);
GO
-- =======================================================
-- SE INICIALIZA LA SESIÓN DEL EVENTO
-- =======================================================
ALTER EVENT SESSION Timeouts_Monitor ON SERVER 
	STATE = START;
GO
-- =======================================================
-- SE CONSULTAN LOS EVENTOS REGISTRADOS
-- =======================================================
SELECT EventDateTime_UTC = SessionEvents.SessionEventData_XML.value(N'(@timestamp)[1]', N'DATETIME2(7)')
	, ClientAppName = SessionEvents.SessionEventData_XML.value(N'(action[@name="client_app_name"]/value)[1]', N'NVARCHAR(1000)')
	, ClientHostName = SessionEvents.SessionEventData_XML.value(N'(action[@name="client_hostname"]/value)[1]', N'NVARCHAR(1000)')
	, ClientProcessId = SessionEvents.SessionEventData_XML.value(N'(action[@name="client_pid"]/value)[1]', N'BIGINT')
	, DatabaseName = SessionEvents.SessionEventData_XML.value(N'(action[@name="database_name"]/value)[1]', N'SYSNAME')
	, ServerPrincipalName = SessionEvents.SessionEventData_XML.value(N'(action[@name="server_principal_name"]/value)[1]', N'SYSNAME')
	, SessionId = SessionEvents.SessionEventData_XML.value(N'(action[@name="session_id"]/value)[1]', N'BIGINT')
	, SQLText = SessionEvents.SessionEventData_XML.value(N'(action[@name="sql_text"]/value)[1]', N'NVARCHAR(MAX)')
FROM
(
    SELECT CAST(event_data AS XML) AS EventData_XML
    FROM sys.fn_xe_file_target_read_file
	(
		N'C:\MSSQL\Extended Events\Timeouts_Monitor*.xel' , NULL , NULL , NULL
	)
)
AS SessionEventData
CROSS APPLY SessionEventData.EventData_XML.nodes(N'//event') AS SessionEvents (SessionEventData_XML);
GO
-- =======================================================
-- SE FINALIZA LA SESIÓN
-- =======================================================
ALTER EVENT SESSION Timeouts_Monitor ON SERVER
	STATE = STOP;
GO
-- =======================================================
-- OPCIONALMENTE SE ELIMINA LA SESIÓN
-- =======================================================
DROP EVENT SESSION Timeouts_Monitor ON SERVER;
GO