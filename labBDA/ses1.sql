// SESIÃ“N 1, 06/10

/* ejercicio 3.1 Obtener ordenados ascendentemente los cÃ³digos de los paÃ­ses de donde son los actores */
SELECT DISTINCT cod_pais FROM actor ORDER BY cod_pais;

/* ejercicio 3.2 Obtener el cÃ³digo y el tÃ­tulo de las pelÃ­culas de aÃ±o anterior a 1970 que no estÃ©n basadas en ningÃºn libro
ordenadas por tÃ­tulo*/
SELECT cod_peli, titulo FROM pelicula WHERE anyo<1970 AND cod_lib IS NULL ORDER BY titulo;

/* ejercicio 3.3 Obtener el cÃ³digo y el nombre de los actores cuyo nombre incluye â€œJohnâ€*/
SELECT cod_act, nombre FROM actor WHERE nombre LIKE '%John%';

/* ejercicio 3.4 Obtener el cÃ³digo y el tÃ­tulo de las pelÃ­culas de mÃ¡s de 120 minutos de la dÃ©cada de los 80 */
SELECT cod_peli, titulo FROM pelicula WHERE duracion>120 AND anyo>1980 AND anyo<1990;

/* ejercicio 3.5 Obtener el cÃ³digo y el tÃ­tulo de las pelÃ­culas que estÃ©n basadas en algÃºn libro y cuyo director se apellide
â€˜Pakula*/
SELECT cod_peli, titulo FROM pelicula WHERE director LIKE '%Pakula%' AND cod_lib IS NOT NULL;

/* EJERCICIO 3.6 Â¿CuÃ¡ntas pelÃ­culas hay de mÃ¡s de 120 minutos de la dÃ©cada de los 80? */
SELECT COUNT(*) FROM pelicula WHERE duracion>120 AND anyo>1980 AND anyo<1990;

/* EJERCICIO 3.7 Â¿CuÃ¡ntas pelÃ­culas se han clasificado de los gÃ©neros de cÃ³digo 'BB5' o 'GG4' o'JH6'.*/
SELECT COUNT(*) FROM genero WHERE cod_gen='BB5' OR cod_gen='GG4' OR cod_gen='JH6';

/* EJERCICIO 3.8 Â¿De quÃ© aÃ±o es el libro mÃ¡s antiguo*/
SELECT MIN(anyo) FROM libro_peli;

/* EJERCICIO 3.9 Â¿CuÃ¡l es la duraciÃ³n media de las pelÃ­culas del aÃ±o 1987? */
SELECT AVG(duracion) FROM pelicula WHERE anyo=1987;

/* EJERCICIO 3.10 Â¿CuÃ¡ntos minutos ocupan todas las pelÃ­culas dirigidas por â€˜Steven Spielbergâ€™?*/
SELECT SUM(duracion) FROM pelicula WHERE director='Steven Spielberg';

/* CONSULTAS SOBRE VARIAS TABLAS */

/* EJERCICIO 3.11 Obtener el cÃ³digo y el tÃ­tulo de las pelÃ­culas en las que actÃºa un actor con el mismo nombre que el director
de la pelÃ­cula (ordenadas por tÃ­tulo)*/

SELECT p.cod_peli, p.titulo 
FROM pelicula p, actor a, actua ac 
WHERE a.director=p.nombre AND 
    a.cod_act=ac.cod_act AND 
    a.cod_peli=ac.cod_peli 
ORDER BY titulo;

/* EJERCICIO 3.12 Obtener el cÃ³digo y el tÃ­tulo de las pelÃ­culas clasificadas del gÃ©nero de nombre â€˜Comediaâ€™ (ordenadas por
tÃ­tulo)*/

SELECT p.cod_peli, p.titulo
FROM pelicula p, genero g, clasificacion c
WHERE p.cod_peli=c.cod_peli AND
    c.cod_gen=g.cod_gen AND
    g.nombre='Comedia'
ORDER BY p.titulo;

/* EJERCICIO 3.13 Obtener el cÃ³digo y el tÃ­tulo de las pelÃ­culas basadas en algÃºn libro anterior a 1950.*/
SELECT p.cod_peli, p.titulo
FROM pelicula p, libro_peli l
WHERE p.cod_lib=l.cod_lib AND
    l.anyo<1950
ORDER BY p.titulo;

/* EJERCICIO 3.14 Obtener el cÃ³digo y el nombre de los paÃ­ses de los actores que actÃºan en pelÃ­culas clasificadas del gÃ©nero
de nombre â€˜Comediaâ€™ (ordenados por nombre) */

SELECT p.cod_pais, p.nombre
FROM clasificacion c, pais p, pelicula pel, actor a, genero g, actua ac
WHERE p.cod_pais=a.cod_pais AND
    a.cod_act=ac.cod_act AND 
    ac.cod_peli=pel.cod_peli AND
    c.cod_peli=pel.cod_peli AND
    c.cod_gen=g.cod_gen AND
    g.cod_gen='Comedia'
ORDER BY p.nombre;



