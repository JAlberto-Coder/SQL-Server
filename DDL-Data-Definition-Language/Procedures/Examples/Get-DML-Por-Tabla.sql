USE Developer;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Version: 	1.0.0.0
-- Archivo: 	Get-DML-Por-Tabla.sql
-- =============================================
-- Autor: 		JAlberto-Coder
-- Fecha: 		07-11-2019
-- Descripcion: Creación de un SP que reciba dos parametros, @NombreTabla y @DML y genere el DML siemple deseado.
-- Para Sentencias UPDATE, DELETE se tomará la llave primaria para agregar el WHERE, en caso de no existir de generara sin un WHERE
-- =============================================
CREATE OR ALTER PROCEDURE dbo.Get_DML_Por_Tabla
(
	@NombreTabla VARCHAR(35)
	, @DML char(1)				-- Parametros validos: C, R, U, D
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Query NVARCHAR(max) = NULL
		, @Campo VARCHAR(50);
	DECLARE @CamposTabla TABLE(Atributo VARCHAR(50) NOT NULL, ValorPorDefecto VARCHAR(50) NULL, EsPrimaryKey BIT DEFAULT(0) NOT NULL, Bandera BIT DEFAULT(0) NOT NULL);
	BEGIN TRY

		IF (LEN(@NombreTabla) = 0)
		BEGIN
			PRINT 'El parametro: NombreTabla, es requerido.';
			RETURN;
		END

		IF OBJECT_ID(@NombreTabla, 'U') IS NOT NULL
		BEGIN
			-- =============================================
			-- SE INSERTAN LOS ATRIBUTOS DE LA TABLA EN UNA VARIABLE TIPO TABLA
			-- =============================================
			INSERT INTO @CamposTabla(Atributo)
			SELECT [name]
			FROM sys.columns
			WHERE object_id = OBJECT_ID(@NombreTabla);
			-- =============================================
			-- C: GENERAREMOS DE SALIDA UN INSERT
			-- =============================================
			IF (@DML = 'C')
			BEGIN
				SET @Query = N'INSERT INTO ' + @NombreTabla + ' (';
				INSERT INTO @CamposTabla (Atributo, ValorPorDefecto)
				SELECT name AS Nombre, IIF(default_object_id = 0, IIF(is_identity = 1, 'THIS_IS_IDENTITY', IIF(is_nullable = 0, '@' + name, 'NULL')), 'DEFAULT') AS ValorPorDefecto
				FROM sys.columns WHERE object_id = OBJECT_ID(@NombreTabla);
				--
				WHILE EXISTS(SELECT 1 FROM @CamposTabla WHERE Bandera = 0 AND ValorPorDefecto <> 'THIS_IS_IDENTITY')
				BEGIN 
					SET @Campo = (SELECT TOP 1 Atributo FROM @CamposTabla WHERE Bandera = 0 AND ValorPorDefecto <> 'THIS_IS_IDENTITY');
					SET @Query = @Query + @Campo +', ';
					UPDATE @CamposTabla SET Bandera = 1 WHERE Atributo = @Campo;
				END
				SET @Query = LEFT(@Query, LEN(@Query)-1);
				SET @Query = @Query + N') 
				VALUES (';
				--
				WHILE EXISTS(SELECT 1 FROM @CamposTabla WHERE Bandera = 1)
				BEGIN 
					DECLARE @NombreCampo NVARCHAR(50) = (SELECT TOP 1 Atributo FROM @CamposTabla WHERE Bandera = 1 AND ValorPorDefecto <> 'THIS_IS_IDENTITY');
					DECLARE @ValorPorDefecto NVARCHAR(50) = (SELECT TOP 1 ValorPorDefecto FROM @CamposTabla WHERE Atributo = @NombreCampo AND ValorPorDefecto <> 'THIS_IS_IDENTITY');
					SET @Query = @Query + IIF(@ValorPorDefecto = 'NULL', '@' + @NombreCampo, @ValorPorDefecto) + ', ';
					UPDATE @CamposTabla SET Bandera = 0 WHERE Atributo = @NombreCampo;
				END
				SET @Query = LEFT(@Query, LEN(@Query)-1);
				SET @Query = @Query + N');'

			END
			-- =============================================
			-- R: CREAREMOS UNA SENTENCIA SELECT
			-- =============================================
			ELSE IF (@DML = 'R')
			BEGIN
				SET @Query = N'SELECT ';
				WHILE EXISTS (SELECT 1 FROM @CamposTabla WHERE Bandera = 0)
				BEGIN 
					SET @Campo = (SELECT TOP 1 Atributo FROM @CamposTabla WHERE Bandera = 0);
					SET @Query = @Query + '[' + @Campo +'], ';
					UPDATE @CamposTabla SET Bandera = 1 WHERE Atributo = @Campo;
				END
				SET @Query = LEFT(@Query, LEN(@Query) - 1);
				SET @Query = @Query + N' FROM ' + @NombreTabla + ' WITH(NOLOCK);';
			END
			-- =============================================
			-- U: CREAREMOS UNA SENTENCIA UPDATE
			-- =============================================
			ELSE IF (@DML = 'U')
			BEGIN
				SET @Query = N'UPDATE ' + @NombreTabla + ' WITH(ROWLOCK) SET ';
			
				INSERT INTO @CamposTabla (Atributo, ValorPorDefecto)
				SELECT name AS Nombre, IIF(default_object_id = 0, IIF(is_identity = 1, 'THIS_IS_IDENTITY', '@'+ name), 'DEFAULT') AS ValorPorDefecto
				FROM sys.columns WHERE object_id = OBJECT_ID(@NombreTabla);
			
				WHILE EXISTS(SELECT 1 FROM @CamposTabla WHERE Bandera = 0 AND ValorPorDefecto <> 'THIS_IS_IDENTITY')
				BEGIN 
					UPDATE @CamposTabla 
					SET EsPrimaryKey = 
						COALESCE((
							SELECT 1
							FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TB
							INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU ON TB.Constraint_Name = CCU.Constraint_Name AND TB.Table_Name = CCU.Table_Name
							WHERE TB.CONSTRAINT_TYPE = 'PRIMARY KEY' AND TB.TABLE_NAME = @NombreTabla
						), 0)
					WHERE Atributo = @Campo;

					SELECT @Campo = (SELECT TOP(1) Atributo FROM @CamposTabla WHERE ValorPorDefecto <> 'THIS_IS_IDENTITY' AND EsPrimaryKey = 0 AND Bandera = 0);
					SELECT @Query = @Query + '[' + @Campo +'] = ' + '@' + @Campo + ', ';
					
					UPDATE @CamposTabla 
					SET Bandera = 1
					WHERE Atributo = @Campo;
				END
				SET @Query = LEFT(@Query, LEN(@Query)-1);
				IF ((SELECT COUNT(1) FROM @CamposTabla WHERE EsPrimaryKey = 1) > 0)
				BEGIN
					DECLARE @CampoTemp VARCHAR(50) = (SELECT TOP(1) Atributo FROM @CamposTabla WHERE EsPrimaryKey = 1)
					SELECT @Query = @Query + N' WHERE ' + @CampoTemp + ' = @' + @CampoTemp + ';';
				END
			END
			-- =============================================
			-- D: CREAREMOS UNA SENTENCIA DELETE
			-- =============================================
			ELSE IF (@DML = 'D')
			BEGIN
				SET @Query = N'DELETE FROM ' + @NombreTabla ;
			
				INSERT INTO @CamposTabla (Atributo, EsPrimaryKey)
				SELECT CCU.COLUMN_NAME, 1
				FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TB
				INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU ON TB.Constraint_Name = CCU.Constraint_Name AND TB.Table_Name = CCU.Table_Name
				WHERE TB.CONSTRAINT_TYPE = 'PRIMARY KEY' AND TB.TABLE_NAME = @NombreTabla;

				IF ((SELECT COUNT(1) FROM @CamposTabla WHERE EsPrimaryKey = 1) > 0)
				BEGIN
					DECLARE @CampoLlave VARCHAR(50) = (SELECT TOP(1) Atributo FROM @CamposTabla WHERE EsPrimaryKey = 1)
					SELECT @Query = @Query + N' WHERE ' + @CampoLlave + ' = @' + @CampoLlave + ';';
				END
			END
			ELSE
			BEGIN
				PRINT 'Validacion: La operación DML ingresada, no es valida.';
			END
			PRINT @Query;
		END
		ELSE
		BEGIN
			PRINT 'Validacion: La tabla ingresada, no es valida';
		END
	END TRY
	BEGIN CATCH
		PRINT 'Error: Sentencia DML no generada: ';
		PRINT 'ERROR NUMBER:    ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'ERROR STATE:     ' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT 'ERROR SEVERITY:  ' + CAST(ERROR_SEVERITY() AS VARCHAR);
		PRINT 'ERROR PROCEDURE: ' + COALESCE(CAST(ERROR_PROCEDURE() AS VARCHAR), 'NA');
		PRINT 'ERROR LINE:      ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT 'ERROR MESSAGE:   ' + ERROR_MESSAGE();
	END CATCH
END
GO