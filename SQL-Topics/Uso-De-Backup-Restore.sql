USE Developer
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Uso-De-Backup-Restore.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		11-02-2020		
-- Descripcion: Ejercicios de backup y restore
-- ==================================================
-- INICIO: EJEMPLO
-- ==================================================
IF OBJECT_ID('Developer.dbo.Usuarios', 'U') IS NULL
BEGIN
	CREATE TABLE Usuarios
	(
		idUsuario BIGINT IDENTITY(1,1) NOT NULL,
		Usuario VARCHAR(60) UNIQUE NOT NULL,
		CONSTRAINT PK_U_idUsuario PRIMARY KEY(idUsuario)
	);
END
GO
-- ==================================================
-- BAKCUP COMPLETO
-- ==================================================
BACKUP DATABASE Developer
TO DISK = 'C:\SQL\Backup\Developer.bak'
WITH INIT
	, FORMAT
	, NAME = 'BackupCompleto'
	, DESCRIPTION = 'Se realiza un backup completo de la base Developer';
GO
-- ==================================================
-- INSERT DE DATOS
-- ==================================================
INSERT INTO Usuarios (Usuario) VALUES('HermannHesse');
INSERT INTO Usuarios (Usuario) VALUES('StevePrefontaine');
GO
-- ==================================================
-- BACKUP DEL LOG
-- ==================================================
BACKUP LOG Developer
TO DISK = 'C:\SQL\Backup\Developer.bak'
WITH NAME = 'BackupLog'
	, DESCRIPTION = 'Se realiza un backup de log';	
GO
-- ==================================================
-- INSERT DE MAS DATOS
-- ==================================================
INSERT INTO Usuarios (Usuario) VALUES('Nitche');
INSERT INTO Usuarios (Usuario) VALUES('FKalo');
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
-- INSERT DE MAS DATOS
-- ==================================================
INSERT INTO Usuarios (Usuario) VALUES('Zapata');
INSERT INTO Usuarios (Usuario) VALUES('HaileH');
GO
-- ==================================================
-- BACKUP DEL LOG
-- ==================================================
BACKUP LOG Developer
TO DISK = 'C:\SQL\Backup\Developer.bak'
WITH NAME = 'BackupLog2'
	, DESCRIPTION = 'Se realiza un backup de log';	
GO
-- ==================================================
-- CONSULTA CONTENIDO DE UN BACKUP
-- ==================================================
RESTORE HEADERONLY
FROM DISK = 'C:\SQL\Backup\Developer.bak';
GO
-- ==================================================
-- BORRAR LA BASE DE DATOS
-- ==================================================
USE [master];
GO
DROP DATABASE Developer;
GO
-- ==================================================
-- RESTORE COMPLETO Y DE LOS LOGS
-- ==================================================
RESTORE DATABASE Developer
FROM DISK = 'C:\SQL\Backup\Developer.bak'
WITH FILE = 1
	, NORECOVERY; -- Instruccion para que la BD no se encuentre disponible
GO
RESTORE DATABASE Developer
FROM DISK = 'C:\SQL\Backup\Developer.bak'
WITH FILE = 2
	, NORECOVERY; -- Instruccion para que la BD no se encuentre disponible
GO
RESTORE DATABASE Developer
FROM DISK = 'C:\SQL\Backup\Developer.bak'
WITH FILE = 4
	, RECOVERY; -- Instruccion para dejar a la BD restaurada disponible
GO
-- ==================================================
-- VERIFICACIONES
-- ==================================================
USE Developer;
GO
SELECT * 
FROM Usuarios WITH(NOLOCK);
-- ==================================================
-- BORRAR LA BASE DE DATOS
-- ==================================================
USE [master];
GO
DROP DATABASE Developer;
GO
-- ==================================================
-- RESTORE COMPLETO Y DEL DIFERENCIAL
-- ==================================================
RESTORE DATABASE Developer
FROM DISK = 'C:\SQL\Backup\Developer.bak'
WITH FILE = 1
	, NORECOVERY; -- Instruccion para que la BD no se encuentre disponible
GO
RESTORE DATABASE Developer
FROM DISK = 'C:\SQL\Backup\Developer.bak'
WITH FILE = 3
	, RECOVERY; -- Instruccion para dejar a la BD restaurada disponible
GO
-- ==================================================
-- CONSULTA DE DATOS
-- ==================================================
USE Developer;
GO
SELECT * 
FROM Usuarios WITH(NOLOCK);
-- ==================================================
-- FIN: EJEMPLO
-- ==================================================