/* 3.1 CONSULTAS SOBRE UNA SOLA TABLA*/

/* EJERCICIO 1 Obtener ordenados ascendentemente los códigos de los países de donde son los actores */

SELECT DISTINCT cod_pais FROM actor ORDER BY cod_pais;

/* EJERCICIO 2 Obtener el código y el título de las películas de año anterior a 1970 que no están basadas en ningún libro ordenadas por título*/

SELECT cod_peli, titulo FROM pelicula WHERE anyo<1970 AND cod_lib IS NULL ORDER BY titulo;

/* EJERCICIO 3 Obtener el código y el nombre de los actores cuyo nombre incluye "John"*/

SELECT cod_act, nombre FROM actor WHERE nombre LIKE '%John%';

/* EJERCICIO 4 Obtener el código y el título de las películas de más de 120 minutos de la década de los 80 */

SELECT cod_peli, titulo FROM pelicula WHERE duracion>120 AND anyo>1980 AND anyo<1990;

/* EJERCICIO 5 Obtener el código y el título de las películas que están basadas en algún libro y cuyo director se apellide ‘Pakula’*/

SELECT cod_peli, titulo FROM pelicula WHERE director LIKE '%Pakula%' AND cod_lib IS NOT NULL;

/* EJERCICIO 6 ¿Cuántas películas hay de más de 120 minutos de la década de los 80? */

SELECT COUNT(*) FROM pelicula WHERE duracion>120 AND anyo>1980 AND anyo<1990;

/* EJERCICIO 7 ¿Cuántas películas se han clasificado de los géneros de código 'BB5' o 'GG4' o'JH6'.*/

SELECT COUNT(*) FROM genero WHERE cod_gen='BB5' OR cod_gen='GG4' OR cod_gen='JH6';

/* EJERCICIO 8 ¿De qué año es el libro más antiguo*/

SELECT MIN(anyo) FROM libro_peli;

/* EJERCICIO 9 ¿Cuál es la duración media de las películas del año 1987? */

SELECT AVG(duracion) FROM pelicula WHERE anyo=1987;

/* EJERCICIO 10 ¿Cuántos minutos ocupan todas las películas dirigidas por â€˜Steven Spielbergâ€™?*/

SELECT SUM(duracion) FROM pelicula WHERE director='Steven Spielberg';

/* 3.2 CONSULTAS SOBRE VARIAS TABLAS */

/* EJERCICIO 11 Obtener el código y el título de las películas en las que actúa un actor con el mismo nombre que el director de la película (ordenadas por título)*/

SELECT p.cod_peli, p.titulo 
FROM pelicula p, actor a, actua ac 
WHERE a.director=p.nombre AND 
    a.cod_act=ac.cod_act AND 
    a.cod_peli=ac.cod_peli 
ORDER BY titulo;

/* EJERCICIO 12 Obtener el código y el título de las películas clasificadas del género de nombre 'Comedia' (ordenadas por
título)*/

SELECT p.cod_peli, p.titulo
FROM pelicula p, genero g, clasificacion c
WHERE p.cod_peli=c.cod_peli AND
    c.cod_gen=g.cod_gen AND
    g.nombre='Comedia'
ORDER BY p.titulo;

/* EJERCICIO 13 Obtener el código y el título de las películas basadas en algún libro anterior a 1950.*/

SELECT p.cod_peli, p.titulo
FROM pelicula p, libro_peli l
WHERE p.cod_lib=l.cod_lib AND
    l.anyo<1950
ORDER BY p.titulo;

/* EJERCICIO 14 Obtener el código y el nombre de los países de los actores que actúan en películas clasificadas del género de nombre 'Comedia' (ordenados por nombre) */

SELECT p.cod_pais, p.nombre
FROM clasificacion c, pais p, pelicula pel, actor a, genero g, actua ac
WHERE p.cod_pais=a.cod_pais AND
    a.cod_act=ac.cod_act AND 
    ac.cod_peli=pel.cod_peli AND
    c.cod_peli=pel.cod_peli AND
    c.cod_gen=g.cod_gen AND
    g.cod_gen='Comedia'
ORDER BY p.nombre;

