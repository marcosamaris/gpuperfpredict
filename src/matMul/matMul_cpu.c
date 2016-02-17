#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

int i,j,k;
// Computes the matrix product using line matrices:
void matMul(float* P, float* M, float* N, int Width) {
  for ( i = 0; i < Width; ++i) {
    for ( j = 0; j < Width; ++j) {
      P[i * Width + j] = 0.0;
      for ( k = 0; k < Width; ++k) {
        P[i * Width + j] += M[i * Width + k] * N[k * Width + j];
      }
    }
  }
}


// Allocates a matrix with random float entries.
void randomInit(float* data, int size) {
  for (i = 0; i < size; ++i) {
     data[i] = (float)drand48();
  }
}


int main(int argc, char* argv[])
{
  if (argc != 2) {
    fprintf(stderr, "Syntax: %s <matrix Width>\n", argv[0]);
    return EXIT_FAILURE;
  }
  int Width = atoi(argv[1]);

  // allocate host memory for matrices M and N
  printf("Allocate memory for matrices M and N...\n");
  float* M = (float*) malloc(Width * Width * sizeof(float));
  float* N = (float*) malloc(Width * Width * sizeof(float));
  float* P = (float*) malloc(Width * Width * sizeof(float));

  // set seed for drand48()
  srand48(42);

  // initialize matrices
  printf("Initialize matrices...\n");
  randomInit(M, Width*Width);
  randomInit(N, Width*Width);

  printf("Multiply matrices...\n");
  struct timeval begin, end;
  gettimeofday(&begin, NULL);
  matMul( P, M, N, Width );
  gettimeofday(&end, NULL);

  double cpuTime = 1000000*(double)(end.tv_sec - begin.tv_sec);
  cpuTime +=  (double)(end.tv_usec - begin.tv_usec);

  // print times
  printf("\nExecution Time (microseconds): %9.2f\n", cpuTime);



  // print result
  FILE *ptr_file;
  ptr_file =fopen("matMul_cpu.out", "w");
  if (!ptr_file) return 1;

  for (i=0; i < Width; i++){
      for (j=0; j < Width; j++) fprintf(ptr_file,"%6.2f ", P[i * Width + j]);
      fprintf(ptr_file,"\n");
  }
  fclose(ptr_file);

  // clean up memory
  free(M);
  free(N);
  free(P);

  return 0;
}

