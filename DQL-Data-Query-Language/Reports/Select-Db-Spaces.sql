USE master
GO
-- =======================================================
-- Version:		1.0.0
-- Archivo:		Select-Db-Spaces.sql
-- =======================================================
-- Autor:		JAlberto-Coder
-- Fecha:		24-03-2021
-- Descripcion: Consultas para extraer información relevante a los tamaños de las bases de datos
-- =======================================================
-- Espacio utilizado por cada base de datos, con su data y su log
-- =======================================================
;WITH CTE
AS
(
    SELECT database_id, type, size * 8.0 / 1024 size
    FROM sys.master_files
)
SELECT TOP(10)
    name
    , CAST((SELECT SUM(size) FROM CTE WHERE type = 0 and CTE.database_id = db.database_id) AS DECIMAL(18, 2)) AS data_file_size_MB
    , CAST((SELECT SUM(size) FROM CTE WHERE type = 1 and CTE.database_id = db.database_id) AS DECIMAL(18, 2)) AS log_file_size_MB
	, CAST((SELECT SUM(size) FROM CTE WHERE type = 0 and CTE.database_id = db.database_id) / 1014 AS DECIMAL(18, 2)) AS data_file_size_GB
    , CAST((SELECT SUM(size) FROM CTE WHERE type = 1 and CTE.database_id = db.database_id) / 1024 AS DECIMAL(18, 2)) AS log_file_size_GB
FROM sys.databases db
WHERE database_id > 4
ORDER BY data_file_size_MB DESC;
GO
-- =======================================================
-- Consulta que trae el espacio que se esta utilizando realmente sobre el tamaño asignado a la base de datos
-- =======================================================
DROP TABLE IF EXISTS #DataBases_Size;
GO
CREATE TABLE #DataBases_Size
(
    database_id INT, 
	database_name SYSNAME,
	name SYSNAME,
    physical_name NVARCHAR(500),
    size DECIMAL(18,2),
    free_space DECIMAL(18,2),
	type BIT
);
GO
EXEC sp_msforeachdb 
'
	Use [?];
	INSERT INTO #DataBases_Size(database_id, database_name, name, physical_name, size, free_space, type)
    SELECT DB_ID() 
		, DB_NAME()
		, name
		, physical_name
		, TRY_CONVERT(NVARCHAR, CAST(ROUND(CAST(size AS decimal) * 8.0 / 1024.0, 2) AS decimal(18,2))) AS size
		, TRY_CONVERT(NVARCHAR, CAST(ROUND(CAST(size AS decimal) * 8.0 / 1024.0, 2) AS DECIMAL(18,2)) 
			- CAST(FILEPROPERTY(name, ''SpaceUsed'') * 8.0 / 1024.0 AS DECIMAL(18,2))) AS free_space
		, type
    FROM sys.database_files;
';

SELECT database_name AS name
	, CAST(SUM(size / 1024) AS DECIMAL(18, 2)) AS size_GB
	, CAST(SUM(free_space / 1024) AS DECIMAL(18, 2)) AS free_space_GB
FROM #DataBases_Size
WHERE database_id NOT IN(1,2,3,4) -- REMOVER FILTRO EN CASO DE QUERER VISUALIZAR LAS BD POROPIAS DE LA INSTANCIA
GROUP BY database_name
ORDER BY size_gb DESC;
GO

DROP TABLE IF EXISTS #DataBases_Size;
GO
-- =======================================================
-- Espacio Utilizado por cada FileGroup
-- =======================================================
SELECT DB_NAME([database_id]) AS [database_name]
	, [file_id]
	, [name]
	, physical_name
	, [type_desc]
	, state_desc
	, is_percent_growth
	, growth
	, CONVERT(BIGINT, growth/128.0) AS [growth_MB]
	, CONVERT(BIGINT, size/128.0) AS [size_MB]
	, CONVERT(BIGINT, (size/128.0) / 1024)  AS [size_GB]
	, max_size
FROM sys.master_files WITH (NOLOCK)
ORDER BY DB_NAME([database_id]), [file_id] OPTION (RECOMPILE);
GO
-- =======================================================
-- Espacio Disponible por cada unidad que contiene la instancia
-- =======================================================
SELECT DISTINCT SUBSTRING(volume_mount_point, 1, 1) AS unidad
    , (total_bytes/1024/1024)/1024 AS total_GB
    , (available_bytes/1024/1024)/1024 AS total_free_GB
    , ISNULL(ROUND(available_bytes / CAST(NULLIF(total_bytes, 0) AS FLOAT) * 100, 2), 0) AS percent_free
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
ORDER BY percent_free;
GO