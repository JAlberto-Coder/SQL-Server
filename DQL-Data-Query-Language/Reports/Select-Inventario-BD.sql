USE master
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Select-Inventario-BD.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		24-08-2021
-- Descripcion:	Consultas para traer información de las bases de datos, para un inventario
-- ==================================================
SELECT @@SERVERNAME AS instance
	, LEFT(@@VERSION, 25) AS version
	, db.database_id
	, db.name
	, CONVERT(VARCHAR, db.create_date, 103) AS create_date
	, db.compatibility_level
	, SUM(mf.size) * 8 / 1024 AS size_MB
	, db.recovery_model_desc
	, db.state_desc
FROM sys.databases db
INNER JOIN sys.master_files mf ON db.database_id = mf.database_id
GROUP BY db.database_id
	, db.name
	, CONVERT(VARCHAR, db.create_date, 103)
	, db.compatibility_level
	, db.recovery_model_desc
	, db.state_desc
GO