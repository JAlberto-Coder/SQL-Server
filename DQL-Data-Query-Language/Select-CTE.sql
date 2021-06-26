USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-CTE.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		16-11-2019
-- Descripcion: Sentencia SELECT CON CTE (COMMON TABLE EXPRESSION), recuerda que pueden aplicar sentencias DML despues de un CTE
-- =============================================
-- ¿QUE ES? R = Es una expesion de tabla definida en una consulta de manera temporal
-- ARGUMENTOS:
--	* expression_name
--	* column_name
--	* CTE_query_definition
-- =============================================
-- CTE Comun
-- =============================================
;WITH CTE_Comun(Fecha)
AS
(
	SELECT GETDATE() AS Fecha
)
SELECT YEAR(Fecha) AS Anio, MONTH(Fecha) AS Mes, DAY(Fecha) AS Dia
FROM CTE_Comun;
GO
-- =============================================
-- CTE Con Recursividad
-- =============================================
;WITH CTE_Fibonacci(Nivel, SerieFibonacci, NivelSiguiente)
AS
(
	SELECT 0 AS Nivel
		, 0 AS SerieFibonacci
		, 1 AS NivelSiguiente
	UNION ALL
	SELECT CTE.Nivel + 1
		, CTE.NivelSiguiente
		, CTE.SerieFibonacci + CTE.NivelSiguiente
	FROM CTE_Fibonacci CTE
	WHERE CTE.Nivel < 21
)
SELECT SerieFibonacci
FROM CTE_Fibonacci;
GO