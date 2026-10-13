#include <stdio.h>
#include <math.h>
#include <omp.h>
typedef unsigned long long Entero_grande;
#define N 100000000ULL

int hilos;

int primo(Entero_grande n)
{
  int p;
  Entero_grande i, s;

  p = (n % 2 != 0 || n == 2);

  if (p) {
    s = sqrt(n);

    for (i = 3; p && i <= s; i += 2)
      if (n % i == 0) p = 0;
  }

  return p;
}

int main()
{
  Entero_grande i, n;

  n = 2; /* Por el 1 y el 2 */
  double t = omp_get_wtime();
  #pragma omp parallel for schedule(runtime) reduction(+:n)
  for (i = 3; i <= N; i += 2) {
    if (primo(i)) n++;
    hilos =  omp_get_thread_num();
  }
  t = omp_get_wtime() - t;
  #pragma omp parallel
    #pragma omp single
      printf("Tiempo para %d hilos: %f\n",omp_get_num_threads(),t);
  printf("Entre el 1 y el %llu hay %llu numeros primos.\n",
         N, n);

  return 0;
}
