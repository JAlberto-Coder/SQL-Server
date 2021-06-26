USE master
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Select-Activity-Of-Instance.sql
-- ==================================================
-- Autor:		JAberto-Coder
-- Fecha:		14-02-2020
-- Descripcion: Scrips que realizan un monitoreo de la actividad de los usuarios que estan en la instancia SQL Server
-- ==================================================
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
-- ==================================================
-- ACTIVIDAD
-- ==================================================
SELECT session_id -- Id de la sesion relacionada la solicitud
	, command -- Comando detectado SELECT, INSERT UPDATE, DELETE, BACKUP LOG, BACKUP DATABASE, DBCC, FOR
    , s.text -- Texto de Consulta realizada
    , start_time -- Marca de tiempo cuando llego la solicitud
	, percent_complete -- Porcentaje completado
	, CAST(((DATEDIFF(S, start_time, GetDate())) / 3600) AS VARCHAR) + ' hour(s), '
	  + CAST((DATEDIFF(S, start_time, GetDate()) % 3600) / 60 AS VARCHAR) + 'min, '
	  + CAST((DATEDIFF(S, start_time, GetDate()) % 60) AS VARCHAR) + ' sec' AS running_time -- Tiempo de sentencia ejecutandose
    , CAST((estimated_completion_time / 3600000) AS VARCHAR) + ' hour(s), '
     + CAST((estimated_completion_time % 3600000) / 60000 AS VARCHAR) + 'min, '
     + CAST((estimated_completion_time % 60000) / 1000 AS VARCHAR) + ' sec' AS est_time_to_go -- Teimpo estimado para que termine la sentencia en ejecucion
	, DATEADD(SECOND,estimated_completion_time / 1000, GETDATE()) AS est_completion_time -- Fecha y Tiempo en el que se completo la sentencia
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
ORDER BY command, s.text, session_id, running_time DESC;
GO
-- ==================================================
-- BLOQUEOS
-- ==================================================
SELECT GETDATE() AS [date]
	, er.session_id -- Id de la sesion asociada con cada conexion primaria activa
	, es.host_name -- Nombre de la estación de trabajo del cliente
	, es.program_name -- Nombre del  programa del cliente que inicio la sesion
	, es.original_login_name -- Nombre del usuario que inicio la sesion
	, er.status -- Estado de la solicitud: Background, Running, Runnable, Sleping, Suspended
	, er.reads -- Numero de lecturas realizadas en la solicitud
	, er.writes -- Numero de escrituras realizadas en la solicud
	, er.cpu_time -- Tiempo de CPU en milisegundos
	, er.wait_type -- Si la solicitud está bloqueada, devuelve el tipo de espera
	, er.wait_time -- Si la solicitud está bloqueada, devuelve el tipo de espera
	, er.wait_resource -- Si la solicitud está bloqueada, devuelve el recurso para el que la solicita actualmente está esperando
	, er.blocking_session_id -- id de la sesion que está bloqueando la solicitud
	, st.text -- Texto de la consulta SQL, es NULL para objetos cifrados
	, er.sql_handle -- Hash map del texto SQL de la solicitud
	, er.transaction_isolation_level -- Nivel de aislamiento con el que se crea la transacción para esta solicitud: =Unspecified, 1=ReadUncommited, 2=ReadCommitted, 3=Repeatable, 4=Serializable, 5=Snapshot
FROM sys.dm_exec_sessions AS es 
LEFT OUTER JOIN sys.dm_exec_requests AS er ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE er.blocking_session_id > 0
UNION ALL
SELECT GETDATE() AS [date]
	, er.session_id -- Id de la sesion asociada con cada conexion primaria activa
	, es.host_name -- Nombre de la estación de trabajo del cliente
	, es.program_name -- Nombre del programa del cliente que inicio la sesion
	, es.original_login_name -- Nombre del usuario que inicio la sesion
	, er.status -- Estado de la solicitud: Background, Running, Runnable, Sleping, Suspended
	, er.reads -- Numero de lecturas realizadas en la solicitud
	, er.writes -- Numero de escrituras realizadas en la solicud
	, er.cpu_time -- Tiempo de CPU en milisegundos
	, er.wait_type -- Si la solicitud está bloqueada, devuelve el tipo de espera
	, er.wait_time -- Si la solicitud está bloqueada, devuelve el tipo de espera
	, er.wait_resource -- Si la solicitud está bloqueada, devuelve el recurso para el que la solicita actualmente está esperando
	, er.blocking_session_id -- id de la sesion que está bloqueando la solicitud
	, st.text -- Texto de la consulta SQL, es NULL para objetos cifrados
	, er.sql_handle -- Hash map del texto SQL de la solicitud
	, er.transaction_isolation_level -- Nivel de aislamiento con el que se crea la transacción para esta solicitud: =Unspecified, 1=ReadUncommited, 2=ReadCommitted, 3=Repeatable, 4=Serializable, 5=Snapshot
FROM sys.dm_exec_sessions AS es
LEFT OUTER JOIN sys.dm_exec_requests AS er ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE es.session_id IN 
	(
		SELECT blocking_session_id
		FROM sys.dm_exec_requests
		WHERE blocking_session_id > 0 
	)
	ORDER BY status;
GO
-- ==================================================
-- SESIONES DE USUARIO
-- ==================================================
SELECT session_id, login_name, [status], cpu_time, reads, writes, logical_reads, transaction_isolation_level, database_id, login_time, total_elapsed_time, last_request_start_time, last_request_end_time, [host_name], [program_name], client_interface_name
FROM sys.dm_exec_sessions
WHERE login_name NOT IN('sa')
	--AND login_name = 'User'
ORDER BY [program_name] DESC, login_name;
GO
-- ==================================================
-- TOTAL DE CONEXIONES
-- ==================================================
SELECT COUNT(dbid) AS connections
FROM sys.sysprocesses
WHERE dbid > 0;
GO
-- ==================================================
-- NUMERO DE CONEXIONES POR USUARIO
-- ==================================================
SELECT DB_NAME(dbid) AS [database_name]
	, loginame AS login_name
	, COUNT(dbid) AS number_of_connections
FROM sys.sysprocesses
WHERE dbid > 0
GROUP BY dbid, loginame
ORDER BY number_of_connections DESC;
GO
-- ==================================================
-- SENTENCIAS CON MAYOR EJECUCION, Y MAYOR ESFUERZO
-- ==================================================
SELECT SUBSTRING(text,qs.statement_start_offset / 2, (IIF(qs.statement_end_offset = -1, LEN(CONVERT(NVARCHAR(MAX), text)) * 2, qs.statement_end_offset)- qs.statement_start_offset)/2) AS query
	, qs.plan_generation_num AS recompiles -- Numero de secuencia que se puede usar para distinguir entre instancias de planes desués de una recompilacion
	, qs.execution_count AS execution_count -- Numero de veces que el plan se ejecuto desde la última compilacion
	, qs.total_elapsed_time - qs.total_worker_time AS total_wait_time --
	, qs.total_worker_time AS cpu_time -- Cantidad total de tiempo de CPU, en milisegundos
	, qs.total_logical_reads AS reads -- Numero total de lecturas logias
	, qs.total_logical_writes AS writes -- Numero total de escrituras logias
FROM sys.dm_exec_query_stats qs -- Devuelve las estadisticas de rendimiento agregado para planes de consultas en cache en SQL Server
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
LEFT JOIN sys.dm_exec_requests r ON qs.sql_handle = r.sql_handle
ORDER BY execution_count DESC;
GO

SET NOCOUNT OFF;
GO