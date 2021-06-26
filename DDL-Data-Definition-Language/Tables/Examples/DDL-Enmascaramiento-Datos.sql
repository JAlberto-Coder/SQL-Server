USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Enmascaramiento-Datos.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		01-11-2019
-- Descripcion: Sentencias DDL para el enmsacaramiento dinamico de datos (DDM) en las columnas de una tabla
-- =============================================
-- DEFINICIONES
--		* Las mascaras de datos nos permiten ocultar datos reservados que se almacenan en nuestra BD
--		* Estas mascaras se administran por usuarios mediante permisos DCL
--		* Existen 3 tipos de mascaras: PARTIAL, DEFAULT, EMAIL, RANDOM
--		* Su gran ventaja es que puede reducir tiempos de desarrollo, pero debe de ser cuidadosamente administrada para que no se pueda extraer informacion
-- =============================================
-- CONSULTAR LAS TABLAS A LAS QUE SE HA APLICADO UNA MASCARA
-- =============================================
SELECT tbl.name AS [Nombre Tabla]
	, c.name AS [Nombre Columna]
	, c.is_masked AS [Tiene Mascara]
	, c.masking_function AS [Funcion de Mascara]
FROM sys.masked_columns AS c
INNER JOIN sys.tables AS tbl ON c.[object_id] = tbl.[object_id]
WHERE is_masked = 1;
-- =============================================
-- CREACION DE UNA MASCARA EN SENTENCIA CREATE TABLE
-- =============================================
DROP TABLE IF EXISTS Proveedores;
GO
CREATE TABLE Proveedores
(
	uuidProveedor UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
	NombreORazonSocial VARCHAR(150) NOT NULL,
	NombresContacto VARCHAR(100) NOT NULL,
	ApellidosContacto VARCHAR(100) MASKED WITH (FUNCTION = 'partial(1, "XXXXXXX", 0)') NULL, -- MASCARA PARCIAL
	Telefono VARCHAR(12) MASKED WITH (FUNCTION = 'default()') NULL, -- MASCARA DEFAULT
	CorreoElectronico VARCHAR(100),
	CONSTRAINT PK_Proveedores_uuidProveedor PRIMARY KEY(uuidProveedor)
);
-- =============================================
-- INSERT DE REGISTROS EN TABLA CON DATOS ENMASCARADOS
-- =============================================
INSERT INTO Proveedores (NombreORazonSocial, NombresContacto, ApellidosContacto, Telefono, CorreoElectronico) VALUES('Cartas Escritas con el Alma', 'Hermann', 'Hesse', '5516147803', 'LaDivinidadEstaEnTi@dominio.net');
INSERT INTO Proveedores (NombreORazonSocial, NombresContacto, ApellidosContacto, Telefono, CorreoElectronico) VALUES('La Vida con Ritmo', 'Steve', 'Prefontaine', '0099118844', 'ElMejorRitmoEs@dominio.com');
INSERT INTO Proveedores (NombreORazonSocial, NombresContacto, ApellidosContacto, Telefono, CorreoElectronico) VALUES('Columpios para Volar', 'Frida', 'Kahlo', '8247911912', 'MisPiesParaQueLosQuiero@dominio.com');
GO
-- =============================================
-- CONSULTAMOS LA TABLA, CLARAMENTE TENEMOS LOS PERMISOS ASI QUE NOS MOSTRARA LOS DATOS
-- =============================================
SELECT uuidProveedor
	, NombreORazonSocial
	, NombresContacto
	, ApellidosContacto
	, Telefono
	, CorreoElectronico
FROM Proveedores WITH(NOLOCK);
GO
-- =============================================
-- MODIFICAMOS LA TABLA PARA AGREGAR OTRA MASCARA
-- =============================================
ALTER TABLE Proveedores ALTER COLUMN CorreoElectronico ADD MASKED WITH (FUNCTION = 'email()'); --MASCARA E-MAIL
-- =============================================
-- CREAMOS UN USUARIO PARA VER EL COMPORTAMIENTO DE LAS MASCARAS
-- =============================================
IF NOT EXISTS(SELECT 1 FROM sys.sysusers WHERE name = 'UsuarioTest') 
BEGIN
	CREATE USER UsuarioTest WITHOUT LOGIN;
END
GO
GRANT SELECT ON Proveedores TO UsuarioTest;
-- =============================================
-- GENERAMOS UN SELECT, EJECUTANDOLO COMO EL USUARIO CREADO
-- =============================================
EXECUTE AS USER = 'UsuarioTest';
SELECT uuidProveedor
	, NombreORazonSocial
	, NombresContacto
	, ApellidosContacto
	, Telefono
	, CorreoElectronico
FROM Proveedores WITH(NOLOCK);
GO
REVERT; -- Nos regresamos a la ejecucion con el usuario anterior
-- =============================================
-- MODIFICAR MASCARA
-- =============================================
ALTER TABLE Proveedores  
ALTER COLUMN ApellidosContacto VARCHAR(100) MASKED WITH (FUNCTION = 'partial(2, "XXXXXXX", 1)');
GO
-- =============================================
-- ELIMINAR UNA MASCARA
-- =============================================
ALTER TABLE Proveedores
ALTER COLUMN Telefono DROP MASKED;
GO