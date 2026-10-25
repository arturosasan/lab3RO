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
| A (Piezas descolocadas) | 7 | 0 | Sí | **Sí**, sin contraejemplo |
| A (Euclídea) | 13 | 0 | Sí | **Sí**, sin contraejemplo |
| A (Filas-Columnas) | 11 | 0 | Sí | **Sí**, sin contraejemplo |
| A (Euclídea + LC) | 13 | 0 | Sí (en el ejemplo) | **No**: contraejemplo con 7 estados |
| A (Propuesta) | 16 | 0 | Sí | **Sí**, sin contraejemplo |

- **Piezas descolocadas, Euclídea, Filas-Columnas y Propuesta** son **admisibles** (comprobado en
  el estado de referencia) y **consistentes** (no aparece contraejemplo en ninguno de los 181 440
  estados alcanzables). Al ser admisibles y consistentes, A* con ellas devuelve la solución
  **óptima**.
- **Euclídea + LC** no supera el coste óptimo en el ejemplo (`13 ≤ 22`), pero **no es consistente**:
  se incumple `h(n) ≤ 1 + h(n')` con `h(n) = 15` y `h(n') = 13` para
  `n = [0, 7, 1, 4, 8, 6, 2, 3, 5]`, ya que la distancia Euclídea apenas cambia entre ambos estados
  mientras `LC` cae en 2. Su admisibilidad general no se ha demostrado.
- **Nota (coma flotante):** la Euclídea **exacta** produce un falso contraejemplo
  (`h(n) − h(n') = 1.0000000000000018`, cuando la diferencia real es exactamente 1). Por eso la
  versión registrada devuelve la parte entera `⌊D_E(n)⌋`, que sigue siendo admisible y resulta
  consistente.
- La exploración completa de los 181 440 estados es **evidencia experimental fuerte**, pero no una
  demostración general (tal y como indica el boletín).

---

## 5. Comparativa y las dos mejores heurísticas

### 5.1. Actividad 6 — estado de referencia 3×3 (`puzzle-p2.ipynb`, coste óptimo = 22)

| Métrica | BFS | DFS(Back) | Voraz | ID | Manh | MD+LC | Euclídea | IDA*Manh | Desc | FilCol | Euclídea+LC | Propuesta | Nueva |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| *Nodes generated* | 233 687 | 2 028 383 | 82 | 2 198 820 | 704 | **415** | 2 829 | 1 409 | 17 460 | 4 363 | 1 779 | 679 | 130 |
| *Nodes expanded* | 86 871 | 1 301 341 | 30 | 1 390 965 | 266 | **158** | 1 057 | 882 | 6 452 | 1 601 | 666 | 256 | 48 |
| *Max nodes stored* | 110 729 | 76 | 54 | 43 | 429 | 251 | 35 | 10 068 | 2 603 | 1 060 | 414 | 82 |
| *Solution cost* | 22 | 38 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 |
| *Search depth* | 23 | 40 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 | 22 |
| *Running time (s)* | 0,6187 | 3,4636 | *0,0005* | 3,7012 | **0,0038** | 0,0096 | 0,0262 | 0,0048 | 0,0808 | 0,0309 | 0,0469 | 0,0204 | 0,0007 |

Nombres abreviados: `DFS(Back)` = `DFS-B`, `Manh` = `A* (Manhattan)`, `MD+LC` = `A (MD + LC)`,
`Euclídea` = `A (Euclídea)`, `IDA*Manh` = `IDA* (Manhattan)`,
`Desc` = `A (Piezas descolocadas)`, `FilCol` = `A (Filas-Columnas)`,
`Euclídea+LC` = `A (Euclídea + LC)`, `Propuesta` = `A (Propuesta)`,
`Nueva` = `Nueva Heurística`.

Todas las heurísticas **admisibles y consistentes** obtienen el **coste óptimo 22**. Entre las
búsquedas A\*, `A (MD + LC)` es la que **menos expande (158)** y **menos memoria usa (251)**,
mientras que `A* (Manhattan)` es la **más rápida (0,0038 s)**. El motivo por el que se descarta cada
alternativa está en §5.3.

### 5.2. Actividad 7 — 1 000 puzzles aleatorios 3×3 (`alg-compare-p3.ipynb`)

El notebook `alg-compare-p3.ipynb` ejecuta en su Actividad 7 **solo las dos heurísticas elegidas**
sobre 1 000 puzzles aleatorios 3×3, midiendo la **calidad de la solución (coste)**, los **nodos
expandidos**, la **memoria** (`max_nodes`) y el **tiempo de ejecución**.

| Algoritmo | Calidad: coste medio (mín–máx) | Nodos expandidos (media) | Memoria: `max_nodes` (media) | Tiempo medio (ms) |
|---|---|---|---|---|
| **A\* (Manhattan)** | 21,54 (6–29) | 588,77 | 942,60 | **9,0** |
| **A (MD + LC)** | 21,54 (6–29) | **307,86** | **491,52** | 19,9 |

