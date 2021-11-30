USE [master]
GO
-- ==================================================
-- Versión:		1.0.0
-- Archivo:		ufn_Cadena_Separacion_Por_Mayusculas.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		30-11-2021
-- Descripción:	Función que separa una cadena que se encuentra junto, donde cada palabra esta en mayúsculas, 
--				Por ejemplo: JorgeAlberto a Jorge Alberto
-- ==================================================
CREATE OR ALTER FUNCTION dbo.ufn_Cadena_Separacion_Por_Mayusculas(@E_Cadena VARCHAR(254))
RETURNS VARCHAR(254)
AS
BEGIN
	
	IF (SELECT ISNUMERIC(@E_Cadena)) = 1
		GOTO FIN;

	DECLARE @Tbl_AbecedarioMayusculas TABLE(Letra CHAR(1), CadenaASCII SMALLINT PRIMARY KEY, PROCESADO BIT DEFAULT(0));

	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('A', ASCII('A'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('B', ASCII('B'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('C', ASCII('C'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('D', ASCII('D'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('E', ASCII('E'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('F', ASCII('F'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('G', ASCII('G'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('H', ASCII('H'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('I', ASCII('I'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('J', ASCII('J'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('K', ASCII('K'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('L', ASCII('L'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('M', ASCII('M'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('N', ASCII('N'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('O', ASCII('O'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('P', ASCII('P'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('Q', ASCII('Q'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('R', ASCII('R'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('S', ASCII('S'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('T', ASCII('T'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('V', ASCII('V'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('W', ASCII('W'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('X', ASCII('X'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('Y', ASCII('Y'));
	INSERT INTO @Tbl_AbecedarioMayusculas(Letra,CadenaASCII) VALUES('Z', ASCII('Z'));
	
	DECLARE @Largo INT = LEN(@E_Cadena)
		, @I INT = 0
		, @Cadena VARCHAR(254) = '';

	DECLARE @LetraASCII SMALLINT
		, @LetraValidacion CHAR(1);

	WHILE @I <= @Largo
	BEGIN
		
		SELECT @LetraValidacion = SUBSTRING(@E_Cadena, @I, 1);
		SELECT @Cadena += @LetraValidacion;

		WHILE EXISTS(SELECT TOP(1) 1 FROM @Tbl_AbecedarioMayusculas WHERE PROCESADO = 0)
		BEGIN
			
			SELECT TOP(1) @LetraASCII = CadenaASCII FROM @Tbl_AbecedarioMayusculas WHERE PROCESADO = 0;

			IF (ASCII(@LetraValidacion) = @LetraASCII)
			BEGIN
				SELECT @Cadena = LEFT(@Cadena, LEN(@Cadena) -1);
				SELECT @Cadena += CONCAT(' ', @LetraValidacion);
			END

			UPDATE @Tbl_AbecedarioMayusculas
			SET PROCESADO = 1
			WHERE CadenaASCII = @LetraValidacion;
		END	

		UPDATE @Tbl_AbecedarioMayusculas
		SET PROCESADO = 0;

		SELECT @I += 1;
	END

	SELECT @Cadena = LTRIM(@Cadena), @E_Cadena = LTRIM(@E_Cadena);
	SELECT @Cadena = RTRIM(@Cadena), @E_Cadena = RTRIM(@E_Cadena);

	IF (SELECT COUNT(1) FROM STRING_SPLIT(@Cadena, ' ')) > 5
		RETURN @E_Cadena;
	
	FIN:
	RETURN @Cadena;
END
GO