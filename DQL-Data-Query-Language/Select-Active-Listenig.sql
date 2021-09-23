USE master
GO
-- ========================================
-- Version: 	1.0.0
-- Archivo: 	Select-Active-Listenig.sql
-- ========================================
-- Autor: 		JAlberto-Coder
-- Fecha: 		23-09-2021
-- Descripcion:	Sentencia para visualizar las IPs y puertos que escuchan para realizar la conexión a nuestra instancia
-- ========================================
EXEC sys.xp_readerrorlog 0, 1, N'Server is listening on';
GO