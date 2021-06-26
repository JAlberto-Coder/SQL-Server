USE msdb
GO
-- ==================================================
-- Version: 	1.0.0
-- Archivo: 	Select-History-Of-Backups.sql
-- ==================================================
-- Autor: 		JAlberto-Coder
-- Fecha: 		19-10-2020
-- Descripcion:	Query's que consultan historico de restauraciones y ultimo backup generado
-- ==================================================
-- BACKUPS GENERADOS
-- ==================================================
;WITH CTE 
AS
(
	SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS server_name
		, bs.database_name AS [database_name]
		, bs.backup_start_date AS backup_start_date
		, bs.backup_finish_date AS backup_finish_date
		, bs.expiration_date AS expiration_date
		, CASE bs.type
			   WHEN 'D' THEN 'Database'
			   WHEN 'L' THEN 'Log'
			   WHEN 'I' THEN 'Differencial'
		   END AS backup_type
		, bs.backup_size AS backup_size
		, bmf.logical_device_name AS logical_device_name
		, bmf.physical_device_name AS physical_device_name
		, bs.name AS backupset_name
		, bs.description AS [description]
	FROM dbo.backupmediafamily bmf
	INNER JOIN dbo.backupset bs ON bmf.media_set_id = bs.media_set_id
)
SELECT server_name AS server_name
	, database_name AS [database_name]
	, backup_finish_date AS backup_finish_date
	, CONVERT(DECIMAL(18, 2), backup_size / 1024 / 1024) AS size
FROM CTE;
GO
-- ==================================================
-- HISTORICO DE RESTAURACIONES
-- ==================================================
SELECT rs.destination_database_name AS destination_database_name
	, rs.restore_date AS restore_date
	, bs.backup_start_date AS backup_start_date
	, bs.backup_finish_date AS backup_finish_date
	, bs.database_name AS [database_name]
	, bmf.physical_device_name AS physical_device_name
FROM dbo.restorehistory rs
INNER JOIN dbo.backupset bs ON rs.backup_set_id = bs.backup_set_id
INNER JOIN dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id 
ORDER BY rs.restore_date DESC;
GO
-- ==================================================
-- ULTIMO BACKUP GENERADO
-- ==================================================
SELECT sdb.Name AS [database_name]
	, COALESCE(CONVERT(VARCHAR(12), MAX(bus.backup_finish_date), 105),'-') AS [date]
FROM sys.sysdatabases sdb
LEFT JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
GROUP BY sdb.Name;
GO