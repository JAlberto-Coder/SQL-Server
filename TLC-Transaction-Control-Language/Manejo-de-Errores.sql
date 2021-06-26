USE [master]
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Manejo-de-Errores.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		14-11-2019
-- Descripcion: Mostrar el Manejo de Errores en SQL Server, Creacion, Eliminacion, Llamado
-- =============================================
-- CONSULTA DE LOS MENSAJES DE ERROR DEFINIDOS POR LA INSTANCIA, Y POR LOS USUARIOS
-- =============================================
SELECT message_id, language_id, severity, is_event_logged, [text]
FROM [master].sys.messages
WHERE message_id = 13000
GO
-- NOTA: SI QUISIERAMOS VER LOS MENSAJE EN ESPAÑOL PODRIAMOS EJECUTAR LA SIGUIENTE SENTENCIA 
SELECT m.message_id, m.language_id, m.severity, m.is_event_logged, m.[text]
FROM [master].sys.messages m
INNER JOIN [master].sys.syslanguages l ON m.language_id = l.msglangid 
WHERE l.alias = 'Spanish'
ORDER BY m.message_id;
GO
-- =============================================
-- CREACION DE UN MENSAJE DE ERROR DEFINIDO POR EL USUARIO
-- =============================================
-- NOTA: PARA EL EJEMPLO SE CREARA UN SIMPLE ERROR, PERO SE ASIGNAREMOS UN NUMERO DE ERROR QUE NO EXISTA
EXEC sp_addmessage 
	@msgnum = 50001,
	@severity = 16,
	@msgtext = N'Error, la division entre 0 no esta definida',
	@lang = N'English';
GO
-- =============================================
-- CREACION DE UN MENSAJE DE ERROR, EN ESPAÑOL
-- =============================================
EXEC sp_addmessage 
	@msgnum = 50001,
	@severity = 16,
	@msgtext = N'Error, la division entre 0 no esta definida',
	@lang = N'Spanish';
GO
-- =============================================
-- INVOCACION DE UN ERROR CON REISEERROR
-- =============================================
-- Con la instruccion REISERROR podemos invocar un error, consultamos el error agregado
RAISERROR(50001, 16, 1);
GO
SET LANGUAGE Spanish; -- Puedes cambiar la configuracion del idioma para verlo al que tu desees
RAISERROR(50001, 16, 1);
GO
-- =============================================
-- INVOCACION DE UN ERROR CON THROW
-- =============================================
-- Con la instruccion THROW podemos invocar un error que no necesariamente se encuentra registrado, es difectamente
THROW 50002, 'Ha ocurrido un error', 16;
GO
-- =============================================
-- EJEMPLO DENTRO DE UN TRY Y CATCH
-- =============================================
BEGIN TRY
	SELECT 1/0 AS Resultado;
	SELECT @@ERROR; -- Instruccion que devuelve el numero de error de la ultima transaccion
END TRY
BEGIN CATCH
	RAISERROR(50001,16,1);
	SELECT 
		ERROR_NUMBER() AS NUMEROERROR,
		ERROR_SEVERITY() AS NUMEROSEVERIDAD,
		ERROR_STATE() AS NUMEROESTADO,
		ERROR_PROCEDURE() AS PROCEDIMIENTOERROR,
		ERROR_MESSAGE() AS MENSAJEERROR
END CATCH
GO
-- =============================================
-- ELIMINACION DE UN MENSAJE DE ERROR DEFINIDO POR EL USUARIO
-- =============================================
EXEC sp_dropmessage 
	@msgnum = 50001, 
	@lang = 'Spanish';
GO
EXEC sp_dropmessage 
	@msgnum = 50001, 
	@lang = 'English';
GO