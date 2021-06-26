USE Developer
GO
-- =============================================
-- Version:		1.0.2
-- Archivo:		Select-XML.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		12-11-2019
-- Descripcion: Sentencias SELECT para la consultas y generacion de XMLs
-- =============================================
-- 20-11-2019 | JAlberto-Coder | Se agrega ejemplo XML RAW y PATH
-- =============================================
-- 24-11-2019 | JAlberto-Coder | Se agregn nivel de aislamiento WITH(NOLOCK) en cada SELECT
-- =============================================
-- 0. Para el ejemplo utilizado utilizaremos una tabla llamada Autores y libros
-- =============================================
IF OBJECT_ID('Autores', 'U') IS NULL
BEGIN
	CREATE TABLE Autores
	(
		uuidAutor UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
		Nombre VARCHAR(150) NOT NULL,
		CorreoElectronico VARCHAR(60) NOT NULL,
		FechaGeneracion DATETIME DEFAULT GETDATE() NOT NULL,
		UsuarioGeneracion VARCHAR(60) DEFAULT 'SYSTEM' NOT NULL,
		Estatus BIT DEFAULT 1 NOT NULL,
		CONSTRAINT PK_Autores_uuidAutor PRIMARY KEY(uuidAutor),
		CONSTRAINT UK_Autores_CorreoElectronico UNIQUE(CorreoElectronico)
	);
	INSERT INTO Autores (Nombre, CorreoElectronico) VALUES('Hermann Hesse', 'hermannH@dominio.com');
	INSERT INTO Autores (Nombre, CorreoElectronico) VALUES('Wilian Shakespeare', 'WilianS@dominio.com');
	PRINT 'Tabla creada y registros insertados'; 
END
GO
IF OBJECT_ID('Libros', 'U') IS NULL
BEGIN
	CREATE TABLE Libros
	(
		uuidLibro UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL,
		uuidAutor UNIQUEIDENTIFIER NOT NULL,
		Titulo VARCHAR(150) NOT NULL,
		ISBN VARCHAR(13) NOT NULL,
		XMLDetalles XML NOT NULL,
		FechaGeneracion DATETIME DEFAULT GETDATE() NOT NULL,
		UsuarioGeneracion VARCHAR(60) DEFAULT 'SYSTEM' NOT NULL,
		Estatus BIT DEFAULT 1 NOT NULL,
		CONSTRAINT PK_Libros_uuidLibro PRIMARY KEY(uuidLibro),
		CONSTRAINT FK_Libros_Autores_uuidAutor FOREIGN KEY(uuidAutor) REFERENCES Autores(uuidAutor),
		CONSTRAINT UK_Libros_ISBN UNIQUE(ISBN)
	);
	DECLARE @uuidAutor1 UNIQUEIDENTIFIER = (SELECT uuidAutor FROM Autores WITH(NOLOCK) WHERE CorreoElectronico = 'hermannH@dominio.com');
	DECLARE @uuidAutor2 UNIQUEIDENTIFIER = (SELECT uuidAutor FROM Autores WITH(NOLOCK) WHERE CorreoElectronico = 'WilianS@dominio.com');
	INSERT INTO Libros(uuidAutor, Titulo, ISBN, XMLDetalles) VALUES(@uuidAutor1, 'Demian', '9788420633398', '<Libro Titulo = "Demian"><ISBN>9788420633398</ISBN><Editorial>Alianza</Editorial><AnioEdicion>2003</AnioEdicion><Genero>Narrativa</Genero><Idioma>Español</Idioma></Libro>');
	INSERT INTO Libros(uuidAutor, Titulo, ISBN, XMLDetalles) VALUES(@uuidAutor1, 'El Lobo Estepario', '9788420666525', '<Libro Titulo = "El Lobo Estepario"><ISBN>9788420666525</ISBN><Editorial>Alianza</Editorial><AnioEdicion>2006</AnioEdicion><Genero>Narrativa</Genero><Idioma>Español</Idioma></Libro>');
	INSERT INTO Libros(uuidAutor, Titulo, ISBN, XMLDetalles) VALUES(@uuidAutor2, 'Romeo y Julieta', '9788467021707', '<Libro Titulo = "Romeo y Julieta"><ISBN>9788467021707</ISBN><Editorial>ESPASA</Editorial><AnioEdicion>2006</AnioEdicion><Genero>Clasicos de la literatura</Genero><Idioma>Español</Idioma></Libro>');
	INSERT INTO Libros(uuidAutor, Titulo, ISBN, XMLDetalles) VALUES(@uuidAutor2, 'Hamlet', '9788469808429', '<Libro Titulo = "Hamlet"><ISBN>9788469808429</ISBN><Editorial>ANAYA</Editorial><AnioEdicion>2016</AnioEdicion><Genero>Clasicos de la literatura</Genero><Idioma>Español</Idioma></Libro>');
	PRINT 'Tabla creada y registros insertados'; 
