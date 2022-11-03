USE Developer
GO
-- ============================================
-- Versión: 1.0
-- ============================================
-- 03-11-2022 | JAlberto-Coder | Plantilla posterior de la creación de una base de datos
-- ============================================
-- ESQUEMAS
-- ============================================
CREATE SCHEMA cat AUTHORIZATION dbo;
GO
CREATE SCHEMA cfg AUTHORIZATION dbo;
GO
CREATE SCHEMA hco AUTHORIZATION dbo;
GO
CREATE SCHEMA sis AUTHORIZATION dbo;
GO
CREATE SCHEMA tmp AUTHORIZATION dbo;
GO
-- ============================================
-- PROCEDIMIENTOS
-- ============================================
GO
-- ============================================
-- Versión: 1.0
-- ============================================
-- 03-11-2022 | JAlberto-Coder
-- ============================================
CREATE PROCEDURE [sis].[Columnas_Auditoria]
(
	@Tabla VARCHAR(100) -- Parámetro donde se debe de indicar la tabla para agregarle las columnas
	, @Esquema VARCHAR(5) = 'dbo' -- Parámetro donde se indica el esquema de la tabla
)
AS
BEGIN
	
	SET NOCOUNT OFF;
	
	IF EXISTS(SELECT TOP(1) 1 FROM sys.objects WHERE [name] = @Tabla AND [type] = 'U')
	BEGIN		
		IF NOT EXISTS(SELECT TOP(1) 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @Tabla AND (COLUMN_NAME = 'FG' OR COLUMN_NAME = 'UG' OR COLUMN_NAME = 'ST' OR COLUMN_NAME = 'FM' OR COLUMN_NAME = 'UM' OR COLUMN_NAME = 'FB' OR COLUMN_NAME = 'UB'))
		BEGIN
			
			DECLARE @vSql NVARCHAR(3000);
			
			SELECT @vSql = CONCAT
				(
					'ALTER TABLE ', @Esquema, '.', @Tabla, ' ADD'
					, ' FG DATETIME NOT NULL CONSTRAINT DF_', @Tabla, '_FG DEFAULT (GETDATE())' 
					, ', UG VARCHAR(60) NOT NULL CONSTRAINT DF_', @Tabla, '_UG DEFAULT(''DEFAULT_USER'')'
					, ', FM DATETIME NULL'
					, ', UM VARCHAR(60) NULL '
					, ', FB DATETIME NULL'
					, ', UB VARCHAR(60) NULL'
					, ', ST BIT NOT NULL CONSTRAINT DF_', @Tabla, '_ST DEFAULT ((1)) ;'
				);
			
			EXEC sys.sp_executesql @vSql;

			SELECT @vSql = CONCAT
				(
					'EXEC sp_addextendedproperty N''MS_Description'', N''Fecha de inserción del registro'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''FG'' ; '
					, 'EXEC sp_addextendedproperty N''MS_Description'', N''Cuenta de usuario que insertó el registro'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''UG'' ; '
					, 'EXEC sp_addextendedproperty N''MS_Description'', N''Última fecha de modificación del registro'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''FM'' ; '
					, 'EXEC sp_addextendedproperty N''MS_Description'', N''Cuenta de usuario que modifica el registro'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''UM'' ; '
					, 'EXEC sp_addextendedproperty N''MS_Description'', N''Fecha de baja del registro'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''FB'' ; '
					, 'EXEC sp_addextendedproperty N''MS_Description'', N''Cuenta de usuario que da de baja el registro'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''UB'' ; '
					, 'EXEC sp_addextendedproperty N''MS_Description'', N''Estatus del registro ( Activo = 1 , Inactivo = 0 )'', N''SCHEMA'', N''', @Esquema ,''', N''table'', N''', @Tabla, ''', N''column'', N''ST'' ; '
				);
			PRINT @vSql;
			EXEC sys.sp_executesql @vSql;

			PRINT 'Columnas de auditoria agregadas sobre la tabla (' + @Tabla + ').';
		END
		ELSE
		BEGIN
			PRINT 'Validación: Existe al menos una columna que funge como auditoria en la tabla (' + @Tabla + ').';
		END
	END
	ELSE
	BEGIN
		PRINT 'Validación: La tabla ingresada (' + @Tabla + ') no existe.';
	END
END
GO
-- ==================================================
-- Version: 1.0
-- ==================================================
-- 03-11-2022 | JAlberto-Coder
-- ==================================================
CREATE PROCEDURE [sis].[Columna_Set_Descripcion]
(
	@Tabla VARCHAR(100)			-- Especifica la tabla que contiene la columna afectar[REQUERIDO]
	, @Columna VARCHAR(100)		-- Especifica la columna a afectar[REQUERIDO]
	, @Descripcion VARCHAR(500)	-- Descripcion general del campo[REQUERIDO]
)
AS
BEGIN

	SET NOCOUNT OFF;
	
	IF OBJECT_ID(@Tabla, 'U') IS NOT NULL
	BEGIN
		
		IF EXISTS (SELECT TOP(1) 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @Tabla AND COLUMN_NAME = @Columna)
		BEGIN
			BEGIN TRY
				EXEC sp_addextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table',  @Tabla , N'column', @Columna;
			END TRY
			BEGIN CATCH
				EXEC sp_updateextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table',  @Tabla , N'column', @Columna;
			END CATCH

			PRINT 'Notificacion: Descripcion de columna actualizada.';
		END
		ELSE
		BEGIN
			PRINT 'Validacion: La columna ingresada (' + @Columna + '), no existe.';
		END
	END
	ELSE
	BEGIN
		PRINT 'Validacion: La tabla ingresada (' + @Tabla + '), no existe.';
	END
END
GO
-- ==================================================
-- TABLAS
-- ==================================================
-- sis.ErroresDB
-- ==================================================
CREATE TABLE [sis].[ErroresDB](
	[ErrorDbID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorTime] [datetime] NOT NULL,
	[UserName] [sysname] NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](126) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_ErroresDB] PRIMARY KEY CLUSTERED ([ErrorDbID] DESC)
)
GO

ALTER TABLE [sis].[ErroresDB] ADD  CONSTRAINT [DF_ErroresDB_ErrorTime]  DEFAULT (getdate()) FOR [ErrorTime]
GO
-- ==================================================
-- sis.Errores
-- ==================================================
CREATE TABLE [sis].[Errores](
	[IdError] [int] IDENTITY(1,1) NOT NULL,
	[UuidPortal] [uniqueidentifier] NOT NULL,
	[UuidUsuario] [uniqueidentifier] NOT NULL,
	[UuidAccion] [uniqueidentifier] NOT NULL,
	[Identificador] [uniqueidentifier] NULL,
	[Excepcion] [varchar](8000) NOT NULL,
	[Mensaje] [varchar](8000) NOT NULL,
	[Fuente] [varchar](1024) NOT NULL,
	[Insumo] [varchar](8000) NOT NULL,
	[LineaYColumna] [varchar](500) NOT NULL,
	[FG] [datetime] NOT NULL,
	[UG] [varchar](60) NOT NULL,
 CONSTRAINT [PK_Errores] PRIMARY KEY CLUSTERED ([IdError] DESC)
)
GO

ALTER TABLE [sis].[Errores] ADD  CONSTRAINT [DF_Errores_FG]  DEFAULT (getdate()) FOR [FG]
GO

ALTER TABLE [sis].[Errores] ADD  CONSTRAINT [DF_Errores_UG]  DEFAULT ('DEFAULT_USER') FOR [UG]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de inserción del registro' , @level0type=N'SCHEMA',@level0name=N'sis', @level1type=N'TABLE',@level1name=N'Errores', @level2type=N'COLUMN',@level2name=N'FG'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuenta de usuario que insertó el registro' , @level0type=N'SCHEMA',@level0name=N'sis', @level1type=N'TABLE',@level1name=N'Errores', @level2type=N'COLUMN',@level2name=N'UG'
GO
-- ==================================================
-- sis.Log
-- ==================================================
CREATE TABLE [sis].[Logs](
	[IdLog] [bigint] IDENTITY(1,1) NOT NULL,
	[UuidUsuario] [uniqueidentifier] NOT NULL,
	[Mensaje] [varchar](8000) NOT NULL,
	[Fuente] [varchar](200) NOT NULL,
	[Proceso] [varchar](50) NOT NULL,
	[Insumo] [varchar](max) NOT NULL,
	[FG] [datetime] NOT NULL,
	[UG] [varchar](60) NOT NULL,
 CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED ([IdLog] DESC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [sis].[Logs] ADD  CONSTRAINT [DF_Logs_FG]  DEFAULT (getdate()) FOR [FG]
GO

ALTER TABLE [sis].[Logs] ADD  CONSTRAINT [DF_Logs_UG]  DEFAULT ('DEFAULT_USER') FOR [UG]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de inserción del registro' , @level0type=N'SCHEMA',@level0name=N'sis', @level1type=N'TABLE',@level1name=N'Logs', @level2type=N'COLUMN',@level2name=N'FG'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuenta de usuario que insertó el registro' , @level0type=N'SCHEMA',@level0name=N'sis', @level1type=N'TABLE',@level1name=N'Logs', @level2type=N'COLUMN',@level2name=N'UG'
GO

-- ==================================================
-- SP [sis].[ErroresDB_Inserta] 
-- ==================================================
GO
-- ==================================================
-- Versión: 1.0
-- ==================================================
-- 03-11-2022 | JAlberto-Coder | Procedimiento de usuario que inserta un registro en la tabla Sys_ErrorLog
-- ==================================================
CREATE PROCEDURE [sis].[ErroresDB_Inserta] 
(
    @ErrorDBID [int] = 0 OUTPUT -- Contiene el ErrorLogID de la fila insertada en la tabla: ErrorLog (-1 = Error o sin detección del error)
)
AS
BEGIN
	
    SET NOCOUNT ON;

    SELECT @ErrorDBID = 0;

    BEGIN TRY
        
        IF ERROR_NUMBER() IS NULL
            RETURN;

        IF XACT_STATE() = -1
        BEGIN
            PRINT 'No se puede registrar el error porque la transacción actual está en un estado no comprometible. ' 
                + 'Revertir la transacción antes de ejecutar uspLogError para registrar correctamente la información del error.';
            RETURN;
        END

        INSERT INTO sis.ErroresDB
		(
            [UserName] 
            , [ErrorNumber]
            , [ErrorSeverity]
            , [ErrorState]
            , [ErrorProcedure]
            , [ErrorLine]
            , [ErrorMessage]
        ) 
        VALUES 
        (
            CONVERT(sysname, CURRENT_USER) 
            , ERROR_NUMBER()
            , ERROR_SEVERITY()
            , ERROR_STATE()
            , ERROR_PROCEDURE()
            , ERROR_LINE()
            , ERROR_MESSAGE()
        );

		PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) 
          + ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) 
          + ', State ' + CONVERT(varchar(5), ERROR_STATE()) 
          + ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') 
          + ', Line ' + CONVERT(varchar(5), ERROR_LINE());
		PRINT ERROR_MESSAGE();

        SELECT @ErrorDBID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'Ocurrió un error en el procedimiento Sys_ErrorresDBLog_Inserta: ';
        
		PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) 
          + ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) 
          + ', State ' + CONVERT(varchar(5), ERROR_STATE()) 
          + ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') 
          + ', Line ' + CONVERT(varchar(5), ERROR_LINE());
		PRINT ERROR_MESSAGE();

        RETURN -1;
    END CATCH
END
GO
-- ==================================================
-- SP [sis].[Errores_Inserta]
-- ==================================================
GO
-- ==================================================
-- Versión: 1.0
-- ==================================================
-- 03-11-2022 | JAlberto-Coder | Store Procedure que guarda un un log de validacion/error
-- ==================================================
CREATE PROCEDURE [sis].[Errores_Inserta]
(
	@UuidPortal UNIQUEIDENTIFIER		-- UUID del portal que ejecuta el proceso
	, @UuidUsuario UNIQUEIDENTIFIER		-- UUID del usuario que ejecuta el proceso
	, @UuidAccion UNIQUEIDENTIFIER		-- UUID Accion que se ejecuta
	, @Identificador UNIQUEIDENTIFIER	-- 
	, @Excepcion VARCHAR(8000)			-- Inner exception de la excepcion
	, @Mensaje VARCHAR(8000)			-- Mensaje de la excepcion
	, @Fuente VARCHAR(512)				-- Donde se origina el error
	, @Insumo VARCHAR(8000)				-- Insumo del proceso que causa el error
	, @LineaYColumna VARCHAR(8000)		-- Linea y columna donde se origina el error
	, @UG VARCHAR(60) = 'Default-User'	-- Usuario que genero el error
)
AS   
BEGIN  

	DECLARE @estatus INT;

	BEGIN TRY
		
		IF NOT EXISTS(SELECT TOP(1) 1 FROM sis.Errores WHERE Insumo = @Insumo)
			INSERT INTO sis.Errores
			(
				UuidPortal, UuidUsuario, UuidAccion, Identificador, Excepcion, Mensaje, Fuente, Insumo, LineaYColumna, FG, UG
			)
			VALUES
			(
				@UuidPortal, @UuidUsuario, @UuidAccion, @Identificador, @Excepcion, @Mensaje, @Fuente, @Insumo, @LineaYColumna, GETDATE(), @UG
			);
		
		SET @estatus = 1;
		SELECT @estatus AS estatus, '' AS resultado;

	END TRY
	BEGIN CATCH

		SELECT @estatus = 0;
		SELECT @estatus AS estatus, ERROR_MESSAGE() AS resultado;

	END CATCH;
END 
GO
-- ==================================================
-- [sis].[Log_Inserta]
-- ==================================================
GO
-- ==================================================
-- Versión: 1.0
-- ==================================================
-- 03-11-2022 | JAlberto-Coder | Procedimiento que almacena un log, este se debe de almacenar en caso de alguna validación
-- ==================================================
CREATE PROCEDURE [sis].[Log_Inserta]
(
	@UuidUsuario UNIQUEIDENTIFIER
	, @Mensaje VARCHAR(8000)
	, @Fuente VARCHAR(200)
	, @Insumo VARCHAR(MAX)
	, @Proceso VARCHAR(50)
	, @UG VARCHAR(60)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		IF NOT EXISTS(SELECT TOP(1) 1 FROM sis.Logs WHERE Insumo = @Insumo)
			INSERT INTO sis.Logs
			(
				UuidUsuario, Mensaje, Fuente, Insumo, Proceso, FG, UG
			)
			VALUES
			(
				@UuidUsuario, @Mensaje, @Fuente, @Insumo, @Proceso, GETDATE(), @UG
			);

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000)
			, @ErrorSeverity INT
			, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
-- ==================================================
-- SENTENCIAS PARA DAR ROLLBACK
-- ==================================================
--DROP PROCEDURE IF EXISTS [sis].[Columna_Set_Descripcion];
--GO
--DROP PROCEDURE IF EXISTS [sis].[Columnas_Auditoria];
--GO
--DROP PROCEDURE IF EXISTS [sis].[Errores_Inserta];
--GO
--DROP PROCEDURE IF EXISTS [sis].[ErroresDB_Inserta];
--GO
--DROP PROCEDURE IF EXISTS [sis].[Log_Inserta];
--GO
--DROP TABLE IF EXISTS [sis].[Errores];
--GO
--DROP TABLE IF EXISTS [sis].[ErroresDB];
--GO
--DROP TABLE IF EXISTS [sis].[Logs];
--GO
--DROP SCHEMA IF EXISTS cat;
--GO
--DROP SCHEMA IF EXISTS cfg;
--GO
--DROP SCHEMA IF EXISTS hco;
--GO 
--DROP SCHEMA IF EXISTS sis;
--GO
--DROP SCHEMA IF EXISTS tmp;
--GO