USE Developer
GO

-- ==================================================
-- Versi�n:		1.0.0
-- Archivo:		DDL-Create-Schema.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		29-09-2021
-- Descripci�n:	Sentencias para la creaci�n de esquemas sobre SQL Server
-- ==================================================
CREATE SCHEMA cat AUTHORIZATION dbo;
GO

SELECT *
FROM sys.schemas
GO

CREATE TABLE cat.Paises(
	ClavePais VARCHAR(3) NOT NULL CONSTRAINT PK_catPaises_ClavePais PRIMARY KEY,
	NombrePais VARCHAR(150) NOT NULL
);

DROP TABLE cat.Paises;
GO

DROP SCHEMA cat;
GO