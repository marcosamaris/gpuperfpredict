/*
 * Copyright 1993-2010 NVIDIA Corporation.  All rights reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and 
 * proprietary rights in and to this software and related documentation. 
 * Any use, reproduction, disclosure, or distribution of this software 
 * and related documentation without an express license agreement from
 * NVIDIA Corporation is strictly prohibited.
 *
 * Please refer to the applicable NVIDIA end user license agreement (EULA) 
 * associated with this source code for terms and conditions that govern 
 * your use of this NVIDIA software.
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

// Convenience function for checking CUDA runtime API results
// can be wrapped around any runtime API call. No-op in release builds.
inline
cudaError_t checkCuda(cudaError_t result)
{
#if defined(DEBUG) || defined(_DEBUG)
  if (result != cudaSuccess) {
    fprintf(stderr, "CUDA Runtime Error: %s\n", cudaGetErrorString(result));
    assert(result == cudaSuccess);
  }
#endif
  return result;
}


#define imin(a,b) (a<b?a:b)

const int BlockSize = 256;

__global__ void dot( float *a, float *b, float *c, int N ) {
    __shared__ float cache[BlockSize];
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int cacheIndex = threadIdx.x;

    float  temp = 0; 
    while (tid < N) {
        temp += a[tid] * b[tid];
        tid += blockDim.x * gridDim.x;
    }
    
    // set the cache values
    cache[cacheIndex] = temp;
    
    // synchronize threads in this block
    __syncthreads();

    // for reductions, BlockSize must be a power of 2
    // because of the following code
    int i = blockDim.x/2;
    while (i != 0) {
        if (cacheIndex < i)
            cache[cacheIndex] += cache[cacheIndex + i];
        __syncthreads();
        i /= 2;
    }

    if (cacheIndex == 0)
        c[blockIdx.x] = cache[0];
}


int main(int argc, char* argv[])
{

    //printf("Argumentos: %d \n",argc);

    if (argc != 3) {
      fprintf(stderr, "Syntax: %s <vector size N> <device id>\n", argv[0]);
      return EXIT_FAILURE;
    }

    int N = atoi(argv[1]);
    int GridSize = imin( 32, (N+BlockSize-1) / BlockSize );
    int devId = atoi(argv[2]);

    checkCuda( cudaSetDevice(devId) );

    float   *a, *b, c, *partial_c;
    float   *dev_a, *dev_b, *dev_partial_c;

    // allocate memory on the cpu side
    a = (float*)malloc( N*sizeof(float) );
    b = (float*)malloc( N*sizeof(float) );
    partial_c = (float*)malloc( GridSize*sizeof(float) );

    // allocate the memory on the GPU
    checkCuda( cudaMalloc( (void**)&dev_a, N*sizeof(float) ) );
    checkCuda( cudaMalloc( (void**)&dev_b, N*sizeof(float) ) );
    checkCuda( cudaMalloc( (void**)&dev_partial_c, GridSize*sizeof(float) ) );

    // fill in the host memory with data
    for (int i=0; i<N; i++) {
        a[i] = i;
        b[i] = i*2;
    }

    // copy the arrays 'a' and 'b' to the GPU
    checkCuda( cudaMemcpy( dev_a, a, N*sizeof(float), cudaMemcpyHostToDevice ) );
    checkCuda( cudaMemcpy( dev_b, b, N*sizeof(float), cudaMemcpyHostToDevice ) ); 

    dot<<<GridSize,BlockSize>>>( dev_a, dev_b, dev_partial_c, N );

    // copy the array 'c' back from the GPU to the CPU
    checkCuda( cudaMemcpy( partial_c, dev_partial_c, GridSize*sizeof(float), cudaMemcpyDeviceToHost ) );

    // finish up on the CPU side
    c = 0;
    for (int i=0; i<GridSize; i++) {
        c += partial_c[i];
    }

    #define sum_squares(x)  (x*(x+1)*(2*x+1)/6)
    printf( "Does GPU value %.6g = %.6g?\n", c, 2 * sum_squares( (float)(N - 1) ) );

    // free memory on the gpu side
    checkCuda( cudaFree( dev_a ) );
    checkCuda( cudaFree( dev_b ) );
    checkCuda( cudaFree( dev_partial_c ) );

    // free memory on the cpu side
    free( a );
    free( b );
    free( partial_c );
}
