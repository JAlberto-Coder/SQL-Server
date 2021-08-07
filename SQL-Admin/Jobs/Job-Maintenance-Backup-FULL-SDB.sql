USE [msdb]
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Job-Maintenance-Backup-FULL-SDB.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-07-2021
-- Descripcion:	Generación de un job para generar respaldos FULL de las BD del sistema, estandar con los objetos de OLA.HALLENGREN
-- ==================================================
-- NOTA: Cambiar rutas, y generar una estrategia de respaldos, para genera el calendario
-- ==================================================
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'MaintenancePlan_BackupSystemDB', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Plan de mantenimiento para realizar un backup full de las bases del sistema utilizando los objetos de https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
DECLARE @ServerName NVARCHAR(15);
SELECT @ServerName = @@SERVERNAME;
EXEC ('EXEC msdb.dbo.sp_add_jobserver @job_name=N''MaintenancePlan_BackupSystemDB'', @server_name = N''' + @ServerName + '''')
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'MaintenancePlan_BackupSystemDB', @step_name=N'MaintenancePlan_BackupSystemDB', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.DatabaseBackup
	@Databases = ''SYSTEM_DATABASES'',
	@Directory = ''C:\SQL\Backups\SYSTEM_DATABASES'',
	@BackupType = ''FULL'',
	@Verify = ''Y'',
	@Compress = ''Y'',
	@CheckSum = ''Y'',
	@CleanupTime = 168;
GO', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'MaintenancePlan_BackupSystemDB', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Plan de mantenimiento para realizar un backup full de las bases del sistema utilizando los objetos de https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'MaintenancePlan_BackupSystemDB', @name=N'MaintenancePlan_BackupSystemDB', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210806, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
