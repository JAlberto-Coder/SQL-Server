USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Diccionario-Datos.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		24-11-2019
-- Descripcion: Sentencia SELECT para generar un diccionario de datos de nuestra base de datos, los campos dependeran de lo que se desea mostrar en este
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

;WITH CTE_Diccionario ([Nombre Tabla], [Nombre Columna], [Llave Primaria])
AS
(
	SELECT OBJECT_NAME(IC.object_id) AS [Nombre Tabla]
		, COL_NAME(IC.object_id, IC.column_id) AS [Nombre Columna]
		, I.[name] AS [Llave Primaria]
	FROM sys.indexes I 
	INNER JOIN sys.index_columns IC ON I.object_id = IC.object_id AND I.index_id = IC.index_id AND I.is_primary_key = 1
)
SELECT SCHEMA_NAME(T.schema_id) AS [Nombre Esquema]
	, T.[name] AS [Nombre Tabla]
	, C.[name] AS [Nombre Columna]
	, ST.[name] AS [Tipo de Dato]
	, C.max_length AS [Longitud Maxima]
	, COALESCE(ST.collation, '') AS [Collation]
	, COALESCE((SELECT 'Si' FROM sys.objects WHERE object_id = C.default_object_id), 'No') AS [Tiene Valor Por Defecto]
	, IIF(C.is_identity = 1, 'Si', 'No') AS [Es Autonumerico]
	, IIF(C.is_nullable = 1, 'Si', 'No') AS [Permite Nulos]
	, COALESCE(D.[Llave Primaria],'No') AS [Llave Primaria]
	, COALESCE(F.ForeignKey, '') AS [Llave Foranea]
	, COALESCE(F.ReferenceTableName,'') AS [Tabla de Referencia]
	, COALESCE(F.ReferenceColumnName,'') AS [Columna de Referencia]
	, COALESCE(EP.[value], '') AS Descripcion
	, T.create_date AS [Fecha Creacion]
FROM sys.tables T
INNER JOIN sys.columns C ON T.object_id = C.object_id
INNER JOIN sys.systypes ST ON C.system_type_id = ST.xtype
LEFT OUTER JOIN sys.extended_properties EP ON T.object_id = EP.major_id AND C.column_id = EP.minor_id
LEFT OUTER JOIN CTE_Diccionario D ON T.[name] = D.[Nombre Tabla] AND C.[name] = D.[Nombre Columna]
LEFT OUTER JOIN (SELECT FK.[name] AS ForeignKey, OBJECT_NAME(FK.parent_object_id) AS TableName, COL_NAME(FKC.parent_object_id, FKC.parent_column_id) AS ColumnName, OBJECT_NAME(FK.referenced_object_id) AS ReferenceTableName, COL_NAME(FKC.referenced_object_id, FKC.referenced_column_id) AS ReferenceColumnName
				 FROM sys.foreign_keys AS FK 
				 INNER JOIN sys.foreign_key_columns AS FKC ON FK.object_id = FKC.constraint_object_id) AS F ON F.TableName = T.[name] AND f.ColumnName = C.[name]
ORDER BY T.[name], C.column_id;
GO