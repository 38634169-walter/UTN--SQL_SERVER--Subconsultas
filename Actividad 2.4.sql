USE Larabox



--1
GO
SELECT a.Nombre,a.Extension FROM Archivos AS a
WHERE a.Tamaño > (
	SELECT AVG(a2.Tamaño) FROM  Archivos AS a2 
)



--2
GO
SELECT p.ID, p.Mes, p.Año, fp.Nombre AS [Forma de pago],p.Importe
FROM Pagos AS p
INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
WHERE p.Importe > (
	SELECT AVG(p2.Importe) FROM Pagos AS p2
)



--3
GO
SELECT DISTINCT u.Nombreusuario, dp.Nombres, dp.Apellidos 
FROM DatosPersonales AS dp 
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE u.ID NOT IN(
	SELECT s2.IDUsuario FROM Suscripciones AS s2 WHERE YEAR(s2.Inicio) = 2019
)

GO
SELECT DISTINCT u.Nombreusuario, dp.Nombres, dp.Apellidos 
FROM DatosPersonales AS dp 
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE u.ID <> ALL(
	SELECT s2.IDUsuario FROM Suscripciones AS s2 WHERE YEAR(s2.Inicio) = 2019
)



--4 preguntar sole
GO
SELECT dp.Apellidos, dp.Nombres, dp.Email,dp.Telefono,dp.Celular 
FROM DatosPersonales AS dp 
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE u.ID <> ALL (
	SELECT a.IDUsuario FROM Archivos AS a
)

GO
SELECT u.ID,dp.Apellidos, dp.Nombres, dp.Email,dp.Telefono,dp.Celular 
FROM DatosPersonales AS dp 
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE u.ID NOT IN (
	SELECT a.IDUsuario FROM Archivos AS a
)



--5
GO
SELECT dp.ID,dp.Apellidos,dp.Nombres FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE u.ID NOT IN (
	SELECT u2.ID FROM Usuarios AS u2
	INNER JOIN Suscripciones AS s2 ON s2.IDUsuario=u2.ID
	INNER JOIN Pagos AS p ON p.IDSuscripcion=s2.ID
)

GO
SELECT dp.ID,dp.Apellidos,dp.Nombres FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE u.ID <> ALL (
	SELECT u2.ID FROM Usuarios AS u2
	INNER JOIN Suscripciones AS s2 ON s2.IDUsuario=u2.ID
	INNER JOIN Pagos AS p ON p.IDSuscripcion=s2.ID
)



--6
GO 
SELECT * FROM FormasPago AS fp
WHERE fp.ID <> ALL (
	SELECT fp2.ID FROM Pagos AS p
	INNER JOIN FormasPago AS fp2 ON p.IDFormaPago = fp2.ID
	WHERE YEAR(p.Fecha) = 2019 AND MONTH(p.Fecha)=12
)



--7
GO
SELECT a.Nombre FROM Archivos AS a 
WHERE a.Tamaño > ALL (
	SELECT a2.Tamaño FROM Archivos AS a2 WHERE a2.Extension='XLS'
)

GO
SELECT a.Nombre FROM Archivos AS a 
WHERE a.Tamaño > (
	SELECT MAX(a2.Tamaño) FROM Archivos AS a2 WHERE a2.Extension='XLS'
)



--8
GO 
SELECT * FROM Archivos AS a
WHERE a.Tamaño < SOME(
	SELECT A2.Tamaño FROM Archivos AS a2 
	WHERE a2.Extension IN ('DOC') AND YEAR(a2.Creacion)=2021
)

GO 
SELECT * FROM Archivos AS a
WHERE a.Tamaño < (
	SELECT MAX(A2.Tamaño) FROM Archivos AS a2 
	WHERE a2.Extension IN ('DOC') AND YEAR(a2.Creacion)=2021
)



--9
GO 
SELECT p.ID, dp.Apellidos, u.Nombreusuario, p.Mes, p.Año,p.Importe
FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID
INNER JOIN Suscripciones AS s ON s.IDUsuario=u.ID
INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
WHERE p.Importe > ALL(
	SELECT p2.Importe FROM Pagos AS p2 
	INNER JOIN FormasPago AS fp ON fp.ID=p2.IDFormaPago
	WHERE fp.Nombre = 'Efectivo' AND YEAR(p2.Fecha)=2020
);



--10
GO
SELECT dp.Apellidos, dp.Nombres,u.Nombreusuario,
( 
	SELECT COUNT(a.Extension) FROM Archivos AS a 
	WHERE a.Extension = 'AVI' AND a.IDUsuario=u.ID
) AS [Cantidad AVI],
(
	SELECT COUNT(a2.Extension) FROM Archivos AS a2
	WHERE a2.Extension='XLS' AND a2.IDUsuario=u.ID
) AS [Cantidad XLS]
FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON dp.ID=u.ID;



