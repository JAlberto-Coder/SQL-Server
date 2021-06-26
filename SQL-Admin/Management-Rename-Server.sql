USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Management-Rename-Server.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		11-02-2020
-- Descripcion: Sentencias para renombrar el nombre se la instancia
-- =============================================
-- CONSULTAR EL NOMBRE SEL SERVIDOR
-- =============================================
SELECT @@SERVERNAME;
GO
-- =============================================
-- ELIMINAR EL SERVIDOR ACTUAL EN EL QUE SE ENCUENTRA SQL SERVER
-- =============================================
sp_dropserver 'WORKSTATION';
GO
-- =============================================
-- AGREGAR EL NUEVO SERVIDOR DE SQL SERVER
-- =============================================
sp_addserver 'SERVER1-SQL', 'local';
GO