END
GO
-- =============================================
-- 1. EJEMPLO CON: XML RAW
-- =============================================
SELECT A.Nombre, L.Titulo, L.ISBN
FROM Autores A WITH(NOLOCK)
INNER JOIN Libros L WITH(NOLOCK) ON A.uuidAutor = L.uuidAutor
FOR XML RAW;
-- =============================================
-- 2. EJEMPLO CON: XML AUTO
-- =============================================
SELECT A.Nombre, L.Titulo, L.ISBN
FROM Autores A WITH(NOLOCK)
INNER JOIN Libros L WITH(NOLOCK) ON A.uuidAutor = L.uuidAutor
FOR XML AUTO;
-- =============================================
-- 3. EJEMPLO CON: XML PATH
-- =============================================
SELECT A.Nombre, L.Titulo, L.ISBN
FROM Autores A WITH(NOLOCK)
INNER JOIN Libros L WITH(NOLOCK) ON A.uuidAutor = L.uuidAutor
FOR XML PATH;
-- =============================================
-- 4. EJEMPLO CON: XML RAW y PATH
-- =============================================
DECLARE @uuidAutorIn UNIQUEIDENTIFIER = '4356C257-D091-42FF-A466-94FFFE973287';
SELECT
	(
		SELECT Nombre, CorreoElectronico FROM Autores WITH(NOLOCK) WHERE uuidAutor = @uuidAutorIn FOR XML RAW('Autor'), TYPE
	),
	(
		SELECT Titulo, ISBN FROM Libros WITH(NOLOCK) WHERE uuidAutor = @uuidAutorIn FOR XML RAW('Libro'), ROOT('Libros'), TYPE
	)
FOR XML PATH(''), ROOT('Autores');
-- =============================================
-- 5. EJEMPLO CON: XML EXPLICIT, Esta es una forma de realizar consultas de una manera mas dinamica para generar un XML de salida
-- =============================================
SELECT TOP 1 1 AS TAG -- El nombre TAG, es obligatorio
	, NULL AS PARENT -- El nombre PARENT, es obligatorio
	, NULL AS [ObrasPorAutor!1]
	, NULL AS [Libro!2!Titulo]
	, NULL AS [Libro!2!ISBN]
	, NULL AS [Libro!2!Autor]
	, NULL AS [Libro!2!CorreoAutor]
UNION ALL
SELECT 2 AS TAG
	, 1 AS PARENT
	, ''
	, L.Titulo
	, L.ISBN
	, A.Nombre
	, A.CorreoElectronico
FROM Autores A WITH(NOLOCK)
INNER JOIN Libros L WITH(NOLOCK) ON A.uuidAutor = L.uuidAutor
FOR XML EXPLICIT;
-- =============================================
-- 6. EJEMPLO CON: XQUERY,
-- NOTA: Recuerda que para hacer este tipo de consultas deberás de tener un XML ya sea en una variable o un campo tipo XML, 
-- ADEMAS EL XML DEBERA DE COINCIDIR EN LOS NODOS Y ETIQUETAS DE TODOS LOS REGISTROS, DE LO CONTRARIO PODRA OCURRIR ERROR O DEVOLVER ALGUN VALOR NULO
-- =============================================
SELECT A.Nombre AS Autor
	, L.XMLDetalles.value('(./Libro/@Titulo)[1]', 'VARCHAR(50)') AS Titulo
	, L.XMLDetalles.value('(./Libro/ISBN)[1]', 'VARCHAR(13)') AS ISBN
	, L.XMLDetalles.value('(./Libro/Editorial)[1]', 'VARCHAR(50)') AS Editorial
	, L.XMLDetalles.value('(./Libro/AnioEdicion)[1]', 'VARCHAR(4)') AS Año
	, L.XMLDetalles.value('(./Libro/Genero)[1]', 'VARCHAR(50)') AS Genero
	, L.XMLDetalles.value('(./Libro/Idioma)[1]', 'VARCHAR(30)') AS Idioma
FROM Autores A WITH(NOLOCK)
INNER JOIN Libros L WITH(NOLOCK) ON A.uuidAutor = L.uuidAutor;
GO
PRINT 'FIN DEL SCRIPT';
GO