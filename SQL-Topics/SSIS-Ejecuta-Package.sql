USE master
-- =============================================
-- Version:		1.0.0
-- Archivo:		SSIS-Ejecuta-Package.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-12-2019
-- Descripcion: Sentencias para ejecutar un Package de SQL Server Integrations Services
-- =============================================
-- NOTAS: 
--	* No se tiene interfaz grafica desde powershell
--	 	DTEXEC.EXE
--	* Se muestra interfaz grafica
--	 	DTEXECUI.EXE
--	* Mas utilizado se relaliza por el SQL Agent
--		Dando de alta un job llamando al paquete a ejecutar
-- =============================================
-- EJECUTOR DESDE LINEA DE COMANDO
-- Asegurate de tener los archivos en la ruta espeficiada de lo contrario no podra ejecutar nada
-- =============================================
DECLARE @FiltroFechaInicio	VARCHAR(10) = '2014-01-01';
DECLARE @FiltroFechaFin	VARCHAR(10) = '2014-01-31';
DECLARE @Paquete VARCHAR(1000) = N'"F:\Work Station\SSIS\ETL\Descarga_Archivos.dtsx" /DECRYPT Password /CHECKPOINTING OFF /REPORTING E /ConsoleLog M';
DECLARE @CMD VARCHAR(1000) = N'dtexec /FILE ' + @Paquete + ' /set \package.variables[FiltroFechaInicio].Value;' + @FiltroFechaInicio + ' /set \package.variables[FiltroFechaFin].Value;'+ @FiltroFechaFin;
PRINT @CMD;
EXECUTE XP_CMDSHELL @CMD;
GO
-- O se puede ejecutar directamente desde CMD, solo asegurarse que se tiene intalado Datatools en el servidor