# Práctica 1 — Resolución de problemas mediante búsqueda en un espacio de estados
## Memoria del trabajo — n-puzzle (SIN, curso 2026-2027)

**Autores:** `Arturo Sarrión Sánchez` y `Juan Carlos Fernandez Abril`

Este documento acompaña a los notebooks `puzzle-p2.ipynb` (Actividades 1-6) y
`alg-compare-p3.ipynb` (Actividad 7). El fichero `search.py` **no se ha modificado**: todas las
heurísticas nuevas se añaden con `register_heuristic`.

---

## 1. Introducción y objetivos

El objetivo de la práctica es **evaluar la calidad de la solución y los costes computacionales
(tiempo y memoria)** de distintas estrategias de búsqueda sobre el **n-puzzle**, e **implementar,
registrar y justificar cinco heurísticas nuevas**. Para ello se usa la librería `search.py` y se
trabaja con un estado de referencia 3×3 cuyo coste óptimo, obtenido con BFS, es **22**.

---

## 2. Representación y resolubilidad

- Tablero de `n × n` casillas con fichas `1..n²−1` y un hueco (`0`). En esta práctica `n = 3`.
- El estado se representa como **lista unidimensional** de `n²` enteros, por ejemplo
  `[7, 8, 1, 4, 0, 6, 2, 3, 5]`, que es el formato que consumen los algoritmos.
- **Operadores:** movimiento del hueco (arriba, abajo, izquierda, derecha), todos con **coste 1**.
- **Resolubilidad:** solo se puede alcanzar la mitad de las configuraciones (paridad de
  permutaciones). `isSolvable(initial, goal)` lo comprueba y `generate_random_state(size, goal)`
  genera estados siempre resolubles.
- El espacio del 8-puzzle tiene `9! = 362 880` configuraciones, de las que **181 440** son
  alcanzables desde un estado dado. Ese es el número de estados que explora la comprobación
  exhaustiva de consistencia.

---

## 3. Las cinco heurísticas implementadas

| # | Heurística | Fórmula | Intuición |
|---|---|---|---|
| 1 | Piezas descolocadas | `W(n)` = nº de fichas fuera de su posición objetivo | cada ficha mal colocada exige al menos un movimiento |
| 2 | Euclídea | `D_E(n) = Σ √((Δfila)² + (Δcol)²)` | distancia en línea recta de cada ficha a su destino |
| 3 | Filas-Columnas | `FilCol(n)`: `+1` si falla la fila y `+1` si falla la columna (máx. 2 por ficha) | cuenta los desajustes de fila/columna |
| 4 | Euclídea + LC | `D_E(n) + LC(n)` | añade a la Euclídea la penalización por conflictos lineales (2 por par invertido) |
| 5 | **Propuesta (inventada)** | `max(D_Manhattan(n), FilCol(n) + LC(n))` | combina Manhattan con `FilCol + LC` tomando el máximo |

**Sobre la heurística inventada.** Como `FilCol(n) ≤ D_Manhattan(n)`, la propuesta queda acotada
entre `D_Manhattan` y `D_Manhattan + LC`; ambas cotas son admisibles, luego la propuesta también lo
es, y además **domina a Manhattan**, por lo que A* debería expandir menos nodos. La comprobación
empírica de la Actividad 6 tampoco encuentra contraejemplos de consistencia.

---

## 4. Admisibilidad y consistencia

**Metodología** (estado de referencia 3×3, coste óptimo 22): se comprueba que `h(objetivo) = 0`,
que `h ≥ 0` y que `h(inicial) ≤ 22`; y se usa `check_consistency(..., max_states=None)`, que recorre
los **181 440 estados alcanzables** verificando `h(n) ≤ 1 + h(n')`.

| Heurística | `h(inicial)` | `h(objetivo)` | ¿Admisible? | Consistencia (181 440 estados) |
|---|---|---|---|---|
| A (Piezas descolocadas) | 7 | 0 | True | **Sí**, sin contraejemplo |
| A (Euclídea) | 13 | 0 | True | **Sí**, sin contraejemplo |
| A (filas_columnas) | 11 | 0 | True | **Sí**, sin contraejemplo |
| A (Euclídea + LC) | 13 | 0 | True | **No**: contraejemplo con 7 estados |
| A (Propuesta) | 16 | 0 | True | **Sí**, sin contraejemplo |

- **Piezas descolocadas, Euclídea, FilCol y Propuesta** son **admisibles y consistentes**: no
  encuentran contraejemplo en ninguno de los 181 440 estados alcanzables. Al ser admisibles y
  consistentes, A* con ellas devuelve la solución **óptima**.
- **Euclídea + LC** es admisible en el ejemplo (`13 ≤ 22`), pero **no consistente**: se incumple
  `h(n) ≤ 1 + h(n')` con `h(n) = 15`, `h(n') = 13` para `n = [0, 7, 1, 4, 8, 6, 2, 3, 5]`, ya que la
  distancia Euclídea apenas cambia entre ambos estados mientras `LC` cae en 2.
- **Nota (coma flotante):** la Euclídea **exacta** produce un falso contraejemplo
  (`h(n) − h(n') = 1.0000000000000018`, cuando la diferencia real es exactamente 1). Por eso la
  versión registrada devuelve la parte entera `⌊D_E(n)⌋`, que sigue siendo admisible y resulta
  consistente.
- La exploración completa de los 181 440 estados es **evidencia experimental fuerte**, pero no una
  demostración general (tal y como indica el boletín).

---

## 5. Comparativa y las dos mejores heurísticas

### 5.1. Actividad 6 — estado de referencia 3×3 (`puzzle-p2.ipynb`, coste óptimo = 22)

