USE [msdb]
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Job-Maintenance-Backup-LOG-UDB.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-07-2021
-- Descripcion:	Generación de un job para generar respaldos LOG, utilizando los objetos de OLA.HALLENGREN
-- ==================================================
-- NOTA: Cambiar rutas, y generar una estrategia de respaldos, para genera el calendario
-- ==================================================
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'MaintenancePlan_BackupLOG', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Plan de mantenimiento para realizar un backup log de las bases del usuario utilizando los objetos de https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
DECLARE @ServerName NVARCHAR(50);
SELECT @ServerName = @@SERVERNAME;
EXEC ('EXEC msdb.dbo.sp_add_jobserver @job_name=N''MaintenancePlan_BackupLOG'', @server_name = N''' + @ServerName + '''')
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'MaintenancePlan_BackupLOG', @step_name=N'MaintenancePlan_BackupLOG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET LANGUAGE SPANISH;
SET DATEFORMAT DMY;

DECLARE @DIA NVARCHAR(50);

SELECT @DIA = N''C:\MSSQL\Backup\'' 
	+ CASE DATEPART(DW, GETDATE()) 
		WHEN 1 THEN ''1-LUNES''
		WHEN 2 THEN ''2-MARTES''
		WHEN 3 THEN ''3-MIERCOLES''
		WHEN 4 THEN ''4-JUEVES''
		WHEN 5 THEN ''5-VIERNES''
		WHEN 6 THEN ''6-SABADO''
		WHEN 7 THEN ''7-DOMINGO''
	END

IF (DATEPART(DW, GETDATE()) < 6)
BEGIN
	EXECUTE dbo.DatabaseBackup
	@Databases = ''USER_DATABASES'',
	@Directory = @DIA,
	@BackupType = ''LOG'',
	@Verify = ''Y'',
	@Compress = ''Y'',
	@CheckSum = ''Y'',
	@CleanupTime = 168;
END
GO', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'MaintenancePlan_BackupLOG', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Plan de mantenimiento para realizar un backup log de las bases del usuario utilizando los objetos de https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
