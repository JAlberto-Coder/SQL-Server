USE [master]
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Maintenance-Log-Truncate.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		12-03-2019
-- Descripcion: Sentencias para liberar el espacio ocupado por los logs de una base de datos
-- =============================================
-- Para base con mismo en el archivo principal y el log nombrado con _log
DECLARE @Query NVARCHAR(1000) = ''
	, @NombreBase VARCHAR(100) = 'Developer';

SELECT @Query = 'ALTER DATABASE [' + @NombreBase + '] SET RECOVERY SIMPLE WITH NO_WAIT; 
---------------------------------------------
USE [' + @NombreBase + '] 
DBCC SHRINKFILE (N''' + @NombreBase + '_log'' , 10); 
--------------------------------------------- 
USE [master]
ALTER DATABASE [' + @NombreBase + '] SET RECOVERY FULL WITH NO_WAIT;';
PRINT @Query;
EXEC sp_executesql @Query;
GO