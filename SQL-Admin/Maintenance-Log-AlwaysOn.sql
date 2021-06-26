USE AdventureWorks2019
GO
-- ==================================================
-- Version:			1.0.0
-- Archivo:		Maintenance-Log-AlwaysOn.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		16-02-2021
-- Descripcion: Reduccion de log en ambiente AlwaysOn, procurando la ejecución de estos en el nodo secundario
-- ==================================================
-- MODO ESTANDAR
-- ==================================================
DBCC SHRINKFILE(N'AdventureWorks2017_log', 5000);
GO

BACKUP LOG [AdventureWorks2019] TO DISK = N'I:\Backup\AdventureWorks2017.trn' 
WITH NOFORMAT
	, INIT
	, NAME = N'AdventureWorks2019 Backup Trn'
	, SKIP
	, NOREWIND
	, NOUNLOAD
	, COMPRESSION
	, STATS = 10;
GO

DBCC SHRINKFILE(N'AdventureWorks2017_log', 3000, NOTRUNCATE);
GO

DBCC SHRINKFILE(N'AdventureWorks2017_log', 3000);
GO
-- ==================================================
-- MODO SEMI-DINAMICO
-- ==================================================
USE AdventureWorks2019
GO

DBCC SHRINKFILE(N'AdventureWorks2017_log', 5000);
GO

DECLARE @Query NVARCHAR(4000);
DECLARE @Fecha_Backup VARCHAR(25) = REPLACE(REPLACE(REPLACE(CONVERT(varchar,GETDATE(),20), '-', ''), ':', ''), ' ', '_');
SELECT @Query = '
	BACKUP LOG CURP TO DISK = N''H:\Backup\AdventureWorks2019\AdventureWorks2019_' + @Fecha_Backup + '.trn''
	WITH NOFORMAT
	, INIT
	, COMPRESSION
	, NAME = N''CURP Backup Trn''
	, SKIP
	, NOREWIND
	, NOUNLOAD
	, STATS = 10;';
PRINT @Query;
EXEC sp_executesql @Query;
GO

DBCC SHRINKFILE(N'AdventureWorks2017_log', 3000, NOTRUNCATE);
GO

DBCC SHRINKFILE(N'AdventureWorks2017_log', 3000);
GO
