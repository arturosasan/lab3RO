/* EJERCICIO 21. ¿Cuántas películas hay clasificadas del género de nombre ‘Comedia’ y en las que sólo aparece un actor
con el papel ‘Secundario’?*/

SELECT COUNT(cod_peli)
FROM PELICULA
WHERE cod_peli IN (
    SELECT cod_peli
    FROM CLASIFICACION
    WHERE cod_gen IN (
        SELECT cod_gen
        FROM GENERO
        WHERE nombre = 'Comedia'
    )
) AND cod_peli IN (
    SELECT cod_peli
    FROM ACTUA
    WHERE papel = 'Secundario'
    GROUP BY cod_peli
);

/* 22. Obtener el año de la primera película en la que el actor de nombre ‘Jude Law’ tuvo un papel como
‘Principal’. */


/* 3.4 Consultas universalmente cuantificadas */

/* 32. Obtener el código y el nombre de los países con actores y tales que todos los actores de ese país han
nacido en el siglo XX (ordenados por nombre).*/

SELECT p.cod_pais, p.nombre
FROM pais p
WHERE NOT EXISTS (SELECT *
				 FROM actor a
				 WHERE a.cod_pais = p.cod_pais
				 AND EXTRACT (YEAR FROM a.fecha_nac)
				 	 NOT BETWEEN 1900 AND 1999)
	  AND EXISTS (SELECT *
	  					FROM actor a 
	  					WHERE a.cod_pais=p.cod_pais)
ORDER BY p.nombre;

/* 33. Obtener el código y el nombre de los actores tales que todos los papeles que han tenido son de
‘Secundario’. Sólo interesan aquellos actores que hayan actuado en alguna película.*/

SELECT ac.cod_act, ac.nombre
FROM actor ac
WHERE EXISTS (SELECT *
					FROM actua a
					WHERE a.cod_act IS NULL)	
				AND EXISTS (SELECT *
							FROM ACTUA ac
							WHERE ac.papel='Secundario');

/*34. Obtener el código y el nombre de los actores que han aparecido en todas las películas del director ‘Guy
Ritchie’ (sólo si ha dirigido al menos una) */

SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE NOT EXISTS (SELECT *
				  FROM PELICULA p
				  WHERE director='Guy Ritchie'
				  AND NOT EXISTS (SELECT *
								 FROM ACTUA ac
								 WHERE ac.cod_act=act.cod_act AND 
								 	ac.cod_peli=p.cod_peli))
				AND EXISTS (SELECT *
							FROM PELICULA p
							WHERE p.director='Guy Ritchie');

/* 35. Resolver la consulta anterior pero para el director de nombre ‘John Steel’ */

SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE NOT EXISTS (SELECT *
				  FROM PELICULA p
				  WHERE director='John Steel'
				  AND NOT EXISTS (SELECT *
								 FROM ACTUA ac
								 WHERE ac.cod_act=act.cod_act AND 
								 	ac.cod_peli=p.cod_peli))
				AND EXISTS (SELECT *
							FROM PELICULA p
							WHERE p.director='John Steel');


/* 36. Obtener el código y el título de las películas de menos de 100 minutos en las que todos los actores que
han actuado son de un mismo país.*/


