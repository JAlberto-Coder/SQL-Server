-- ==================================================
-- Version:		1.0.0
-- Archivo		DCL-Autentificacion.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		10-02-2020
-- Descripcion: Sentencias para administrar usuarios como 
-- ==================================================
USE [master]
GO
-- ==================================================
-- CREACION DE UN LOGIN
-- ==================================================
CREATE LOGIN Developer 
WITH PASSWORD = 'Developer123';
GO
-- ==================================================
-- CREACION DE USUARIO PARA EL LOGIN Developer
-- ==================================================
USE Developer;
GO
CREATE USER Developer FOR LOGIN Developer
WITH DEFAULT_SCHEMA = dbo;
GO
-- ==================================================
-- DAR PERMISOS DE MANERA INDIVIDUAL
-- ==================================================
GRANT CREATE TABLE TO Developer;
GRANT SELECT TO Developer;
-- ==================================================
-- DENEGAR PERMISOS DE MANERA INDIVIDUAL
-- ==================================================
DENY CREATE TABLE TO Developer;
DENY SELECT TO Developer;
-- ==================================================
-- REVOCAR PERMISOS DE MANERA INDIVIDUAL
-- ==================================================
REVOKE CREATE TABLE TO Developer;
REVOKE SELECT TO Developer;
-- ==================================================
-- ASIGNACION DE ROLES EN LA BD
-- ==================================================
EXEC sp_addsrvrolemember 'Developer', 'Sysadmin';
GO
-- ==================================================
-- QUITAR ROLES EN LA BD
-- ==================================================
EXEC sp_dropsrvrolemember 'Developer', 'Sysadmin';
GO
-- ==================================================
-- ASIGNACION DE MAPPING EN LA BD
-- ==================================================
EXEC sp_addrolemember 'db_datareader', 'Developer';
GO
EXEC sp_addrolemember 'db_datawriter', 'Developer';
GO
-- ==================================================
-- EJECUTAR SENTENCIAS COMO UN USUARIO REGISTRADO
-- ==================================================
EXECUTE AS USER = 'Developer';
GO
-- ==================================================
-- HABILITAR Y DESHABILITAR USUARIOS
-- ==================================================
GRANT CONNECT TO guest;
GO
REVOKE CONNECT TO guest;
GO