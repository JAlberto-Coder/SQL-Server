USE master
GO
-- ==================================================
-- Version:		1.0.0
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-08-2021
-- Descripcion:	Consulta que devuelve la información que es relevante para sacar un inventario de instancias
-- ==================================================
SELECT SERVERPROPERTY('MachineName') AS hostname
	, @@SERVERNAME AS instance
	, REPLACE(LEFT(@@VERSION, 25), 'Microsoft SQL Server', 'MSSQL') AS product
	, SERVERPROPERTY ('edition') AS edition
	, SERVERPROPERTY('productversion') AS product_version
	, SERVERPROPERTY ('productlevel') AS product_level
	, CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS bit) AS is_full_text_installed
	, CAST(ISNULL(SERVERPROPERTY('IsClustered'), N'') AS bit) AS is_clustered
GO
