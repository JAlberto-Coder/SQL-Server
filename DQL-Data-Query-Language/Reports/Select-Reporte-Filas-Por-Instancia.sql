USE [master]
GO

-- ==================================================
-- Version:		1.0.0
-- Archivo:		Select-Reporte-Cantidad-Filas.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		11-10-2021
-- Descripción:	Consulta para sacar la cantidad de filas que contiene una instancia
-- ==================================================
CREATE TABLE #Tbl_Filas_Por_Instancia (
	Base_datos SYSNAME NOT NULL,
	Tabla VARCHAR(256) NOT NULL,
	Cantidad_Filas BIGINT NULL
);

INSERT INTO #Tbl_Filas_Por_Instancia(Base_datos, Tabla, Cantidad_Filas)
EXEC sys.sp_msforeachdb 'USE [?];
;WITH CTE AS 
(
	SELECT
		(row_number() over(order by a3.name, a2.name))%2 as l1,
		a3.name AS [schemaname],
		a2.name AS [tablename],
		a1.rows as row_count,
		(a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved, 
		a1.data * 8 AS data,
		(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS index_size,
		(CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS unused
	FROM
		(SELECT 
			ps.object_id,
			SUM (
				CASE
					WHEN (ps.index_id < 2) THEN row_count
					ELSE 0
				END
				) AS [rows],
			SUM (ps.reserved_page_count) AS reserved,
			SUM (
				CASE
					WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
					ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
				END
				) AS data,
			SUM (ps.used_page_count) AS used
		FROM sys.dm_db_partition_stats ps
			WHERE ps.object_id NOT IN (SELECT object_id FROM sys.tables WHERE is_memory_optimized = 1)
		GROUP BY ps.object_id) AS a1
	LEFT OUTER JOIN 
		(SELECT 
			it.parent_id,
			SUM(ps.reserved_page_count) AS reserved,
			SUM(ps.used_page_count) AS used
		 FROM sys.dm_db_partition_stats ps
		 INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
		 WHERE it.internal_type IN (202,204)
		 GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
	INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id ) 
	INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
	WHERE a2.type <> N''S'' and a2.type <> N''IT''
)
SELECT DB_NAME() AS BaseDatos, [schemaname] + ''.''  + [tablename], ISNULL(row_count, 0) AS Filas
FROM CTE';
GO

-- ==================================================
-- CANTIDAD DE FILAS POR INSTANCIA
-- ==================================================
SELECT SERVERPROPERTY('MachineName') AS Hostname
	, @@SERVERNAME AS Instancia
	, SUM(Cantidad_Filas) AS Cantidad_Filas
FROM #Tbl_Filas_Por_Instancia
GO

-- ==================================================
-- CANTIDAD DE FILAS POR BASE DE DATOS
-- ==================================================
SELECT SERVERPROPERTY('MachineName') AS Hostname
	, @@SERVERNAME AS Instancia
	, Base_datos
	, SUM(Cantidad_Filas) AS Cantidad_Filas
FROM #Tbl_Filas_Por_Instancia
GROUP BY Base_datos
GO

-- ==================================================
-- CANTIDAD DE FILAS POR BASE DE DATOS Y POR CADA TABLA
-- ==================================================
SELECT SERVERPROPERTY('MachineName') AS Hostname
	, @@SERVERNAME AS Instancia
	, Base_datos
	, Tabla
	, SUM(Cantidad_Filas) AS Cantidad_Filas
FROM #Tbl_Filas_Por_Instancia
GROUP BY Base_datos, Tabla

DROP TABLE #Tbl_Filas_Por_Instancia
GO