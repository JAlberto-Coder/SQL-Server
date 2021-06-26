USE [master]
GO
-- =============================================
-- Version:		1.0.0
-- Archivo:		Esquemas-Ejemplos-De-Uso.sql
-- =============================================
-- Autor:		JAlberto-Coder
-- Fecha:		15-11-2019
-- Descripcion: Generacion de esquema en base de datos y creacion de usuario para ver el comportamiento que tienen los esquemas
-- =============================================
-- CREAMOS UN LOGIN
-- El login lo podrás ver en el Object Explorer en la parte de Instancia\Security\Logins
-- =============================================
CREATE LOGIN userDemo
WITH PASSWORD = '#user#Demo123';
GO
-- =============================================
-- CREAMOS UN USUARIO
-- El usuario lo podras ver dentro del Object Explorar en Intancia\Databases\AlgunaBaseDeDatos\Security\Users, una vez aqui en usuario podra ver el arbol de la base de datos
-- =============================================
USE Developer;
GO
CREATE USER userDemo FOR LOGIN userDemo
WITH DEFAULT_SCHEMA = esquemaDemo;
GO
-- =============================================
-- CREAMOS UN ESQUEMA
-- Se crea el esquema que le asignamos al usuario
-- =============================================
CREATE SCHEMA esquemaDemo AUTHORIZATION userDemo;
GO
-- =============================================
-- Damos permisos al usuario para crear tablas
-- =============================================
GRANT CREATE TABLE TO userDemo;
GO
-- =============================================
-- Cambiamos la opcion de ejecucion, para ejecutar scripts como el usuario userDemo
-- =============================================
SELECT USER; -- Sentencia que muestra el usuario actual
EXECUTE AS USER = 'userDemo';
SELECT USER; -- Sentencia que muestra el usuario actual
-- =============================================
-- CREAMOS UNA TABLA COMO SI FUERAMOS EL USUARIO userDemo
-- =============================================
IF OBJECT_ID('Developer.esquemaDemo.CatNivelEducativo','U') IS NOT NULL
	DROP TABLE Developer.esquemaDemo.CatNivelEducativo;
GO
CREATE TABLE Developer.esquemaDemo.CatNivelEducativo
(
	idNivelEducativo INT IDENTITY NOT NULL,
	NivelEducativo VARCHAR(100),
	FechaGeneracion DATETIME DEFAULT GETDATE() NOT NULL,
	UsuarioGeneracion VARCHAR(60) DEFAULT 'SYSTEM' NOT NULL,
	Estatus BIT DEFAULT(1) NOT NULL,
	CONSTRAINT PK_CatNivelEducativo_idNivelEducativo PRIMARY KEY(idNivelEducativo)
);
GO
-- =============================================
-- REVERTIMOS LA EJECUCION
-- =============================================
REVERT;
GO