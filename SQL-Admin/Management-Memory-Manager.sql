USE master
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Management-Memory-Manager.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		19-03-2020
-- Descripcion: Sentencias para bajar la memoria de la instancia, esta se bajará en caso de no estár utilizando páginas
-- =============================================
-- Se reconfigura la memoria asignada al servidor, a un valor menor
-- =============================================
BEGIN TRY

    EXEC sys.sp_configure N'show advanced options', N'1' RECONFIGURE WITH OVERRIDE;
    EXEC sys.sp_configure N'max server memory (MB)', N'4000';
    RECONFIGURE WITH OVERRIDE;
    EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE;
    WAITFOR DELAY '00:01:00';
	
END TRY
BEGIN CATCH

	PRINT 'ERROR';
	
END CATCH
GO
 -- =============================================
 -- Se restablece la memoria asignada a la instancia
 -- =============================================
EXEC sys.sp_configure N'show advanced options', N'1' RECONFIGURE WITH OVERRIDE;
EXEC sys.sp_configure N'max server memory (MB)', N'6000';
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE;
GO