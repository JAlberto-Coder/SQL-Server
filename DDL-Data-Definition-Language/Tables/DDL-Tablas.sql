USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Tablas.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		19-11-2019
-- Descripcion: Sentencias CREATE, ALTER, TRUNCATE, y DROP para la Definicion de tablas en una base de datos
-- =============================================
-- CREACION DE UNA TABLA
-- =============================================
IF OBJECT_ID('CatMonedas', 'U') IS NULL
BEGIN
	CREATE TABLE CatMonedas
	(
		ClaveMoneda VARCHAR(3) NOT NULL,
		Moneda VARCHAR(50) NOT NULL,
		FechaGeneracion DATETIME DEFAULT(GETDATE()) NOT NULL,
		UsuarioGeneracion VARCHAR(50) DEFAULT('SYSTEM') NOT NULL
	);
	PRINT 'TABLA CatMonedas CREADA';
END;
GO
-- =============================================
-- MODIFICACION DE UNA TABLA, AGREGANDO UNA COLUMA
-- =============================================
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'CatMonedas' AND COLUMN_NAME = 'Estatus')
BEGIN
	ALTER TABLE CatMonedas
	ADD Estatus BIT DEFAULT(0) NOT NULL;
	PRINT 'COLUMNA Estatus AGREGADA';
END;
GO
-- =============================================
-- MODIFICACION DE UNA TABLA, AGREGANDO UNA LLAVE PRIMARIA
-- =============================================
IF OBJECT_ID('PK_CatMonedas_ClaveMoneda', 'PK') IS NULL
BEGIN
	ALTER TABLE CatMonedas
	ADD CONSTRAINT PK_CatMonedas_ClaveMoneda PRIMARY KEY(ClaveMoneda);
	PRINT 'LLAVE PRIMARIA PK_CatMonedas_ClaveMoneda AGREGADA';
END;
GO
-- =============================================
-- MODIFICACION DE UNA TABLA, MODIFICANDO UNA COLUMA
-- =============================================
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'CatMonedas' AND COLUMN_NAME = 'Estatus')
BEGIN
	ALTER TABLE CatMonedas
	ALTER COLUMN Moneda VARCHAR(60) NOT NULL;
	PRINT 'COLUMNA Moneda MODIFICADA';
END;
GO
-- =============================================
-- TRUNCATE TABLA, Asegurate que no haya relacion para que no exista error
-- =============================================
TRUNCATE TABLE CatMonedas;
GO
PRINT 'TABLA CatMonedas TRUNCADA';
GO
-- =============================================
-- ELIMINACION DE LA TABLA
-- =============================================
IF OBJECT_ID('CatMonedas', 'U') IS NOT NULL
BEGIN
	DROP TABLE CatMonedas;
	PRINT 'TABLA CatMonedas ELIMINADA';
END;
GO