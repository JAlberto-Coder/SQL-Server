USE AdventureWorks2019
GO
-- ==================================================
-- Version: 	1.0.0
-- Archivo:		Exportacion-De-Datos.sql
-- ==================================================
-- Autor:		JAlberto-Coder
-- Fecha:		29-30-2021
-- Descripcion:	Sentencias bcp que se pueden realizar en MSSQL
-- ==================================================
-- SENTENCIA PARA EXPORTAR UNA TABLA A UN ARCHIVO CSV POR MEDIO DE UN BCP
-- ==================================================
bcp AdventureWorks2019.Person.AddressType out C:\Adres.csv -c -t"," -T

bcp AdventureWorks2019.Person.AddressType out C:\Adres.csv -c -t"," -T -S LocalHost -U UsuarioTest -P 123456 

bcp "SELECT AddressTypeID, Name FROM AdventureWorks2019.Person.AddressType" queryout C:\AddressType_2.csv -c -t"," -T

bcp "SELECT AddressTypeID, Name FROM AdventureWorks2019.Person.AddressType" queryout C:\AddressType_2.csv -c -t"," -T -S LocalHost -U UsuarioTest -P 123456 

-- ==================================================
-- SENTENCIA PARA EXPORTAR UNA CONSULTA A UN ARCHIVO CSV POR MEDIO DE UN SQLCMD
-- ==================================================
SQLCMD -S LOCALHOST -E -Q "SELECT AddressTypeID, Name FROM AdventureWorks2019.Person.AddressType" -s "," -o "C:\AddressType.csv" 