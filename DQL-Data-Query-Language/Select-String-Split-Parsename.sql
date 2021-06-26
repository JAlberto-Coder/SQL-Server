USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-String-Split-Parsename.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		23-11-2019
-- Descripcion: Sentencias STRING_SPLIT Y PARSENAME para aplicarlas en un SELECT
-- Precondiciones: 
--		* Utilizar nombres completos de 3 o 4 palabras, ya que la función PARSENAME solo se puedes extraer de 1 a 4
--		* El nombre o los nombres hay que colocarlos primero nombres y despues apellidos
--		* Informtunadamente para este ejercicio pueden haber demasiadas excepciones a la hora de realizar una depuracion de datos, estas las puedes trabajar conforme vayan apareciendo
--		* Realiza a tu conveniencia el uso de estas importantes funciones
-- =============================================
-- DECLARACION DE VARIABLES
-- =============================================
DECLARE @i INT = 0;
DECLARE @Longitud INT = 0;
DECLARE @Nombre VARCHAR(150) = UPPER('Jose Romulo Sosa Ortiz');
DECLARE @NombreTemp VARCHAR(150);
DECLARE @NombreCheck VARCHAR(150);
-- =============================================
-- SETEO DE VARIABLES NECESARIAS
-- =============================================
SET @Nombre = REPLACE(@Nombre,' ', '.');
SET @Longitud = (DATALENGTH(@Nombre) - DATALENGTH(REPLACE(@Nombre, '.', '')));
SET @NombreCheck = @Nombre;
-- =============================================
-- CICLO WHILE, PARA APLICAR UN STRING_SPLIT Y EXTRAER CADA PALABRA, PARA VALIDAR QUE NO SEA UNA PALABRA COMPUESTA
-- =============================================
WHILE @i <= @Longitud
BEGIN
	SET @NombreTemp = (SELECT [VALUE] FROM STRING_SPLIT(@NombreCheck, '.') ORDER BY 1 ASC OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY);
	IF (@NombreTemp IN('DE', 'DEL', 'LA', 'LAS', 'LOS', 'SAN', 'Y'))
	BEGIN
		SET @Nombre = REPLACE(@Nombre, @NombreTemp + '.', @NombreTemp + ' ');
	END
	SET @i = @i + 1;
END
-- =============================================
-- SELECT CON PARSENAME
-- Nota: Recuerda que esta funcion solo permite seleccionar del 1 al 4, ademas de realizar la separacion solo por un punto
-- =============================================
SELECT COALESCE(IIF(PARSENAME(@Nombre, 4) IS NULL, PARSENAME(@Nombre, 3), PARSENAME(@Nombre, 4)), '') AS [Primer Nombre]
	, IIF(PARSENAME(@Nombre, 4) IS NULL, '', PARSENAME(@Nombre, 3)) AS [Segundo Nombre]
	, COALESCE(PARSENAME(@Nombre, 2), '') AS [Primer Apellido]
	, COALESCE(PARSENAME(@Nombre, 1), '') AS [Segundo Apellido];
GO
PRINT 'FIN';
GO