Ambas obtienen el **mismo coste** en los 1 000 puzzles (diferencia mínima, máxima y media = 0; el
**óptimo**, por ser admisibles y consistentes, §4): `A (MD + LC)` expande **≈47,7 % menos nodos** y
usa **≈47,9 % menos memoria**, mientras que `A* (Manhattan)` es **≈2,2× más rápida**. Las
diferencias de tiempo (MD + LC − Manhattan) van de −0,763 a +83,827 ms, con una media de
+10,846 ms. Los valores corresponden a la ejecución guardada en el notebook; al ser puzzles
aleatorios y no fijar semillas, pueden variar ligeramente.

### 5.3. Las dos mejores: `A (MD + LC)` y `A* (Manhattan)`

**Calidad de la solución (coste): empate.** En la Actividad 6 ambas resuelven el estado de
referencia con el **coste óptimo 22**, y en la Actividad 7 obtienen también el **mismo coste medio**
(21,54) sobre los 1 000 puzzles. Es consecuencia de que las dos son **admisibles y consistentes**
(§4), por lo que garantizan la solución óptima.

**Memoria y esfuerzo de búsqueda: gana `A (MD + LC)`.** Ya en la Actividad 6 es la que **menos nodos
expande** (158 frente a 266) y la que **menos memoria ocupa** (251 frente a 429 nodos como máximo)
entre las admisibles. Sobre los 1 000 puzzles expande 307,86 nodos frente a 588,77 (≈47,7 % menos) y
necesita 491,52 `max_nodes` frente a 942,60 (≈47,9 % menos). Es la mejor opción cuando el cuello de
botella es la memoria (tableros grandes).

**Tiempo: gana `A* (Manhattan)`.** Es la **más rápida** en la Actividad 6 (0,0038 s frente a
0,0096 s) y también en la Actividad 7 (9,0 ms frente a 19,9 ms, ≈2,2× más rápida; la diferencia
media es +10,846 ms a favor de Manhattan): calcular los conflictos lineales es más caro por nodo y
ese sobrecoste supera el ahorro en expansiones de `A (MD + LC)`.

**Por qué no las demás.**

- `Voraz (Manhattan)` es el más rápido (0,0005 s) y solo expande 30, pero es **voraz** (`f = h`,
  sin `g`): **no garantiza el coste óptimo**, aquí acierta el 22 por casualidad.
- `IDA* (Manhattan)` tiene el menor `Max nodes` (35), pero usa la **misma heurística** que
  `A* (Manhattan)` y su `max_nodes` no es comparable (guarda solo la rama actual, no la lista
  abierta ni los explorados); además expande 882 nodos y tarda 0,0048 s.
- `Nueva Heurística` expande 48 nodos, pero es el ejemplo 2 · Manhattan (no una de las cinco) y
  **no es admisible ni consistente** (32 > 22).
- `BFS`, `DFS-B` e `ID` no son informados; `DFS-B` ni siquiera es óptimo (coste 38) y los tres
  tardan entre 0,6187 s y 3,7012 s.
- El resto de heurísticas A\* (`A (Propuesta)` 256 expansiones / 0,0204 s, `Euclídea + LC` 666,
  `Euclídea` 1 057, `Filas-Columnas` 1 601 y `Piezas descolocadas` 6 452) expande y tarda más que
  las dos elegidas.

Por todo ello elegimos **`A (MD + LC)`** (mejor en memoria/expansiones) y **`A* (Manhattan)`**
(mejor en tiempo), ambas con la solución óptima.

---

## 6. Conclusión

- Se han implementado y registrado las **cinco heurísticas** de las Actividades 1-5 **sin modificar
  `search.py`**.
- Son **admisibles y consistentes** (y por tanto garantizan el óptimo): *Piezas descolocadas*,
  *Euclídea (truncada)*, *Filas-Columnas* y la heurística inventada
  *`max(D_Manhattan, FilCol + LC)`*. **No** lo es `Euclídea + LC`: es inconsistente y su
  admisibilidad general no se ha demostrado.
- La comprobación de **los 181 440 estados alcanzables** aporta evidencia experimental muy fuerte
  sobre la consistencia (aunque no es una demostración formal).
- En los 1 000 puzzles de la Actividad 7, las dos heurísticas elegidas obtienen el **mismo coste
  óptimo**; las diferencias están en los **nodos expandidos**, la **memoria** y el **tiempo**.
- `Nueva Heurística` (2 · Manhattan) es la heurística de ejemplo del boletín, no una de las cinco
  nuevas: **no es admisible ni consistente** y por eso no se elige entre las dos mejores, aunque
  expanda pocos nodos.
- Las **"dos mejores"** (*¡no se puede decir que una solución sea más óptima que otra!*) son
  **`A (MD + LC)`** (mejor en memoria y expansiones) y **`A* (Manhattan)`** (mejor en tiempo), con
  empate en la calidad de la solución.
