USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-TOP-Invertido.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		13-11-2019
-- Descripcion: Sentencia TOP en SELECT, para tomar los ultimos registros en el caso presentado serán los ultimos 5 registros
-- =============================================
-- 1. Para el ejemplo utilizado utilizaremos una tabla llamada CatPaises
-- =============================================
IF OBJECT_ID('CatPaises', 'U') IS NULL
BEGIN
	CREATE TABLE CatPaises
	(
		ClavePais VARCHAR(3) NOT NULL,
		Pais VARCHAR(100) NOT NULL,
		Agrupacion VARCHAR(50) NULL,
		FormatoCodigoPostal VARCHAR(100) NULL,
		RegexCodigoPostal NVARCHAR(100) NULL,
		FechaGeneracion DATETIME DEFAULT GETDATE() NOT NULL,
		UsuarioGeneracion VARCHAR(60) DEFAULT 'SYSTEM' NOT NULL,
		Estatus BIT DEFAULT 1 NOT NULL,
		CONSTRAINT PK_CatPaises_ClavePais PRIMARY KEY(ClavePais)
	);
	PRINT 'TABLA CREADA';
END
GO
-- =============================================
-- 2. Claramente le insertaremos mas de 5 registros
-- =============================================
IF ((SELECT COUNT(1) FROM CatPaises WITH(NOLOCK)) = 0)
BEGIN
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AFG','Afganistán',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ALA','Islas Åland',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ALB','Albania',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('DEU','Alemania','Unión Europea');
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AND','Andorra',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AGO','Angola',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AIA','Anguila',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ATA','Antártida',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ATG','Antigua y Barbuda',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('SAU','Arabia Saudita',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('DZA','Argelia',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ARG','Argentina',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ARM','Armenia',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('ABW','Aruba',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AUS','Australia',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AUT','Austria','Unión Europea');
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('AZE','Azerbaiyán',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BHS','Bahamas (las)',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BGD','Bangladés',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BRB','Barbados',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BHR','Baréin',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BEL','Bélgica','Unión Europea');
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BLZ','Belice',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BEN','Benín',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BMU','Bermudas',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BLR','Bielorrusia',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('MMR','Myanmar',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BOL','Bolivia, Estado Plurinacional de',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BIH','Bosnia y Herzegovina',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BWA','Botsuana',NULL);
	INSERT INTO CatPaises(ClavePais, Pais, Agrupacion) VALUES('BRA','Brasil',NULL);
	PRINT 'REGISTROS INSERTADOS';
END
GO
-- =============================================
-- 3. SELECT CON TOP INVERTIDO
-- NOTA: Si tu tabla contiene demasiados registros, no se recomienda utilizar el query siguiente ya que tardaria mucho, deberias de utilizar otro recurso o reducir tu consulta con alguna condicion
-- =============================================
SELECT ClavePais, Pais, Agrupacion, FormatoCodigoPostal, RegexCodigoPostal
FROM CatPaises WITH(NOLOCK)
WHERE ClavePais NOT IN
	(
		SELECT TOP ((SELECT COUNT(1) FROM CatPaises WITH(NOLOCK)) - 5) ClavePais
		FROM CatPaises WITH(NOLOCK)
	);
GO
PRINT 'FIN DEL SCRIPT';