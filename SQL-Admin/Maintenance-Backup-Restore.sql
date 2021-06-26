USE master
GO
-- ==================================================
-- Version:		1.0.0.0
-- Archivo:		Maintenance-Backup-Restore.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		11-02-2020
-- Descripcion: Sentencias para respaldar y restaurar bases de datos
-- ==================================================
-- BACKUP MUY ESTÁNDAR CON OPCIONES DE COMPRESION
-- ==================================================
BACKUP DATABASE [Developer] TO
DISK = N'C:\SQL\Backup\Developer.bak' 
WITH NOFORMAT
	, COMPRESSION
	, INIT
	, NAME = N'Developoer-Full Database Backup'
	, SKIP
	, NOREWIND
	, NOUNLOAD
	, STATS = 10;
GO
-- ==================================================
-- BACKUP COMPLETO, SIN INDICACION DE ALGUNA PROPIEAD
-- ==================================================
BACKUP DATABASE Developer
TO DISK = 'C:\SQL\Backup\Developer.bak'
WITH INIT
	, FORMAT
	, NAME = 'BackupCompleto'
	, DESCRIPTION = 'Se realiza un backup completo de la base Developer';
GO
-- ==================================================
-- BACKUP DIFERENCIAL
-- ==================================================
BACKUP DATABASE Developer
TO DISK = 'C:\SQL\Backup\Developer.bak'
WITH DIFFERENTIAL -- INSTRUCCION PARA QUE EL BACKUP IDENTIFIQUE QUE ES DIFERENCIAL
	, NAME = 'BackupDiferencial'
	, DESCRIPTION = 'Se realiza un backup diferencial de la base Developer';	
GO
-- ==================================================
-- BACKUP LOG DE TRANSACCIONES
-- ==================================================
BACKUP LOG Developer
TO DISK = 'C:\SQL\Backup\Developer.bak'
WITH NAME = 'BackupLog'
	, DESCRIPTION = 'Se realiza un backup de log de transacciones de la base Developer';	
GO
-- ==================================================
-- BACKUP DE SOLO COPIA
-- ==================================================
BACKUP DATABASE Developer
TO DISK = 'C:\SQL\Backup\Developer_11-02-2020.bak'
WITH COPY_ONLY
	, NAME = 'BackupCompletoSoloCopia'
	, DESCRIPTION = 'Se realiza un backup completo de solo copia de la base Developer';	
GO
-- ==================================================
-- BACKUP DE FILEGROUP
-- ==================================================
BACKUP DATABASE Developer FILEGROUP = 'Primary'
TO DISK = 'C:\SQL\Backup\Developer_11-02-2020.bak'
WITH NAME = 'BackupFilegroup'
	, DESCRIPTION = 'Se realiza un backup de log de transacciones de la base Developer';	
GO
-- ==================================================
-- BACKUP DE LA COLA DEL LOG
-- ==================================================
BACKUP LOG Developer
TO DISK = 'C:\SQL\Backup\Developer_11-02-2020.bak'
WITH RECOVERY
	, NAME = 'BackupColaLog'
	, DESCRIPTION = 'Se realiza un backup de la cola del log de la base Developer';	
GO