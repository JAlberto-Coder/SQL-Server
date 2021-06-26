USE master
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Maintenance-Index.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		04-11-2020
-- Descripcion:	Script con el que se pueden realizar validaciones para verificar si una reconstrucción de indice es necesaria
-- ==================================================
-- CONSULTA Y GENERACIÓN DE SENTENCIAS PARA ACTUALIZAR INDICES
-- Si está fragmentado menos de un 10% no es necesario hacer nada
-- Si está fragmentado entre un 10% y un 30% es mejor reoganizar el índice
-- Si está fragmentado más de un 30% es mejor reconstruir el índice
-- ==================================================
SELECT GETDATE() AS Fecha
	, @@SERVERNAME AS Servidor
	, DB_NAME(DB_ID()) AS BaseDeDatos
	, i.name AS NombreIndice
	, o.name AS ObjetoDueno
	, IIF(dbi.avg_fragmentation_in_percent > 30, 'ALTER INDEX ' + i.name + ' ON ' + o.name + ' REBUILD', 'ALTER INDEX ' + i.name + ' ON ' + o.name + ' REORGANIZE') AS Sentencia
	, dbi.avg_fragmentation_in_percent AS 'Porcentaje Frag'
	, dbi.page_count AS NumeroPaginas
	, dbi.fragment_count AS PromPagFrag
	, dbi.index_type_desc AS TipoIndice
	, dbi.avg_fragment_size_in_pages AS FragmentacionPaginas
	, dbi.partition_number AS NumeroParticion
FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'limited') AS dbi
INNER JOIN sys.indexes AS i ON dbi.object_id = i.object_id AND dbi.index_id = i.index_id
INNER JOIN sys.objects AS o ON dbi.object_id = o.object_id
--WHERE o.name = 'Table'
ORDER BY 'Porcentaje Frag' DESC;
GO
-- ==================================================
-- VERIFICACIÓN DE TABLAS QUE NO CONTIENEN UN INDICE CLUSTERIZADO (AQUÍ SE RECOMENDARIA GENERAR UN INDICE CLUSTERIZADO)
-- ==================================================
SELECT OBJECT_NAME(I.object_id) AS Tabla
      , I.name AS Indice
	  , P.rows AS NumeroDeFilas
	  , I.type_desc AS TipoDeIndice
FROM sys.partitions P
INNER JOIN sys.indexes I ON P.object_id = I.object_id AND P.index_id = I.index_id AND I.type = 0
INNER JOIN sys.tables T ON T.object_id = I.object_id AND T.type = 'U';
GO
-- ==================================================
-- LA FUNCION: Sys.dm_db_index_physical_stats REEMPLAZA A LA SENTENCIA DBCC SHOWCONTIG;
-- ==================================================
DBCC SHOWCONTIG;
GO
-- ==================================================
-- SELECT QUE DEVUELVE INFORMACION DE TAMANO Y FRAGMENTACION DE LOS DATOS Y LOS INDICES DE LAS TABLAS O VISTAS
-- ==================================================
-- NOTA: EN CASO DE CONSULTAR LA FUNCION: Sys.dm_db_index_physical_stats, EN UN AMBIENTE EN ALWAYS ON, SEGURAMENTE SE PRODUCIRAN BLOQUEOS SOBRE LOS OBJETOS CONSULTATOS
-- ==================================================
SELECT O.name AS Objeto
    , IPS.partition_number AS NumeroParticion
    , IPS.index_type_desc AS TipoIndice
    , IPS.record_count AS Registros
	, IPS.avg_record_size_in_bytes AS PromedioTamanioBytes
    , IPS.min_record_size_in_bytes AS MinimoTamanioBytes
    , IPS.max_record_size_in_bytes AS MaximoTamanioBytes
    , IPS.page_count AS Paginas
	, IPS.compressed_page_count AS PaginasComprimidas
FROM sys.dm_db_index_physical_stats
	(
		DB_ID(N'Developer') -- id de base de datos  { database_id | NULL | 0 | DEFAULT }
		, NULL				-- id de tabla			{ object_id | NULL | 0 | DEFAULT }
		, NULL				-- id de indice			{ index_id | NULL | 0 | -1 | DEFAULT }
		, NULL				-- numero de particion	{ partition_number | NULL | 0 | DEFAULT }
		, 'DETAILED'		-- modo					{ mode | NULL | DEFAULT }
	) IPS
JOIN sys.objects O ON O.object_id = IPS.object_id
ORDER BY record_count DESC;
GO