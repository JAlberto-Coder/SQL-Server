USE master
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo: 	Triggers-Review.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		18-08-2020
-- Descripcion:	Script las posibles sentencias para buscar triggers en nuestra base de datos, tablas o servidor
-- ==================================================
EXEC sp_helptrigger @tabname = 'Developers';
GO

EXEC sp_settriggerorder @triggername = 'Developers_Update', @order='First', @stmttype = 'UPDATE';
GO

SELECT * 
FROM sys.triggers;
GO
-- Por ejemplo
SELECT [name]
	, is_instead_of_trigger
FROM sys.triggers  
WHERE [type] = 'TR';

SELECT * 
FROM sys.trigger_events;

SELECT * 
FROM sys.server_triggers;

SELECT * 
FROM sys.server_trigger_events;

