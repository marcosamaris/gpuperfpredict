#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "common.h"

// See more at: http://docs.nvidia.com/cuda/cuda-c-programming-guide/#sthash.7QeV8b7J.dpuf

// Forward declaration of the matrix sum kernel
__global__ void MatSumKernel(const Matrix, const Matrix, Matrix);

// Matrix sum - Host code
// Matrix dimensions are assumed to be multiples of BLOCK_SIZE
void MatSum(const Matrix A, const Matrix B, Matrix C)
{
  Matrix d_A, d_B, d_C;

  // Load A and B to device memory
  d_A.width = A.width; d_A.height = A.height;
  size_t size = A.width * A.height * sizeof(double);
  checkCuda(cudaMalloc(&d_A.elements, size));
  checkCuda(cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice));

  d_B.width = B.width; d_B.height = B.height;
  size = B.width * B.height * sizeof(double);
  checkCuda(cudaMalloc(&d_B.elements, size));
  checkCuda(cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice));

  // Allocate C in device memory
  d_C.width = C.width; d_C.height = C.height;
  size = C.width * C.height * sizeof(double);
  cudaMalloc(&d_C.elements, size);

  // Invoke kernel
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid(B.width / dimBlock.x, A.height / dimBlock.y);
  MatSumKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);

  // Read C from device memory
  cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost);

  // Free device memory
  cudaFree(d_A.elements);
  cudaFree(d_B.elements);
  cudaFree(d_C.elements);
}

// Matrix sum kernel called by MatSum()
__global__ void MatSumKernel(Matrix A, Matrix B, Matrix C)
{
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;

  C.elements[row * C.width + col] =
    A.elements[row * A.width + col] + B.elements[row * B.width + col];
}

int main(int argc, char* argv[])
{
  if (argc != 3) {
    fprintf(stderr, "Syntax: %s <vector size N> <device id>\n", argv[0]);
    return EXIT_FAILURE;
  }

  const int N = atoi(argv[1]);
  const int devId = atoi(argv[2]);
  size_t size = N * N * sizeof(double);
  struct timespec start, finish;
  double elapsed;
  double mul = 5.0;

  checkCuda(cudaSetDevice(devId));

  Matrix a, b, c;

  // allocate matrices on the CPU side
  a.width = N;
  a.height = N;
  a.elements = (double *) malloc(size);

  b.width = N;
  b.height = N;
  b.elements = (double *) malloc(size);

  c.width = N;
  c.height = N;
  c.elements = (double *) malloc(size);

  // fill in the host memory with data
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      a.elements[i * N + j] = i * mul;
      b.elements[i * N + j] = i;
    }
  }

  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  MatSum(a, b, c);

  clock_gettime(CLOCK_MONOTONIC_RAW, &finish);
  elapsed = calculate_elapsed_time(start, finish);

  printf("Total elapsed time: %lf\n", elapsed);

  // finish up on the CPU side
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      assert(compare_doubles(
             c.elements[i * N + j],
             a.elements[i * N + j] + b.elements[i * N + j],
             0.1));
    }
  }
  printf("Matrix check successful!\n");

  // free memory on the cpu side
  free(a.elements);
  free(b.elements);
  free(c.elements);
}
