USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Check-Bb-Tables.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-12-2019
-- Descripcion: Consulta utiles para visualizar informacion de importancia de las bases de datos
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
GO
-- =============================================
-- CONSULTA PARA VER EL MODO DE RECUPERACION EN EL QUE SE ENCUENTRA CADA BASE DE DATOS
-- =============================================
SELECT name
	, user_access_desc
	, is_read_only
	, state_desc
	, recovery_model_desc 
FROM sys.databases;
GO

USE Developer
GO
-- =============================================
-- Query para visualzar como están los archivos de mdf, ndf y log de la base de datos en la que se encuentra
-- =============================================
SELECT name
	, size/128.0 AS FileSizeInMB
	, size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS EmptySpaceInMB 
FROM sys.database_files;
GO
-- =============================================
-- PROCEDIMIENTO PARA VISUALIZAR EL TAMINIO DE CADA TABLA
-- =============================================
EXEC sp_spaceused N'Developer.dbo.Encabezado';
GO
-- =============================================
-- CONSULTA PARA VER EL TAMANIO DE LAS TABLAS Y OTROS PARAMETROS DE IMPORTANCIA
-- =============================================
SELECT s.Name AS SchemaName
	, t.NAME AS TableName
	, p.rows AS RowCounts
	, SUM(a.total_pages) * 8 AS TotalSpaceKB
	, (SUM(a.total_pages) * 8) / 1024.0 AS TotalSpaceMB
	, ( (SUM(a.total_pages) * 8) / 1024.0 ) / 1024.0 AS TotalSpaceGB
	, SUM(a.used_pages) * 8 AS UsedSpaceKB
	, (SUM(a.used_pages) * 8) / 1024.0 AS UsedSpaceMB
    , ( (SUM(a.used_pages) * 8) / 1024.0 ) / 1024.0 AS UsedSpaceGB
    , ( SUM(a.total_pages) - SUM(a.used_pages) ) * 8 AS UnusedSpaceKB
    , ( ( SUM(a.total_pages) - SUM(a.used_pages) ) * 8 ) / 1024.0 AS UnusedSpaceMB
    , ( ( ( SUM(a.total_pages) - SUM(a.used_pages) ) * 8 ) / 1024.0) / 1024.0 AS UnusedSpaceGB
	, GROUPING(t.Name) AS groupTable
FROM sys.tables t 
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.NAME NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
GROUP BY s.Name, t.Name, p.Rows WITH ROLLUP
ORDER BY s.Name, t.Name
GO