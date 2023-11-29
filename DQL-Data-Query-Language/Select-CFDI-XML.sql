USE Comprobantes;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#TablaTemp','U') IS NOT NULL
	DROP TABLE #TablaTemp;
GO

WITH CFD AS(
	SELECT XMLCFDI.value('(./*:Comprobante/*:Complemento/*:Nomina/*:Receptor/@*[upper-case(local-name())="CURP"])[1]','VARCHAR(18)') AS CURP
		, EstatusCFDI
		, Total
	FROM dbo.CFDI WITH(NOLOCK)
	WHERE XMLCFDI.value('(/*:Comprobante/*:Complemento/*:Nomina/@FechaPago)[1]','DATE') 
		BETWEEN '2018-08-01' AND '2018-09-31'
)
SELECT CURP
	, SUBSTRING(CURP, 11 ,1) AS Sexo
	, TRY_CONVERT(DATE, SUBSTRING(CURP,5,6)) AS FechaNacimiento
	, SUBSTRING(CURP,12,2) AS LugarNacimiento
	, Total
-- CREAR UNA TABLA ASÍ AL VUELVO, NO ES NADA RECOMENDABLE EN UN PROCESO PROGRAMADO.
INTO #TablaTemp
FROM CFD;
GO