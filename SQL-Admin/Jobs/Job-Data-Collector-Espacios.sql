USE [msdb]
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Job-Data-Collector-Espacios.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-07-2021
-- Descripcion:	Generación de un job para la recolección de información de las bases de datos de la instancia, recolectadas en la base master, y en la tabla sql_server_espacios
-- ==================================================
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'ManagementPlan_DC_Espacios', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Job encargado de recolectar información de los espacios utilizados por cada base de datos, con el fin de poder generar una estimación de crecimiento facilmente al leer la tabla sql_server_espacios.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO

DECLARE @ServerName NVARCHAR(15);
SELECT @ServerName = @@SERVERNAME;
EXEC ('EXEC msdb.dbo.sp_add_jobserver @job_name=N''ManagementPlan_DC_Espacios'', @server_name = N''' + @ServerName + '''')
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'ManagementPlan_DC_Espacios', @step_name=N'ManagementPlan_DC_Espacios', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
-- =======================================================
-- Version:		1.0.0
-- =======================================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-07-2021
-- Descripcion:	Proceso que lee las bases de datos, para poder realizar un analisis de tendencia facilmente a futuro
-- =======================================================
IF NOT EXISTS (SELECT TOP(1) 1 FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[sql_server_espacios]'') AND type IN(N''U''))
BEGIN
	CREATE TABLE dbo.sql_server_espacios 
	(
		id_espacios BIGINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_sql_server_espacios PRIMARY KEY(id_espacios),
		fecha DATETIME NOT NULL CONSTRAINT DF_sql_server_espacios_fecha DEFAULT(GETDATE()),
		base_datos VARCHAR(256) NOT NULL,
		tamanio_datos_mb DECIMAL(18, 2) NOT NULL,
		tamanio_log_mb DECIMAL(18, 2) NOT NULL,
		espacio_libre_datos_mb DECIMAL(18, 2) NOT NULL,
		espacio_libre_log_mb DECIMAL(18, 2) NOT NULL
	);
END
GO

CREATE TABLE #databases_size
(
    database_id INT, 
	[database_name] SYSNAME,
	[name] SYSNAME,
    physical_name NVARCHAR(500),
    size DECIMAL(18,2),
    free_space DECIMAL(18,2),
	[type] BIT
);
GO

EXEC sys.sp_MSforeachdb 
''Use [?];
	INSERT INTO #databases_size(database_id, database_name, name, physical_name, size, free_space, type)
	SELECT DB_ID() 
		, DB_NAME()
		, name
		, physical_name
		, CONVERT(NVARCHAR, CAST(ROUND(CAST(size AS decimal) * 8 / 1024, 2) AS DECIMAL(18,2))) AS size
		, CONVERT(NVARCHAR, CAST(ROUND(CAST(size AS decimal) * 8 / 1024, 2) AS DECIMAL(18,2)) 
			- CAST(FILEPROPERTY(name, ''''SpaceUsed'''') * 8 / 1024 AS DECIMAL(18,2))) AS free_space
		, type
	FROM sys.database_files;'';
GO

;WITH CTE
AS
(
    SELECT [database_name] AS [database_name], size AS size, free_space AS free_space, type AS [type]
    FROM #databases_size
)
INSERT INTO dbo.sql_server_espacios(fecha,base_datos,tamanio_datos_mb,tamanio_log_mb,espacio_libre_datos_mb,espacio_libre_log_mb)
SELECT GETDATE() AS fecha
	, name AS base_datos
    , CAST((SELECT SUM(size) FROM CTE WHERE type = 0 AND CTE.database_name = db.name) AS DECIMAL(18, 2)) AS tamanio_datos_mb
    , CAST((SELECT SUM(size) FROM CTE WHERE type = 1 AND CTE.database_name = db.name) AS DECIMAL(18, 2)) AS tamanio_log_mb
	, CAST((SELECT SUM(free_space) FROM CTE WHERE type = 0 AND CTE.database_name = db.name) AS DECIMAL(18, 2)) AS espacio_libre_datos_mb
    , CAST((SELECT SUM(free_space) FROM CTE WHERE type = 1 AND CTE.database_name = db.name) AS DECIMAL(18, 2)) AS espacio_libre_log_mb
FROM sys.databases db
GO

DROP TABLE #databases_size;
GO', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ManagementPlan_DC_Espacios', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Job encargado de recolectar información de los espacios utilizados por cada base de datos, con el fin de poder generar una estimación de crecimiento facilmente al leer la tabla sql_server_espacios.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'ManagementPlan_DC_Espacios', @name=N'ManagementPlan_DC_Espacios', 
		@enabled=1, 
		@freq_type=32, 
		@freq_interval=8, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=16, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210722, 
		@active_end_date=99991231, 
		@active_start_time=235900, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
