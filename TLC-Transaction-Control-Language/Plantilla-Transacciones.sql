USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Plantilla-Transacciones.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		27-10-2019
-- Descripcion: Plantilla para el manejo de transacciones, esto para practicamente realizar las sentencias necesarias y enviar a su ejecucion
-- =============================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT OFF;

BEGIN TRANSACTION
BEGIN TRY
	-- AQUI PONER LAS OPERACIONES
	PRINT 'COMENZAR LAS OPERACIONES';

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	-- EN CASO DE AGREGAR ALGUN LOG EN CASO DE ERROR AGREGAR AQUI
	ROLLBACK TRANSACTION;
	PRINT 'ERROR NUMBER:    ' + CAST(ERROR_NUMBER() AS VARCHAR);
	PRINT 'ERROR STATE:     ' + CAST(ERROR_STATE() AS VARCHAR);
	PRINT 'ERROR SEVERITY:  ' + CAST(ERROR_SEVERITY() AS VARCHAR);
	PRINT 'ERROR PROCEDURE: ' + COALESCE(CAST(ERROR_PROCEDURE() AS VARCHAR), 'NA');
	PRINT 'ERROR LINE:      ' + CAST(ERROR_LINE() AS VARCHAR);
	PRINT 'ERROR MESSAGE:   ' + ERROR_MESSAGE();
END CATCH
GO