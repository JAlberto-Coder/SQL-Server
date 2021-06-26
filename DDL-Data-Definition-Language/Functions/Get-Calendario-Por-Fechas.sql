USE Developer
GO
-- ==============================================
-- Version:		1.0.0
-- Archivo:		Calendario-Consulta.sql
-- ==============================================
-- Autor:		JAlberto-Coder
-- Fecha:		26-12-2019
-- Descripcion: Funcion que devuelve una tabla con las fechas de Anio, Mes y Dia con un rango dado en fechas en formato yyyy-MM-dd
-- ==============================================
CREATE OR ALTER FUNCTION dbo.Calendario_Consulta
(
	@FechaInicio DATETIME
	, @FechaFin DATETIME
)
RETURNS
@Calendario TABLE
(
	Fecha DATETIME
)
BEGIN
	WHILE (@FechaInicio <= @FechaFin)
	BEGIN
		INSERT INTO @Calendario VALUES(@FechaInicio);
		SET @FechaInicio = DATEADD(D, 1, @FechaInicio);
	END
RETURN
END
GO
-- ==============================================
-- Ejecucion de la funcion
-- ==============================================
SELECT * 
FROM Calendario_Consulta('2019-01-01','2019-12-31');
GO