USE Developer
GO
-- ==================================================
-- Version:		1.0.0
-- Archivo:		Select-Caracteres-Especiales.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		23-04-2021
-- Descripcion: Consulta alguna colunma que contenga algun caracter especial
-- ==================================================
CREATE TABLE #Diccionario(Palabra NVARCHAR(150), Descripcion NVARCHAR(1024));
INSERT INTO #Diccionario(Palabra, Descripcion) VALUES('diccionario', 'Repertorio 
en forma de 	libro o en soporte electrónico / en el que se recogen, según un orden determinado, las palabras o expresiones de una o más lenguas, o de una materia concreta, acompañadas de su definición, equivalencia o explicación.');

-- SELECCION DE DATOS BUSCANDO CARACTERES ESPECIALES MEDIANTE SU FILTRADO,
-- EN CASO DE TRAER DATOS, CONTIENE UN CARACTER ESPECIAL
SELECT * 
FROM #Diccionario 
WHERE 
(
	Descripcion LIKE '%'+ CHAR(9) +'%' 		-- Tab horizontal
	OR Descripcion LIKE '%'+ CHAR(08) +'%'	-- Retroseso
	OR Descripcion LIKE '%'+ CHAR(10) +'%'	-- Salto de linea
	OR Descripcion LIKE '%'+ CHAR(12) +'%'	-- Form feed
	OR Descripcion LIKE '%'+ CHAR(13) +'%'	-- Retorno de carro
	OR Descripcion LIKE '%'+ CHAR(34) +'%'	-- Espacio
	OR Descripcion LIKE '%'+ CHAR(47) +'%'	-- Diagonal /
	OR Descripcion LIKE '%'+ CHAR(92) +'%'	-- Diagonal \
);
GO