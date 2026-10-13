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

/*EJERCICIO 3.16. Obtener el código y el nombre de los actores nacidos antes de 1950 que actúan con un papel ‘Principal’
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

/*EJERCICIO 3.17  Obtener el código, el título y el autor de los libros en los que se ha basado alguna película de la década
de los 90 (ordenados por título).*/
SELECT cod_lib, titulo, autor
FROM libro_peli
WHERE cod_lib IN (SELECT distinct cod_lib
                  FROM pelicula
                  WHERE anyo BETWEEN 1990 AND 1999
                  )
ORDER BY titulo;

/*EJERCICIO 3.18 Obtener el código, el título y el autor de los libros en los que no se haya basado ninguna película.*/
SELECT cod_lib l, titulo l, autor l
FROM libro_peli l
WHERE NOT EXISTS (SELECT *
                  FROM pelicula p
			WHERE p.cod_lib=l.cod_lib);

/* EJERCICIO 3.19 Obtener el nombre del género o géneros a los que pertenecen películas en las que no actúa ningún actor
(ordenados por nombre).*/

/* EJERCICIO 20*/

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
