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

/* Vector addition: C = A + B.
 *
 * This sample is a very basic sample that implements element by element
 * vector addition. It is the same as the sample illustrating Chapter 3
 * of the programming guide with some additions like error checking.
 *
 */
//#include <prof.cu>
// Includes
#include <stdio.h>
#include <assert.h>    
#include <cuda_profiler_api.h> 
//#include <cutil_inline.h>

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

// Variables
float* h_A;
float* h_B;
float* h_C;
float* d_A;
float* d_B;
float* d_C;
bool noprompt = false;

// Functions
void Cleanup(void);
void RandomInit(float*, int);
void ParseArguments(int, char**);

// Device code
__global__ void vectorAdd(const float* A, const float* B, float* C, int N)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N)
        C[i] = A[i] + B[i];
}

// Host code
int main(int argc, char** argv)
{

    if (argc != 3 ) {
		fprintf(stderr, "Syntax: %s <Vector size>  <device>\n", argv[0]);
    		return EXIT_FAILURE;
	}
    
    int N = atoi(argv[1]);
    int devId = atoi(argv[2]);

    size_t size = N * sizeof(float);
    
    checkCuda( cudaSetDevice(devId) );
    cudaDeviceReset();
    
    ParseArguments(argc, argv);

    printf("Vector addition\n");
    

    // Allocate input vectors h_A and h_B in host memory
    h_A = (float*)malloc(size);
    if (h_A == 0) Cleanup();
    h_B = (float*)malloc(size);
    if (h_B == 0) Cleanup();
    h_C = (float*)malloc(size);
    if (h_C == 0) Cleanup();

    // Initialize input vectors
    RandomInit(h_A, N);
    RandomInit(h_B, N);

    // Allocate vectors in device memory
    checkCuda(cudaMalloc((void**)&d_A, size)) ;
    checkCuda(cudaMalloc((void**)&d_B, size)) ;
    checkCuda(cudaMalloc((void**)&d_C, size)) ;

    // Copy vectors from host memory to device memory
    checkCuda(cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice)) ;
    checkCuda(cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice)) ;



    // Invoke kernel
    int threadsPerBlock = Tile_Width*Tile_Width;
    int GridSize = (N + threadsPerBlock - 1) / threadsPerBlock;
//  GpuProfiling::prepareProfiling( blocksPerGrid, threadsPerBlock );
    vectorAdd<<<GridSize, threadsPerBlock>>>(d_A, d_B, d_C, N);
//  GpuProfiling::addResults("VecAdd");
//    cutilCheckMsg("kernel launch failure");
#ifdef _DEBUG
    cutilSafeCall( cudaThreadSynchronize() );
#endif

    // Copy result from device memory to host memory
    // h_C contains the result in host memory
    checkCuda(cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost)) ;

    // Verify result
    int i;
    for (i = 0; i < N; ++i) {
        float sum = h_A[i] + h_B[i];
        if (fabs(h_C[i] - sum) > 1e-5)
            break;
    }
    printf("Assertion started\n");
    printf("%s \n", (i == N) ? "PASSED" : "FAILED");    
    assert(i == N);
    printf("Assertion Finished");

    Cleanup();
    return 0;
}

void Cleanup(void)
{
    // Free device memory
    if (d_A)
        cudaFree(d_A);
    if (d_B)
        cudaFree(d_B);
    if (d_C)
        cudaFree(d_C);

    // Free host memory
    if (h_A)
        free(h_A);
    if (h_B)
        free(h_B);
    if (h_C)
        free(h_C);

    cudaThreadExit() ;
exit(0);
    if (!noprompt) {
        printf("\nPress ENTER to exit...\n");
        fflush( stdout);
        fflush( stderr);
        getchar();
    }

    exit(0);
}

// Allocates an array with random float entries.
void RandomInit(float* data, int n)
{
    for (int i = 0; i < n; ++i)
        data[i] = rand() / (float)RAND_MAX;
}

// Parse program arguments
void ParseArguments(int argc, char** argv)
{
    for (int i = 0; i < argc; ++i)
        if (strcmp(argv[i], "--noprompt") == 0 ||
            strcmp(argv[i], "-noprompt") == 0)
        {
            noprompt = true;
            break;
        }
}
