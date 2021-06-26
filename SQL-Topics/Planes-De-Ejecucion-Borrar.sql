USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Planes-De-Ejecucion-Borrar.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-12-2019
-- Descripcion: Sentencias para borrar planes de ejecucion para que las consultas o sentencias no se almacenen y veamos el tiempo real de ejecucion
-- =============================================
DBCC FREEPROCCACHE WITH NO_INFOMSGS;
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;
GO

SELECT COUNT(1) AS TotalRegistros
FROM dbo.Encabezado WITH(NOLOCK);
GO

SELECT COUNT(1) AS TotalRegistros
FROM dbo.Detalle WITH(NOLOCK)
GO