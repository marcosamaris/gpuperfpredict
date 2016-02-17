#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "common.h"

const int BlockSize = 256;

__global__ void dot(float *a, float *b, float *c, int N) {
   /* Use cache to store the products of each index of the arrays in a locally shared array for each block */
   __shared__ float cache[BlockSize];
   /* Calculate thread id (according to slide 24) */
   int id = blockDim.x * blockIdx.x + threadIdx.x;

   cache[threadIdx.x] = a[id] * b[id];
   __syncthreads();

   /* A recursive approach to do the additions in parallel */
   for (int i = blockDim.x/2; i >  0; i /= 2) {
      if (threadIdx.x < i) {
         cache[threadIdx.x] += cache[threadIdx.x + i];
      }
      __syncthreads();
   }

   /* Store the result from this block in global memory */
   if (threadIdx.x == 0) {
      c[blockIdx.x] = cache[0];
   }

}

int main(int argc, char* argv[])
{
  if (argc != 3) {
    fprintf(stderr, "Syntax: %s <vector size N> <device id>\n", argv[0]);
    return EXIT_FAILURE;
  }

  int N = atoi(argv[1]);
  int GridSize = imin(pow(2, 31), (N + BlockSize - 1) / BlockSize);
  int devId = atoi(argv[2]);
  struct timespec start, finish, partial_start, partial_finish;
  double elapsed;

#if defined(DEBUG) || defined(_DEBUG)
  printf("DeviceId=%d, N=%d, BlockSize=%d, GridSize=%d\n", devId, N, BlockSize, GridSize);
#endif

  checkCuda(cudaSetDevice(devId));

  float *a, *b, c, *partial_c;
  float *dev_a, *dev_b, *dev_partial_c;

  // allocate memory on the cpu side
  a = (float*) malloc(N * sizeof(float));
  b = (float*) malloc(N * sizeof(float));
  partial_c = (float*) malloc(GridSize * sizeof(float));

  assert(a != NULL);
  assert(b != NULL);
  assert(partial_c != NULL);

  // allocate the memory on the GPU
  checkCuda(cudaMalloc((void**) &dev_a, N * sizeof(float)));
  checkCuda(cudaMalloc((void**) &dev_b, N * sizeof(float)));
  checkCuda(cudaMalloc((void**) &dev_partial_c, GridSize * sizeof(float)));

  // fill in the host memory with data
  for (int i = 0; i < N; ++i) {
    a[i] = i;
    b[i] = i * 2;
  }

  clock_gettime(CLOCK_MONOTONIC_RAW, &start);
  partial_start = start;
  // copy the arrays 'a' and 'b' to the GPU
  checkCuda(cudaMemcpy(dev_a, a, N * sizeof(float), cudaMemcpyHostToDevice));
  checkCuda(cudaMemcpy(dev_b, b, N * sizeof(float), cudaMemcpyHostToDevice));

  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_finish);
  elapsed = calculate_elapsed_time(partial_start, partial_finish);
  printf("Memcpy 1 elapsed time: %lf\n", elapsed);

  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_start);
  dot<<<GridSize,BlockSize>>>(dev_a, dev_b, dev_partial_c, N);
  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_finish);
  elapsed = calculate_elapsed_time(partial_start, partial_finish);
  printf("Kernel elapsed time: %lf\n", elapsed);

  // copy the array 'c' back from the GPU to the CPU
  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_start);
  checkCuda(cudaMemcpy(partial_c, dev_partial_c, GridSize * sizeof(float), cudaMemcpyDeviceToHost));
  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_finish);
  elapsed = calculate_elapsed_time(partial_start, partial_finish);
  printf("Memcpy 2 elapsed time: %lf\n", elapsed);

  // finish up on the CPU side
  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_start);
  c = 0;
  for (int i = 0; i < GridSize; ++i) {
    c += partial_c[i];
  }
  clock_gettime(CLOCK_MONOTONIC_RAW, &partial_finish);
  elapsed = calculate_elapsed_time(partial_start, partial_finish);
  printf("CPU-side loop elapsed time: %lf\n", elapsed);

  clock_gettime(CLOCK_MONOTONIC_RAW, &finish);
  elapsed = calculate_elapsed_time(start, finish);

  printf("Does GPU value %.6g = %.6g?\n", c, 2 * sum_squares((float)(N - 1)));
  printf("Total elapsed time: %lf\n", elapsed);

  // free memory on the gpu side
  checkCuda(cudaFree(dev_a));
  checkCuda(cudaFree(dev_b));
  checkCuda(cudaFree(dev_partial_c));

  // free memory on the cpu side
  free(a);
  free(b);
  free(partial_c);
}
