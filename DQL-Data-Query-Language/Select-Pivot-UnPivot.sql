USE Developer
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Select-Pivot-UnPivot.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-11-2019
-- Descripcion: Sentencia SELECT para Pivotear datos
-- =============================================
-- PREMISAS, Para el siguiente ejemplo crearemos una tabla llamada Productos y la insertaremos unos registros
-- =============================================
IF OBJECT_ID('Productos', 'U') IS NOT NULL DROP TABLE Productos;
GO

CREATE TABLE Productos
(
	idProducto INT IDENTITY(1,1) NOT NULL,
	NombreProducto VARCHAR(50) NOT NULL,
	Descripcion VARCHAR(150) NOT NULL,
	PrecioUnitario MONEY NULL,
	UnidadDeMedida VARCHAR(50) NULL,
	UnidadesDisponibles SMALLINT NULL,
	UnidadesEnOrden SMALLINT NULL,
	Categoria VARCHAR(50) NOT NULL,
	NombreProveedor VARCHAR(150) NULL,
	Estatus BIT DEFAULT(1) NOT NULL,
	CONSTRAINT PK_Productos_idProducto PRIMARY KEY(idProducto)
);
GO

INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Libro', 'Lobo Estepario', 25.00, 'Pieza', 20, 0, 'Estante y accesorios para libros', 'Cartas Escritas con el Alma');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Libro', 'Demian', 20.00, 'Pieza', 25, 0, 'Estante y accesorios para libros', 'Cartas Escritas con el Alma');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Libro', 'Juego de Abalorios', 15.00, 'Pieza', 30, 0, 'Estante y accesorios para libros', 'Cartas Escritas con el Alma');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Libro', 'Viaje a Oriente', 50.00, 'Pieza', 56, 0, 'Estante y accesorios para libros', 'Cartas Escritas con el Alma');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('CD', 'El Objeto Antes Llamado Disco', 120.00, 'Pieza', 20, 0, 'Discos Compactos', 'Music for you');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('CD Digital', 'Jei Beibi', 125.00, 'Pieza', 10, 0, 'Discos Compactos', 'Music for you');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('CD', 'Reves / Yo soy', 500.00, 'Pieza', 1, 0, 'Discos Compactos', 'Music for you');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Cuadro de madera', 'La Ultima Cena', 800.00, 'Pieza', 2, 0, 'Cuadros de madera', 'Pinturas Leonardo SA');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Cuadro de madera', 'Imitacion la Noche Estrellada', 1000.00, 'Pieza', 2, 0, 'Cuadros de madera', 'Pinturas Leonardo SA');
INSERT INTO Productos (NombreProducto, Descripcion, PrecioUnitario, UnidadDeMedida, UnidadesDisponibles, UnidadesEnOrden, Categoria, NombreProveedor) VALUES ('Cuadro de madera', 'Imitacion la Gioconda', 1500.00, 'Pieza', 4, 0, 'Cuadros de madera', 'Pinturas Leonardo SA');
GO
-- =============================================
-- SELECT PIVOT
-- Elementos:
--		1. El agrupamiento determina que elemento obtiene una fila en el conjunto de resultados.
--		2. La dispersion proporciona los distintos valores que se pueden
--		3. La agregacion realiza una función de agregación (tal como SUM, COUNT, ETC)
-- =============================================
SELECT *
FROM
(
	SELECT NombreProducto, Categoria, PrecioUnitario * UnidadesDisponibles AS Total 
	FROM Productos WITH(NOLOCK)
) AS P
PIVOT (SUM(Total) FOR Categoria IN([Estante y accesorios para libros],[Discos Compactos],[Cuadros de madera])) AS TablaPivote;
GO
-- =============================================
-- PIVOT DINAMICO
-- =============================================
DECLARE @Categorias NVARCHAR(1000) = '';
SELECT @Categorias = @Categorias + '[' + T.Categoria + '],' FROM (SELECT DISTINCT Categoria FROM Productos) AS T;
SET @Categorias = LEFT(@Categorias, LEN(@Categorias) - 1);
EXEC 
(
	'SELECT *
	FROM
	(
		SELECT NombreProducto, Categoria, PrecioUnitario * UnidadesDisponibles AS Total 
		FROM Productos WITH(NOLOCK)
	) AS P
	PIVOT (SUM(Total) FOR Categoria IN(' + @Categorias + ')) AS TablaPivote;'
);
GO
-- =============================================
-- SELECT UNPIVOT
-- Los datos no dinamicos estan rotando datos desde una orientación basada en columnas a una orientacion basada en filas.
-- Difunde o divide valores de una fila de origen en una o más filas de destino.
-- Cada fila de origen se convierte en una o más filas en el conjunto de resultados en función del numero de columnas que se giran
-- Unpivoting incluye tres elementos:
--		1. Columnas de origen que no se han intercambiado.
--		2. Nombre a asignar a la nueva columna de valores
--		3. Nombre que se va a asignar a las columnas de nombres.
-- =============================================
DROP TABLE IF EXISTS #TablaPivot;
GO
SELECT *
INTO #TablaPivot
FROM
(
	SELECT Categoria, NombreProducto, PrecioUnitario * UnidadesDisponibles AS Total 
	FROM Productos WITH(NOLOCK)
) AS P
PIVOT (SUM(Total) FOR Categoria IN([Estante y accesorios para libros],[Discos Compactos],[Cuadros de madera])) AS TablaPivote;
GO
-- AQUI REALIZAMOS EL UNPIVOT
SELECT Categoria, NombreProducto, Total
FROM 
(
	SELECT NombreProducto, [Cuadros de madera], [Discos Compactos], [Estante y accesorios para libros]
	FROM #TablaPivot WITH(NOLOCK)
) AS P
UNPIVOT (Total FOR Categoria IN ([Cuadros de madera], [Discos Compactos], [Estante y accesorios para libros])) AS TablaUnpivot;
GO