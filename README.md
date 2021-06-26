﻿# SQL-Server
Scripts para desarrollar, operar y administrar bases de datos en SQL Server

**Premisas:**
* Cada archivo contiene su propia descripción de lo que hace.
* Para la ejecución de estos scripts utilizo mi propia base de datos llamada Developer, pero puedes ejecutarlos en cualquier base de datos, preferiblemente local y en una instancia de SQL Server, solo tienes que cambiar la base de datos para usar.
* Existen versiones de la instancia de SQL Server donde las sentencias pueden no funcionar, recomiendo usar una instancia a partir de la versión SQL Server 2016.
* Tener en cuenta que solo son scripts de muestra, al final si tienes que aplicarlo en un software, asegúrate de que sea la mejor opción.
* Trato de no utilizar acentos en los scripts .sql, para que al subirlos o descargarlos no se lleguen a codificar con caracteres extraños.
* Estos scripts se han ido generando a partir de mi experiencia, y de manera clara muchas referencias encontradas especialmente de Microsoft además de enseñanzas aprendidas.

**Repositorio:**
* **DCL-Data-Control-Language:**
  * Contiene sentencias para el control de accesos, permisos, roles que tienen los usuarios de la base de datos.
* **DDL-Data-Definition-Language:**
  * Contiene queries para la definicion de objetos dentro de la instancia de SQL Server, comandos como CREATE, ALTER, DROP y TRUNCATE (En caso de aplicar)
* **DML-Data-Manipulation-Language:**
  * Contiene queries para la manipulacion de datos, encontrares sentencias INSERT, UPDATE, DELETE, ETC.
* **DQL-DataQuery-Language:**
  * Contiene queries para la selección de datos con la sentencia SELECT.
* **SQL-Admin:**
  * Contiene sentencias que son utilizadas por un DBA en SQL Server.
* **SQL-KonwLedge:**
  * Contiene Diapositivas sobre algún tema en especifico manejado por SQL Server, también se encuentra el editable, utilizando la herramienta draw.io.
* **SQL-Operation:**
  * Contiene scripts que son utilizados por un DBA mediante una solicitud para tener un control y backup de estos.
* **SQL-Topics**: 
  * Contiene temas generales y especificos de SQL Server.
* **TLC-Transaction-Control-Language**: 
  * Contiene sentencias referentes al manejo de errores y transacciones.

_A veces el mejor método para hacer algo es lanzarse. (Motoko Kusanagi)_