/* 15. Resolver los ejercicios 11, 12, 13 y 14 con subconsultas. Las soluciones son exactamente las mismas.*/

/* 15.1*/
SELECT p.cod_peli, p.titulo 
FROM pelicula p 
WHERE p.director IN (SELECT a.nombre
                     FROM actor a, actua at
                     WHERE a.cod_act=at.cod_act AND 
                           at.cod_peli= p.cod_peli)
ORDER BY p.titulo;

/*15.2*/
SELECT p.cod_peli, p.titulo
FROM pelicula p
WHERE p.cod_peli IN (SELECT c.cod_peli
		     FROM clasificacion c, genero g
		     WHERE c.cod_gen=g.cod_gen AND
                     g.nombre='Comedia')
ORDER BY p.titulo;

/* 15.3*/
SELECT p.cod_peli, p.titulo
FROM pelicula p 
WHERE p.cod_lib IN (SELECT l.cod_lib
		    FROM libro_peli l
		    WHERE l.anyo < 1950)
ORDER BY p.titulo;

/* 15.4 */
SELECT p.cod_pais, p.nombre
FROM pais p
WHERE p.cod_pais IN (
    SELECT a.cod_pais
    FROM actor a
    JOIN actua ac ON ac.cod_act = a.cod_act
    JOIN pelicula pel ON pel.cod_peli = ac.cod_peli
    JOIN clasificacion c ON c.cod_peli = pel.cod_peli
    JOIN genero g ON g.cod_gen = c.cod_gen
    WHERE g.cod_gen = 'Comedia'
)
ORDER BY p.nombre;

/* EJERCICIO 16. Obtener el código y el nombre de los actores nacidos antes de 1950 que actúan con un papel ‘Principal’ 
en alguna película (ordenados por nombre). */

SELECT cod_act, nombre
FROM actor
WHERE fecha_nac<'01-01-1950'
   AND cod_act IN (
      SELECT cod_act
      FROM ACTUA
      WHERE papel = 'Principal'
  )
ORDER BY nombre;

/* EJERCICIO 17  Obtener el código, el título y el autor de los libros en los que se ha basado alguna película de la década de los 90 (ordenados por título).*/

SELECT cod_lib, titulo, autor
FROM libro_peli
WHERE cod_lib IN (SELECT distinct cod_lib
                  FROM pelicula
                  WHERE anyo BETWEEN 1990 AND 1999
                  )
ORDER BY titulo;

/* EJERCICIO 18 Obtener el código, el título y el autor de los libros en los que no se haya basado ninguna película.*/

SELECT cod_lib l, titulo l, autor l
FROM libro_peli l
WHERE NOT EXISTS (SELECT *
                  FROM pelicula p
			WHERE p.cod_lib=l.cod_lib);

/* EJERCICIO 19 Obtener el nombre del género o géneros a los que pertenecen películas en las que no actúa ningún actor (ordenados por nombre).*/

SELECT g.nombre
FROM genero g
WHERE g.cod_gen IN (
                    SELECT ca.cod_gen
                    FROM clasificacion ca
                    WHERE ca.cod_peli IN (
                                            SELECT p.cod_peli
                                            FROM pelicula p
                                            WHERE NOT p.cod_PELI IN (
                                                                        SELECT a.cod_peli
                                                                        FROM actua a
                                                                        WHERE NOT a.cod_act IS NULL
                                                                        )
                    )
)
ORDER BY g.nombre;

/* EJERCICIO 20 Obtener el título de los libros en los que se haya basado alguna película en la que no hayan actuado actores del país de nombre ‘USA’ (ordenados por título).*/

SELECT l.titulo
FROM libro_peli l
WHERE l.cod_lib IN (SELECT DISTINCT p.cod_lib
                    FROM pelicula p 
                    WHERE NOT EXISTS (SELECT *
                                      FROM actua ac
                                      WHERE ac.cod_peli=p.cod_peli
                                            AND EXISTS (
                                                SELECT *
                                                FROM actor a, pais pa
                                                WHERE a.cod_act=ac.cod_act
                                                      AND a.cod_pais=pa.cod_pais
                                                      AND pa.nombre='USA')))
