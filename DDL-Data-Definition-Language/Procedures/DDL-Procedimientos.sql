-- =============================================
-- Version:		1.0.0
-- Archivo:		DDL-Procedimientos.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-11-2019
-- Descripcion: Sentencias CREATE, ALTER y DROP para la Definicion de procedimientos almacenados
-- =============================================
USE Developer;
GO
-- =============================================
-- Introduccion: Un Procedimiento Almacenado o SP,
-- se pueden ingresar cualquier tipo de sentencias sean DDL, DQL, DML o DCL
-- =============================================
-- ELIMINACION DE UN PROCEDIMIENTO ALMACENADO
-- =============================================
IF OBJECT_ID('SerieFibonacci_Consulta', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE SerieFibonacci_Consulta;
	PRINT 'PROCEDIMIENTO SerieFibonacci_Consulta ELIMINADO';
END
GO
-- =============================================
-- CREACION DE UN PROCEDIMIENTO ALMACENADO
-- Nota: Como recomendacion manten un versionamiento y descripcion de los SP
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Version:		1.0.0
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-11-2019
-- Descripcion: Procedimiento almacenado que selecciona la secuencia de Fibonacci repetida 50 veces
-- =============================================
CREATE PROCEDURE SerieFibonacci_Consulta 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @n INT = 0;
	DECLARE @Lenght INT = 50;
	DECLARE @TablaFibonnaci table (Secuencia bigint NOT NULL);
	
	WHILE (@n < @Lenght)
	BEGIN
		IF (@n = 0)
		BEGIN
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(0);
		END
		ELSE IF (@n = 1)
		BEGIN
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(1);
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(1);
		END
		ELSE IF (@n > 1)
		BEGIN
			DECLARE @a bigint = (SELECT TOP 1 Secuencia FROM @TablaFibonnaci ORDER BY Secuencia DESC);
			DEClARE @B bigint;
			SET @B = IIF(@a = 1, 1, (SELECT TOP 1 Secuencia FROM @TablaFibonnaci WHERE Secuencia <> @a ORDER BY Secuencia DESC));
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(@a + @B);
		END
		SET @n = @n + 1;
	END
	
	SELECT Secuencia AS SecuenciaFibonacci FROM @TablaFibonnaci;

END
GO

PRINT 'PROCEDIMIENTO SerieFibonacci_Consulta CREADO';
GO
-- =============================================
-- EJECUCION DE UN PROCEDIMIENTO ALMACENADO, SIN VARIABLES
-- =============================================
EXECUTE SerieFibonacci_Consulta;
PRINT 'PROCEDIMIENTO SerieFibonacci_Consulta EJECUTADO';
GO
-- =============================================
-- MODIFICACION DE UN PROCEDIMIENTO ALMACENADO
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Version: 1.0.0.0
-- Procedure: SerieFibonacci_Consulta
-- =============================================
-- Autor: JAlberto-Coder
-- Fecha: 22-11-2019
-- Descripcion: Procedimiento almacenado que selecciona la secuencia de Fibonacci repetida 50 veces
-- =============================================
-- 22-11-2019 | JAlberto-Coder | Se agrega Parametro de entrada @Length para que el usuario ingrese que tanto quiere la secuencia de Fibonacci
-- =============================================
ALTER PROCEDURE SerieFibonacci_Consulta
(
	@Lenght INT = 50 -- Recuerda que las veces que se repita la secuencia Fibonacci, no deberan se sobrepasar un numero BIGINT, sino marcara error
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @n INT = 0;
	DECLARE @TablaFibonnaci table (Secuencia bigint NOT NULL);
	
	WHILE (@n < @Lenght)
	BEGIN
		IF (@n = 0)
		BEGIN
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(0);
		END
		ELSE IF (@n = 1)
		BEGIN
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(1);
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(1);
		END
		ELSE IF (@n > 1)
		BEGIN
		
			DECLARE @a bigint = (SELECT TOP 1 Secuencia FROM @TablaFibonnaci ORDER BY Secuencia DESC);
			DEClARE @B bigint;
			SET @B = IIF(@a = 1, 1, (SELECT TOP 1 Secuencia FROM @TablaFibonnaci WHERE Secuencia <> @a ORDER BY Secuencia DESC));
			INSERT INTO @TablaFibonnaci(Secuencia) VALUES(@a + @B);
		END
		SET @n = @n + 1;
	END
	
	SELECT Secuencia AS SecuenciaFibonacci FROM @TablaFibonnaci;
END
GO

PRINT 'PROCEDIMIENTO SerieFibonacci_Consulta MODIFICADO';
GO

EXECUTE SerieFibonacci_Consulta @Lenght = 15;
PRINT 'PROCEDIMIENTO SerieFibonacci_Consulta RE-EJECUTADO';
GO

-- =============================================
-- CREATE OR ALTER PROCEDURE, Con un parametro de salida
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Version:		1.0.0
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-11-2019
-- Descripcion: Procedimiento almacenado devuelve la Fecha actual
-- =============================================
CREATE OR ALTER PROCEDURE Fecha_Consulta
(
	@Fecha DATETIME OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET @Fecha = GETDATE();
END;
GO
PRINT 'PROCEDIMIENTO Fecha_Consulta CREADO O MODIFICADO';
GO
-- Ejecucion del SP para cachar la varaible de salida
DECLARE @Fecha DATETIME;
EXECUTE Fecha_Consulta @Fecha OUTPUT;
SELECT @Fecha AS FechaActual;
PRINT 'PROCEDIMIENTO Fecha_Consulta EJECUTADO';
GO
-- =============================================
-- WITH ENCRYPTION, sirve para encriptar la definicion. No se podra ver o modificar a menos que se tenga el script origial
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Version:		1.0.0
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		22-11-2019
-- Descripcion: Procedimiento almacenado devuelve la cadena Hola Mundo, pero este se encuentra encriptado
-- =============================================
CREATE OR ALTER PROCEDURE Print_HolaMundo
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 'Hola Mundo' AS Mensaje;
END;
GO
PRINT 'PROCEDIMIENTO GetHolaMundo CREADO O MODIFICADO';
GO
-- SP_HELPTEXT, Si un SP esta WITH ENCRYPTION no mostrara su definicion
sp_helptext @objname = 'Print_HolaMundo';
GO
-- =============================================
-- WITH RECOMPILE, sirve que el SP no se almacene un plan de ejecucion hay dos maneras de hacerlo, una en la definicion del SP, u otra ejecutando el SP
-- =============================================
EXECUTE Print_HolaMundo
WITH RECOMPILE;
GO
PRINT 'PROCEDIMIENTO GetHolaMundo EJECUTADO';
GO
PRINT 'FIN';
GO
-- =============================================
-- SENTENCIAS RELEVANTES A PROCEDIMIENTOS ALMACENADOS
-- =============================================
-- Almacenamiento de los SPs
SELECT * FROM sys.procedures WITH(NOLOCK);
GO
-- SP_HELPTEXT, para que nos muestre la definicion del SP
sp_helptext @objname = 'Fecha_Consulta';
GO