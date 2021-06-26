USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Management-Move-Files-Databases.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		19-03-2020
-- Descripcion: Sentencias para mover los files de alguna base de datos a otro lugar,
--				recuerda que al hacer esto se deberá de reiniciar el motor de base de datos al terminar
-- =============================================
EXEC sp_helpfile
GO

USE master
GO

ALTER DATABASE Developer
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE Developer SET OFFLINE;  
GO

ALTER DATABASE Developer
MODIFY FILE (NAME = Developer, FILENAME = 'C:\SQL\Data\Developer.mdf')
GO

ALTER DATABASE Developer
MODIFY FILE (NAME = Developer_log, FILENAME = 'C:\SQL\Log\Developer_log.ldf')
GO

ALTER DATABASE Developer
MODIFY FILE (NAME = Developer_2, FILENAME = 'C:\SQL\Llaves\Developer_2.ndf')
GO

ALTER DATABASE Developer SET ONLINE;  
GO

ALTER DATABASE Developer
SET MULTI_USER;
GO