USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Management-Encriptacion-BD.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		26-06-2021
-- Descripcion: Generación de certificado para copias de seguridad
-- =============================================
-- PRE-REQUISITOS para Cifrado de Copias de Seguridad de SQL Server
-- * Verificar si ya existe una "clave maestra de servicio"
-- * Verificar si ya existe una "clave maestra de base de datos en la base de datos maestra"
-- =============================================
-- CONSULTA CLAVE MAESTRA
-- =============================================
-- Como una clave maestra de servicio es generada automáticamente durante la instalación de SQL Server, 
-- debería ya estar contenida en la base de datos maestra. La presencia de SMK y DMK es revisada consultando 
-- la vista de catálogo master.sys.symmetric_keys y buscando la fila ##MS_DatabaseMasterKey## en los resultados:
-- =============================================
SELECT * FROM master.sys.symmetric_keys;
GO
-- =============================================
-- Si la fila ##MS_DatabaseMasterKey## no existe, use la siguiente consulta para crearla:
-- =============================================
-- CREACIÓN DE LLAVE MAESTRA PARA BASE DE DATOS
-- =============================================
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Database123#';
GO
-- =============================================
-- CONSULTA CERTIFICADO
-- =============================================
SELECT * FROM sys.certificates;
GO
-- =============================================
-- CREACION DE UN CERTIFICADO
-- =============================================
CREATE CERTIFICATE CERT_CERTIFICADOS_DE_SEGURIDAD
WITH SUBJECT = 'SQL Server 2019 CERTIFICADO DE SEGURIDAD';
GO
-- =============================================
-- RESPALDAR CERTIFICADO Y CLAVES MAESTRAS
-- =============================================
-- Respaldar la Clave Maestra de Servicio (Backup the Service Master Key):
BACKUP SERVICE MASTER KEY
TO FILE = 'C:\MSSQL\SECURITY\SQL2019_CMS.key'
ENCRYPTION BY PASSWORD = 'Database123#';
GO
-- Respaldar la Clave Maestra de Base de Datos (Backup the Database Master Key):
BACKUP MASTER KEY
TO FILE = 'C:\MSSQL\SECURITY\SQL2019_CMB.key'
ENCRYPTION BY PASSWORD = 'Database123#';
GO
-- Respaldar el Certificado:
BACKUP CERTIFICATE CERTIFICADOSEGURIDAD
TO FILE = 'C:\MSSQL\SECURITY\SQL2019_CERTIFICADODERESPALDO.cer'
WITH PRIVATE KEY
(
	FILE = 'C:\MSSQL\SECURITY\SQL2019_LC.key'
    , ENCRYPTION BY PASSWORD = 'Database123#'
);
GO
-- =============================================
-- EJEMPLO
-- =============================================
USE Developer
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE CERT_CERTIFICADOS_DE_SEGURIDAD;
GO

ALTER DATABASE Developer
SET ENCRYPTION ON;
GO

-- =============================================
-- SENTENCIAS PARA ELIMINAR CLAVE MAESTRA Y CLAVE MAESTRA DE BD
-- =============================================
-- DROP MASTER KEY;
-- DROP CERTIFICATE CERT_CERTIFICADOS_DE_SEGURIDAD;
-- GO