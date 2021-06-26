USE Developer;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Version: 	1.0.0.0
-- Arhivo: 		Columna-Set-Descripcion.sql
-- =============================================
-- Autor: 		JAlberto-Coder
-- Fecha: 		12-11-2019
-- Descripcion: Creación de un SP que reciba tres parametros @Tabla, @Columna, @DescripcionColumna, para que se actualice la descripción de esta
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Columna_Set_Descripcion
(
	@Tabla VARCHAR(35)
	, @Columna VARCHAR(35)
	, @Descripcion VARCHAR(50)
)
AS
BEGIN

	SET NOCOUNT ON;

	IF OBJECT_ID(@Tabla, 'U') IS NOT NULL
	BEGIN
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @Tabla AND COLUMN_NAME = @Columna)
		BEGIN
			BEGIN TRY
				EXEC sp_addextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table',  @Tabla , N'column', @Columna;
			END TRY
			BEGIN CATCH
				EXEC sp_updateextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table',  @Tabla , N'column', @Columna;
			END CATCH
			PRINT 'Notificacion: Ejecucion exitosa.';
		END
		ELSE
		BEGIN
			PRINT 'Validacion: La columna ingresada, no existe.';
		END
	END
	ELSE 
	BEGIN
		PRINT 'Validacion: La tabla ingresada, no existe.';
	END
END
GO