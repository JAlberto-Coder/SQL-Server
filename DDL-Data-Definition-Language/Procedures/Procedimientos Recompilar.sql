USE Developers
GO

-- ==================================================
-- Versión: 1.0
-- ==================================================
-- 03-06-2023 | JAlberto-Coder
-- ==================================================
CREATE PROCEDURE sis.usp_ProcedimientosAlmacenados_Recompilar
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcedureName NVARCHAR(128);
    DECLARE @SQL NVARCHAR(MAX);

    CREATE TABLE #UserProcedures(
        ProcedureName NVARCHAR(128)
    );

    INSERT INTO #UserProcedures (ProcedureName)
    SELECT [name]
    FROM sys.objects
    WHERE type = 'P' AND is_ms_shipped = 0;

    WHILE EXISTS (SELECT * FROM #UserProcedures)
    BEGIN
        SELECT TOP 1 @ProcedureName = ProcedureName
        FROM #UserProcedures;

        SET @SQL = 'EXEC sp_recompile ''' + @ProcedureName + '''';

        EXEC sp_executesql @SQL;

        DELETE FROM #UserProcedures
        WHERE ProcedureName = @ProcedureName;
    END

    DROP TABLE #UserProcedures;
END
GO