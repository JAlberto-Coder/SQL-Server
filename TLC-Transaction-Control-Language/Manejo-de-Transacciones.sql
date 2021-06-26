USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Manejo-de-Transacciones.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		12-11-2019
-- Descripcion: En el siguiente ejemplo se muestran dos ejemplos para el manejo de transacciones, en espera de que veas y compruebes el funcionamiento de estas
-- Lee las instrucciones para ejecutar paso a paso cada sentencia
-- =============================================
-- EJEMPLO 1: MANEJO DE UNA TRANSACCION CON LA CONFIGURACION POR DEFECTO 
-- Generamos dos sentencias un DDL y un DML, y al final damos COMMIT. Pero si ocurre un error, al generar esto los scripts ejecutados correctamente se quedaran sin embargo los que tuvieron un error no lo haran.
-- =============================================
-- INICIO: EJECUCION EJEMPLO 1
IF OBJECT_ID('Clientes', 'U') IS NOT NULL
BEGIN
	DROP TABLE Clientes;
END
GO

BEGIN TRANSACTION Ejemplo1;
	CREATE TABLE Clientes
	(
		idCliente INT IDENTITY NOT NULL,
		Nombre VARCHAR(150) NOT NULL,
		NombreContacto VARCHAR(150) NULL,
		TituloContacto VARCHAR(50) NULL,
		ClavePais VARCHAR(3) NOT NULL,
		CONSTRAINT PK_Clientes_idCliente PRIMARY KEY(idCliente)
	);
	PRINT 'TABLA CREADA';
	INSERT INTO Clientes(Nombre, NombreContacto, TituloContacto, ClavePais)
	VALUES( 'Columpios para volar S.A. de C.V.', 'Jorge Alberto', 'Developer'); -- ERROR In INSERT statement
	INSERT INTO Clientes (Nombre, NombreContacto, TituloContacto, ClavePais)
	VALUES ('Cartas Escritas desde el Alma', 'Hermann Hesse', 'Escritor', 'DEU');
	PRINT 'REGISTROS CREADOS';
COMMIT TRANSACTION Ejemplo1;
GO
-- AL FINALIZAR PODREMOS VER QUE LA TABLA FUE CREADA, PERO LA SENTENCIA PARA INSERTARLE DATOS NO SE COMPLETO, POR LO CUAL ENVIO UN ERROR
SELECT * FROM Clientes;
-- FIN: EJECUCION EJEMPLO 1
-- =============================================
-- EJEMPLO 2: CREACIÓN DE UNA TRANSACCION ACTIVANDO LA PROPIEDAD XACT_ABORT
-- Generamos dos sentencias un DDL y un DML, y al final damos COMMIT. Pero si ocurre un error, al tener la porpiedad XACT_ABORT activada, las sentencias anteriores tampoco serán creadas ya que por lo menos ocurrio un error en la ejecución antes de dar el COMMIT
-- =============================================
-- INICIO: EJECUCION EJEMPLO 2
IF OBJECT_ID('Clientes', 'U') IS NOT NULL
BEGIN
	DROP TABLE Clientes;
END
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION Ejemplo2;
	CREATE TABLE Clientes
	(
		idCliente INT IDENTITY NOT NULL,
		Nombre VARCHAR(150) NOT NULL,
		NombreContacto VARCHAR(150) NULL,
		TituloContacto VARCHAR(50) NULL,
		ClavePais VARCHAR(3) NOT NULL,
		CONSTRAINT PK_Clientes_idCliente PRIMARY KEY(idCliente)
	);
	PRINT 'TABLA CREADA';
	INSERT INTO Clientes(Nombre, NombreContacto, TituloContacto, ClavePais)
	VALUES('Columpios para volar S.A. de C.V.', 'Jorge Alberto', 'Developer'); -- ERROR In INSERT statement
	INSERT INTO Clientes (Nombre, NombreContacto, TituloContacto, ClavePais)
	VALUES ('Cartas Escritas desde el Alma', 'Hermann Hesse', 'Escritor', 'DEU');
	PRINT 'REGISTROS CREADOS';
COMMIT TRANSACTION Ejemplo2;
GO
SET XACT_ABORT OFF;
-- AL FINALIZAR PODREMOS VER QUE NI SIQUIERA CREO LA TABLA QUE CON EL EJEMPLO ANTERIOR SI LA CREO, CON ESTO NOS ASEGURAMOS QUE EN LA TRANSACCIÓN O SE EJECUTA TODO CORRECTAMENTE O NO SE EJECUTA NADA
SELECT * FROM Clientes; -- ERROR Invalida Object Name (Ya que este no existe)
-- FIN: EJECUCION TRANSACCION 2
-- =============================================
-- EJEMPLO 3: VERIFICACIÓN DE TRANSACCIONES ACTIVAS
-- Para asegurarnos de que no existen transacciones activas, podemos ejecutar las siguientes sentencias
-- =============================================
-- INICIO: EJECUCION TRANSACCION 3
IF OBJECT_ID('Clientes', 'U') IS NOT NULL
BEGIN
	DROP TABLE Clientes;
END
GO
BEGIN TRANSACTION Ejemplo3;
	CREATE TABLE Clientes
	(
		idCliente INT IDENTITY NOT NULL,
		Nombre VARCHAR(150) NOT NULL,
		NombreContacto VARCHAR(150) NULL,
		TituloContacto VARCHAR(50) NULL,
		ClavePais VARCHAR(3) NOT NULL,
		CONSTRAINT PK_Clientes_idCliente PRIMARY KEY(idCliente)
	);
	INSERT INTO Clientes(Nombre, NombreContacto, TituloContacto, ClavePais)
	VALUES('Columpios para volar S.A. de C.V.', 'Jorge Alberto', 'Developer', 'MEX');
	INSERT INTO Clientes (Nombre, NombreContacto, TituloContacto, ClavePais)
	VALUES ('Cartas Escritas desde el Alma', 'Hermann Hesse', 'Escritor', 'DEU');
	PRINT 'REGISTROS CREADOS';
GO
-- VER BLOQUEOS SOBRE LA BASE DE DATOS
sp_lock
-- VERIFICAR EL ESTADO DE UNA TRANSACCIÓN
SELECT XACT_STATE() AS TotalTransaccionesActivas;
-- LE DAMOS ROLLBACK A LAS TRANSACCIONES ACTIVAS, AUNQUE LO MEJOR ES QUE LA CIERRE CADA PROCESO
COMMIT TRANSACTION;
PRINT 'TRANSACCION AL FIN COMITEADA';
GO
-- FIN: EJECUCION TRANSACCION 3