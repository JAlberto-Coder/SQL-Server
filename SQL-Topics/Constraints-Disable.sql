USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Constraints-Disable.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		27-10-2019
-- Descripcion: Para el siguiente ejemplo, se crearan dos tablas relacionadas para ver como se reaccionan al eliminar los registros de estas y como nos ayuda a deshabilitar los constraints
-- Se utiliza el manejo de transacciones por costumbre, pero esto realmente no es necesario
-- Recuerda que si utilizas transacciones, asegurate que nunca se quede ninguna abierta, commitea o dale rollback
-- Esto solo es un ejemplo, pero recuerda lo podrias realizar para todas las tablas de una BD utilizando recursos de la propia base de datos
-- =============================================
BEGIN TRANSACTION DisableConstraints;
BEGIN TRY
	-- =================================================================================================================
	-- 1. CREACION DE LAS TABLAS, CON SUS RESPESTIVOS CONSTRAINTS DE RELACION
	-- =================================================================================================================
	IF OBJECT_ID('Detalle', 'U') IS NOT NULL
	BEGIN
		DROP TABLE Detalle;
	END
	IF OBJECT_ID('Encabezado', 'U') IS NOT NULL
	BEGIN
		DROP TABLE Encabezado;
	END
	CREATE TABLE Encabezado 
	(
		uuidEncabezado UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
		Descripcion VARCHAR(50) NOT NULL,
		CONSTRAINT PK_Encabezado_uuidLlave PRIMARY KEY(uuidEncabezado)
	);
	CREATE TABLE Detalle 
	(
		uuidDetalle UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
		uuidEncabezado UNIQUEIDENTIFIER NOT NULL,
		NombreProducto VARCHAR(50) NOT NULL,
		Cantidad INT NOT NULL,
		CONSTRAINT PK_Detalle_uuidDetalle PRIMARY KEY(uuidDetalle),
		CONSTRAINT FK_Encabezado_Detalle_uuidEncabezado FOREIGN KEY(uuidEncabezado) REFERENCES Encabezado(uuidEncabezado)
	);
	PRINT 'CREACION DE LAS TABLAS';
	-- =================================================================================================================
	-- 2. INSERT DE DATOS, PARA QUE SE ENCUENTREN TOTALMENTE RELACIONADOS
	-- =================================================================================================================
	DECLARE @uuidEncabezadoIn UNIQUEIDENTIFIER = NEWID();
	INSERT INTO Encabezado(uuidEncabezado, Descripcion) VALUES(@uuidEncabezadoIn, 'Refescos');
	INSERT INTO Detalle(uuidEncabezado, NombreProducto, Cantidad) VALUES(@uuidEncabezadoIn, 'Red Bubble', 18);
	INSERT INTO Detalle(uuidEncabezado, NombreProducto, Cantidad) VALUES(@uuidEncabezadoIn, 'Blue Bubble', 32);
	INSERT INTO Detalle(uuidEncabezado, NombreProducto, Cantidad) VALUES(@uuidEncabezadoIn, 'Purple Bubble', 20);
	PRINT 'INSERT DE DATOS';
	-- =================================================================================================================
	-- 3. DML PARA ELIMINACION DE REGISTROS, SE GENERA UN INTENTO FALLIDO PARA LA ELIMINACION DE DATOS
	-- =================================================================================================================
	BEGIN TRY
		DELETE FROM Encabezado WHERE uuidEncabezado = @uuidEncabezadoIn;
		DELETE FROM Detalle;
		PRINT 'REGISTROS ELIMINADOS';
	END TRY
	BEGIN CATCH
		PRINT 'ERROR PROVOCADO:';
		PRINT 'ERROR NUMBER:    ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'ERROR STATE:     ' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT 'ERROR SEVERITY:  ' + CAST(ERROR_SEVERITY() AS VARCHAR);
		PRINT 'ERROR PROCEDURE: ' + COALESCE(CAST(ERROR_PROCEDURE() AS VARCHAR), 'NA');
		PRINT 'ERROR LINE:      ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT 'ERROR MESSAGE:   ' + ERROR_MESSAGE();
	END CATCH
	-- =================================================================================================================
	-- 4. DESACTIVACION DE CONSTRAINTS, APLICAMOS LOS COMANDOS PARA QUITAR CONSTRAINTS
	-- =================================================================================================================
	-- Primer comando, se quitan todos los constrains que contenga la tabla
	ALTER TABLE Detalle NOCHECK CONSTRAINT ALL;
	-- Segundo comando, se desactivan todos los triggers que puedan estar asociados a la tabla
	ALTER TABLE Detalle DISABLE TRIGGER ALL;
	PRINT 'DESACTIVACIÓN DE CONSTRAINTS';
	-- =================================================================================================================
	-- 5. REALIZAMOS NUEVAMENTE EL DELETE DE LAS TABLAS CON EL MISMOS ORDEN, AHORA A SQL SERVER NO LE IMPORTARA
	-- =================================================================================================================
	DELETE FROM Encabezado WHERE uuidEncabezado = @uuidEncabezadoIn;
	DELETE FROM Detalle;
	PRINT 'REGISTROS ELIMINADOS';
	-- =================================================================================================================
	-- 6. CONSTRAINTS REACTIVADOS, POR ULTIMO, VOLVEMOS A ACTIVAR LOS CONSTRAINTS EN LA TABLA (PASO QUE NO SE DEBE DE OLVIDAR)
	-- =================================================================================================================
	-- Asegurate que lo realizado en el paso 5. se encuentre completo, ya que el regresar los constraints a la tabla podría ocasionar un error si existen datos que corrompen las reglas
	ALTER TABLE Detalle CHECK CONSTRAINT ALL;
	ALTER TABLE Detalle ENABLE TRIGGER ALL;
	PRINT 'CONSTRAINTS REACTIVADOS';
	PRINT 'FIN DEL SCRIPT';
	COMMIT TRANSACTION DisableConstraints;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION DisableConstraints;
	PRINT 'ERROR';
	PRINT 'ERROR NUMBER:    ' + CAST(ERROR_NUMBER() AS VARCHAR);
	PRINT 'ERROR STATE:     ' + CAST(ERROR_STATE() AS VARCHAR);
	PRINT 'ERROR SEVERITY:  ' + CAST(ERROR_SEVERITY() AS VARCHAR);
	PRINT 'ERROR PROCEDURE: ' + COALESCE(CAST(ERROR_PROCEDURE() AS VARCHAR), 'NA');
	PRINT 'ERROR LINE:      ' + CAST(ERROR_LINE() AS VARCHAR);
	PRINT 'ERROR MESSAGE:   ' + ERROR_MESSAGE();
END CATCH
GO