ORDER BY l.titulo;

/* EJERCICIO 21. ¿Cuántas películas hay clasificadas del género de nombre ‘Comedia’ y en las que sólo aparece un actor con el papel ‘Secundario’?*/

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

/* EJERCICIO 22. Obtener el año de la primera película en la que el actor de nombre ‘Jude Law’ tuvo un papel como ‘Principal’. */

SELECT MIN(p.anyo )
FROM Pelicula p
WHERE p.cod_peli IN (
    SELECT ac.cod_peli
    FROM actua ac
    WHERE ac.papel = 'Principal' AND ac.cod_act IN (
                                                    SELECT a.cod_act
                                                    FROM ACtor a
                                                    WHERE a.nombre = 'Jude Law'
                                                    )
);

/* EJERCICIO 23 Obtener el código y el nombre de actor o actores más viejos.*/

SELECT a.cod_act, a.nombre
FROM Actor a
WHERE a.fecha_nac <= ALL (
                        SELECT a.fecha_nac
                        FROM actor a
);

/* EJERCICIO 24 Obtener el código, el nombre y la fecha de nacimiento del actor más viejo nacido en el año 1940.*/

SELECT a.cod_act, a.nombre , a.fecha_nac
FROM Actor a
WHERE a.fecha_nac =(
                    SELECT MIN(a.fecha_nac)
                    FROM actor a
                    WHERE (EXTRACT (YEAR FROM a.fecha_nac)) BETWEEN 1940 AND 1949
);

/* EJERCICIO 25 Obtener el nombre del género (o de los géneros) en los que se ha clasificado la película más larga.*/

SELECT g.nombre
FROM genero g
where g.cod_gen in(
                SELECT ca.cod_gen
                FROM clasificacion ca
                WHERE ca.cod_peli in(
                                    SELECT p.cod_peli
                                    FROM pelicula p
                                    WHERE p.duracion = (
                                                        SELECT MAX(p.duracion)
                                                        FROM pelicula p
                                                        )
                                    )
) ORDER BY g.nombre;

/* EJERCICIO 26 Obtener el código y el título de los libros en los que se han basado películas en las que actúan actores del 
país de nombre España (ordenados por título).*/

SELECT l.cod_lib, l.titulo
FROM libro_peli l
WHERE l.cod_lib IN(
                    SELECT p.cod_lib
                    FROM pelicula p
                    WHERE p.cod_peli IN (
                                        SELECT a.cod_peli
                                        FROM actua a
                                        WHERE a.cod_act IN (
                                                            SELECT ac.cod_act
                                                            FROM actor ac
                                                            WHERE ac.cod_pais IN (
                                                                                    SELECT pa.cod_pais
                                                                                    FROM pais pa
                                                                                    WHERE pa.nombre = 'España'
                                                                                )
                                                            )
                                        )
) ORDER BY g.titulo;

/* EJERCICIO 27 Obtener el título de las películas anteriores a 1950 clasificadas en más de un género (ordenadas por título)*/

SELECT p.titulo
FROM pelicula p
WHERE anyo < 1950 AND 1< (
                        SELECT count(ca.cod_gen)
                        FROM clasificacion ca
                        WHERE ca.cod_peli = p.cod_peli
);

/* EJERCICIO 28 Obtener la cantidad de películas en las que han participado menos de 4 actores.*/

SELECT COUNT(*)
FROM pelicula p
WHERE 4 > (
            SELECT count(a.cod_act)
            FROM actua a
            WHERE a.cod_peli = p.cod_peli
);

/* EJERCICIO 29 Obtener los directores que han dirigido más de 250 minutos entre todas sus películas.*/

SELECT DISTINCT p.director
FROM pelicula p
WHERE 250 <(
            SELECT SUM (a.duracion)
            FROM pelicula a
            WHERE p.director = a.director
);

/* EJERCICIO 30 Obtener el año o años en el que nacieron más de 3 actores.*/

SELECT DISTINCT extract (YEAR FROM a.fecha_nac)
FROM actor a
WHERE 3 < (
            SELECT COUNT( b.nombre)
            FROM actor b
            WHERE extract (year from a.fecha_nac)=extract (year from b.fecha_nac)
);

