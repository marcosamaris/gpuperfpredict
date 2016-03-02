#ifndef _COMMON_H_
#define _COMMON_H_

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <time.h>

// Thread block size
#define BLOCK_SIZE 16
#define imin(a,b) (a < b ? a : b)
#define sum_squares(x) (x * (x + 1) * (2 * x + 1) / 6)
/* Need to do this instead of defining a function, since
 * CUDA does not support function definition with generic
 * types inside kernels. */
#define print_2d_array(array, N) \
do { \
    for (int i = 0; i < N; ++i) { \
        for (int j = 0; j < N; ++j) { \
	    printf("%4f ", array[i * N + j]); \
        } \
	printf("\n"); \
    } \
   } while(0);
#define DEBUG

// Matrices are stored in row-major order:
// M(row, col) = *(M.elements + row * M.width + col)
typedef struct {
  int width;
  int height;
  int stride;
  double* elements;
} Matrix;

cudaError_t checkCuda(cudaError_t result);
double calculate_elapsed_time(struct timespec start, struct timespec finish);
bool compare_doubles(double n1, double n2, double epsilon);

#endif
