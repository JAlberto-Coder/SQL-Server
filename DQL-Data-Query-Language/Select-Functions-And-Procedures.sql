USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Functions-And-Procedures.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-12-2019
-- Descripcion: Consulta los Store Procedures que existen en una base de datos
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
-- =============================================
-- CONSULTA QUE DEVUELVE LAS FUNCIONES EXISTENTES EN LA BASE DE DATOS ACTUAL
-- =============================================
SELECT ROUTINE_CATALOG
	, ROUTINE_SCHEMA
	, ROUTINE_NAME
	, ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;
GO
-- =============================================
-- CONSULTA QUE DEVUELVE LOS PROCEDIMIENTOS EXISTENTES EN LA BASE DE DATOS ACTUAL
-- =============================================
SELECT ROUTINE_CATALOG
	, ROUTINE_SCHEMA
	, ROUTINE_NAME
	, ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
GO