| Métrica | BFS | DFS(Back) | Voraz | ID | Manh | MD+LC | Euclid | IDA*Manh | Desc | FilCol | Euclid+LC | Propuesta |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| *Nodes generated* | 233 687 | 2 028 383 | 82 | 2 198 820 | 704 | **415** | 2 829 | 1 409 | 17 460 | 4 363 | 1 779 | 679 |
| *Nodes expanded* | 86 871 | 1 301 341 | 30 | 1 390 965 | 266 | **158** | 1 057 | 882 | 6 452 | 1 601 | 666 | 256 |
| *Max nodes stored* | 110 729 | **76** | 54 | 43 | 429 | 251 | 1 681 | 35 | 10 068 | 2 603 | 1 060 | 414 |
| *Solution cost* | 22 | 38 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 |
| *Search depth* | 23 | 40 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 |
| *Running time (s)* | 0,628 | 2,899 | 0,0004 | 3,144 | **0,0033** | 0,0082 | 0,0222 | 0,0041 | 0,0683 | 0,0267 | 0,0401 | 0,0170 |

Todas las heurísticas **admisibles y consistentes** obtienen el **coste óptimo 22**. Entre las
búsquedas A\*, `A (MD + LC)` es la que **menos expande (158 nodos)** y la que **menos memoria usa
(251 nodos)**, mientras que `A* (Manhattan)` es la **más rápida (0,0033 s)**.

### 5.2. Actividad 7 — 1 000 puzzles aleatorios 3×3 (`alg-compare-p3.ipynb`)

El notebook `alg-compare-p3.ipynb` ejecuta **solo las dos heurísticas elegidas** sobre 1 000 puzzles
aleatorios 3×3, midiendo la **calidad de la solución (coste)**, los **nodos expandidos** y el
**tiempo de ejecución**.

| Algoritmo | Calidad: coste medio (mín–máx) | Nodos expandidos (media) | Tiempo medio (ms) |
|---|---|---|---|
| **A\* (Manhattan)** | 21,48 (5–29) | 579,9 | **9,0** |
| **A (MD + LC)** | 21,48 (5–29) | **309,1** | 19,0 |

Ambas obtienen el **mismo coste** en los 1 000 puzzles (el **óptimo**, por ser admisibles y
consistentes, §4): `A (MD + LC)` expande **≈47 % menos nodos** y `A* (Manhattan)` es **≈2,1× más
rápida**.

### 5.3. Las dos mejores: `A (MD + LC)` y `A* (Manhattan)`

**Calidad de la solución (coste): empate.** 

En la Actividad 6 (`puzzle-p2.ipynb`) todas las
heurísticas admisibles y consistentes —y en particular las dos elegidas— resuelven el estado de
referencia con el **coste óptimo 22**; y en la Actividad 7 ambas dan también el **mismo coste**
(media 21,48) sobre los 1 000 puzzles. 

Es consecuencia de que las dos son **admisibles y
consistentes** (§4), por lo que garantizan la solución óptima.

**Coste computacional — memoria / esfuerzo de búsqueda: gana `A (MD + LC)`.** 

Ya en la Actividad 6
es la que **menos nodos expande (158)** y la que **menos memoria ocupa (251 nodos como máximo)**;
sobre los 1 000 puzzles de la Actividad 7 expande 309,1 nodos frente a los 579,9 de `A* (Manhattan)`
(≈47 % menos). Es la mejor opción cuando el cuello de botella es la memoria (tableros grandes).

**Coste computacional — tiempo: gana `A* (Manhattan)`.** Es la **más rápida** en la Actividad 6


(0,0033 s) y también en la Actividad 7 (9,0 ms frente a 19,0 ms, ≈2,1× más rápida): calcular los
conflictos lineales es más caro por nodo y ese sobrecoste supera el ahorro en expansiones de
`A (MD + LC)`.

**Por qué estas dos y no las demás (referencia a `puzzle-p2`).** 

Según la tabla de la Actividad 6, las demás heurísticas nuevas expanden notoriamente más nodos (frente a 158 de `A (MD + LC)`):
- `A (Propuesta)` => 256, 
- `A (Euclídea + LC)` => 666, 
- `A (Euclídea)` => 1 057, 
- `A (filas_columnas)`=> 1 601 y
- `A (Piezas descolocadas)` => 6 452

La `A (Propuesta)`
`max(MD, FilCol + LC)` es la siguiente mejor, pero necesita 0,0170 s (más del doble que
`A* (Manhattan)`, 0,0033 s) y expande más que `A (MD + LC)`. 

Por todo ello elegimos **`A (MD + LC)`**
(mejor en memoria/expansiones) y **`A* (Manhattan)`** (mejor en tiempo), ambas con la solución óptima.

---

## 6. Conclusión

- Se han implementado y registrado las **cinco heurísticas** de las Actividades 1-5 **sin modificar
  `search.py`**.
- Son **admisibles y consistentes** (y por tanto garantizan el óptimo): *Piezas descolocadas*,
  *Euclídea (truncada)*, *Filas-Columnas* y la heurística inventada *`max(D_Manhattan, FilCol + LC)`*.
  **No** lo es `Euclídea + LC` (admisible pero inconsistente).
- La comprobación de **los 181 440 estados alcanzables** aporta evidencia experimental muy fuerte
  sobre la consistencia (aunque no es una demostración formal).
- En los 1 000 puzzles, todas las heurísticas admisibles y consistentes obtienen el **mismo coste
  óptimo**; las diferencias están en los **nodos expandidos**, la **memoria** y el **tiempo**.
- Las **"dos mejores"** (*¡no se puede decir que una solución es más optima que otra!*) son **`A (MD + LC)`** (mejor en memoria y expansiones) y **`A* (Manhattan)`**
  (mejor en tiempo), con empate en la calidad de la solución.