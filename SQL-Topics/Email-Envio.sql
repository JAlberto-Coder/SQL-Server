USE msdb
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Email-Envio.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		11-02-2020
-- Descripcion: Utilizacion de un SP para el envio de correo previamente configurado
-- Informacion: Database Mail es una característica disponible desde SQL Server 2005
-- ==================================================
EXEC dbo.sp_send_dbmail
    @profile_name = 'AdministradorSQL',  
    @recipients = 'correoElectronico@empresa.com',  
    @body = 'Prueba de envio de correo sp_send_dbmail',  
    @subject = 'Test SEND EMAIL';
GO
-- ==================================================
-- REVISION DE BITÁCORA DE CORREOS ENVIADOS Y BITÁCORA DE EVENTOS
-- ==================================================
SELECT * 
FROM dbo.sysmail_mailitems;
GO

SELECT * 
FROM dbo.sysmail_log;
GO