USE Developer;
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Maintenance-Statistics.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		04-11-2020
-- Descripcion:	Script de utilidad para actualizar estadisticas de optimizacion de consultas en una tabla o vista indizada
-- ==================================================
-- ACTUALIZAR ESTADISTICAS A UN OBJETO EN CONCRETO
-- ==================================================
UPDATE STATISTICS dbo.Developers Indice_Developers_FechaIngreso;
GO
-- ==================================================
-- ACTUALIZAR TODAS LAS ESTADISTICAS DE UNA SOLA TABLA
-- ==================================================
UPDATE STATISTICS dbo.Developers;
GO
-- ==================================================
-- ACTUALIZAR TODAS LAS ESTADISTICAS DE TODA UNA BASE DE DATOS
-- ==================================================
EXEC sp_updatestats;
GO