/* EJERCICIO 31 Obtener el código y nombre del actor más joven que ha participado en una película clasificada del género de código ‘DD8’.*/

/* 3.4 CONSULTAS UNIVERSAL CUANTIFICADAS */

/* EJERCICIO 32. Obtener el código y el nombre de los países con actores y tales que todos los actores de ese país han
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

/* EJERCICIO 33. Obtener el código y el nombre de los actores tales que todos los papeles que han tenido son de ‘Secundario’. 
Sólo interesan aquellos actores que hayan actuado en alguna película.*/

SELECT ac.cod_act, ac.nombre
FROM actor ac
WHERE EXISTS (SELECT *
					FROM actua a
					WHERE a.cod_act IS NULL)	
				AND EXISTS (SELECT *
							FROM ACTUA ac
							WHERE ac.papel='Secundario');

/* EJERCICIO 34. Obtener el código y el nombre de los actores que han aparecido en todas las películas del director ‘Guy Ritchie’ 
(sólo si ha dirigido al menos una) */

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

/* EJERCICIO 35. Resolver la consulta anterior pero para el director de nombre ‘John Steel’ */

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

/* EJERCICIO 36. Obtener el código y el título de las películas de menos de 100 minutos en las que todos los actores que han actuado son de un mismo país.*/

SELECT p.cod_peli,p.titulo
FROM pelicula p
WHERE EXISTS (
              SELECT *
              FROM pelicula pe
              WHERE pe.duracion <100 AND pe.cod_peli = p.cod_peli
              ) AND p.cod_peli IN(
                                  SELECT ac.cod_peli
                                  FROM actua ac
                                  WHERE ac.cod_act IN (
                                                      SELECT a.cod_act
                                                      FROM actor a
                                                      WHERE NOT EXISTS (
                                                                        SELECT *
                                                                        FROM actor a2
                                                                        WHERE a.cod_pais <> a2.cod_pais AND a2.cod_act 
                                                                        IN (
                                                                            SELECT ac2.cod_act
                                                                            FROM actua ac2
                                                                            WHERE ac2.cod_peli = p.cod_peli
                                                                            )
                                                                        )
                                                      )
                );
/* EJERCICIO 37 Obtener el código, el título y el año de las películas en las que haya actuado algún actor si se cumple que
todos los actores que han actuado en ella han nacido antes del año 1943 (hasta el 31/12/1942).*/

SELECT p.cod_peli,p.titulo, p.anyo
FROM pelicula p
WHERE EXISTS (
                SELECT *
                FROM actua ac1
                WHERE ac1.cod_peli = p.cod_peli
                ) AND NOT EXISTS (
                                    SELECT *
                                    FROM actua ac
                                    WHERE ac.cod_peli = p.cod_peli AND ac.cod_act 
                                    IN (
                                        SELECT a.cod_act
                                        FROM actor a
                                        WHERE EXTRACT (YEAR FROM a.fecha_nac) >=1943
                                    )
)ORDER BY p.titulo;

/* EJERCICIO 38 Obtener el código y el nombre de cada país si se cumple que todos sus actores han actuado en al menos
una película de más de 120 minutos. (Ordenados por nombre).*/ 

SELECT pa.cod_pais, pa.nombre
FROM pais pa
WHERE NOT EXISTS (
                    SELECT *
                    FROM actor a
                    WHERE a.cod_pais = pa.cod_pais AND a.cod_act NOT IN (
                                                                            SELECT ac.cod_act
                                                                            FROM actua ac
                                                                            WHERE EXISTS (
                                                                            SELECT *
                                                                            FROM pelicula p
                                                                            WHERE p.cod_peli = ac.cod_peli AND p.duracion > 120
                                                                            )
                                                                        )
                                                                        ) AND EXISTS (
                                                                            SELECT *
                                                                            FROM actor ac1
                                                                            WHERE ac1.cod_pais = pa.cod_pais AND ac1.cod_act IN(
                                                                            SELECT ac2.cod_act
                                                                            FROM actua ac2
                                                                        )
);

/* 3.5 CONSULTAS AGRUPADAS*/