--11
GO
SELECT dp.Apellidos,dp.Nombres,u.Nombreusuario,
(
	SELECT isnull(SUM(p.Importe),0) FROM Suscripciones AS s
	INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
	INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
	WHERE fp.Nombre='Efectivo' AND s.IDUsuario=u.ID
) AS [Total abonado en efectivo],
(
	SELECT isnull(SUM(p.Importe),0) FROM Suscripciones AS s
	INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
	INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
	WHERE fp.Nombre='Billetera electronica' AND s.IDUsuario=u.ID
)[Total abonado en billetera electronica]
FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID;



--12
GO 
SELECT dp.Apellidos,dp.Nombres,u.Nombreusuario,
(
	SELECT COUNT(a.Tamaño) FROM Archivos AS a
	WHERE a.Tamaño / 1024.0 < 75
) AS [Cantidad de archivos menor a 75MB],
(
	SELECT COUNT(a.Tamaño) FROM Archivos AS a
	WHERE a.Tamaño / 1024.0 >= 75
) AS [Cantidad de archivos mayor igual a 75MB]
FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID;



--13
GO 
SELECT * FROM (
	SELECT  dp.Nombres,dp.Apellidos,u.Nombreusuario,
	(
		SELECT SUM(p.Importe) FROM Suscripciones AS s
		INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
		INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
		WHERE fp.Nombre='Efectivo' AND s.IDUsuario=u.ID
	)AS [Pagos en efectivo],
	(
		SELECT SUM(p.Importe) FROM Suscripciones AS s
		INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
		INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
		WHERE fp.Nombre='Billetera electrónica' AND s.IDUsuario=u.ID
	)AS [Pagos en billetera electronica]
	FROM DatosPersonales AS dp
	INNER JOIN Usuarios AS u ON dp.ID=u.ID
) AS Tablita
WHERE Tablita.[Pagos en efectivo]<Tablita.[Pagos en billetera electronica]/2;


GO
SELECT dp.Apellidos,dp.Nombres,u.Nombreusuario 
FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE (
		SELECT SUM(p.Importe) FROM Suscripciones AS s
		INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
		INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
		WHERE fp.Nombre = 'Efectivo' AND s.IDUsuario=u.ID
	) < (
		SELECT SUM(p.Importe) FROM Suscripciones AS s
		INNER JOIN Pagos AS p ON p.IDSuscripcion=s.ID
		INNER JOIN FormasPago AS fp ON fp.ID=p.IDFormaPago
		WHERE fp.Nombre = 'Billetera electrónica' AND s.IDUsuario=u.ID
	)/2;
	
	
	
--14
GO
SELECT dp.Apellidos, dp.Nombres,u.Nombreusuario 
FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE ( 
		SELECT COUNT(a.Extension) FROM Archivos AS a
		WHERE a.Extension='XLS' AND a.IDUsuario=u.ID
	) = (
		SELECT COUNT(a.Extension) FROM Archivos AS a
		WHERE a.Extension='AVI' AND a.IDUsuario=u.ID
	);



--15
GO
SELECT * FROM (
	SELECT dp.Nombres,dp.Apellidos,u.Nombreusuario,
	(
		SELECT COUNT(a.Extension) FROM Archivos AS a
		WHERE a.Extension='XLS' AND a.IDUsuario=u.ID
	) AS [ArchivosXLS],
	(
		SELECT COUNT(a.Extension) FROM Archivos AS a
		WHERE a.Extension='AVI' AND a.IDUsuario=u.ID
	)AS [ArchivosAVI]
	FROM Usuarios AS u
	INNER JOIN DatosPersonales AS dp ON dp.ID=u.ID
) AS Tablita
WHERE Tablita.ArchivosXLS > Tablita.ArchivosAVI AND Tablita.ArchivosAVI > 0;


GO
SELECT dp.Nombres,dp.Apellidos,u.Nombreusuario FROM DatosPersonales AS dp
INNER JOIN Usuarios AS u ON u.ID=dp.ID
WHERE(
		SELECT COUNT(a.Extension) FROM Archivos AS a 
		WHERE a.Extension='XLS' AND a.IDUsuario=u.ID
	) > (
		SELECT COUNT(a.Extension) FROM Archivos AS a 
		WHERE a.Extension='AVI' AND a.IDUsuario=u.ID
	)
	AND (
		SELECT COUNT(a.Extension) FROM Archivos AS a 
		WHERE a.Extension='AVI' AND a.IDUsuario=u.ID
	) > 0;



--16
SELECT COUNT(u.ID) AS [Cantidad de usuarios] 
FROM DatosPersonales AS dp 
INNER JOIN Usuarios AS u on u.ID=dp.ID
WHERE (
		SELECT COUNT(a.Extension) FROM Archivos AS a
		WHERE a.Extension = 'AVI' AND a.IDUsuario=u.ID
	) > (
		SELECT COUNT(a.Extension) FROM Archivos AS a
		WHERE a.Extension ='XLS' AND a.IDUsuario=u.ID
	)*2;