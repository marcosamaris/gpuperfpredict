//#include <prof.cu>
// Includes
#include <stdio.h>
#include <float.h>
#include <assert.h>     
#include <cuda_profiler_api.h>
//#include <cutil_inline.h>

#define DECIMAL_DIG 12

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
float* d_A;

// Functions
void RandomInit(float*, int);

// Device code
__global__ void transFloat(float* A, int N)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N)
        i++;
}

// Host code
int main(int argc, char** argv)
{

    if (argc != 3 ) {
		fprintf(stderr, "Syntax: %s <Vector size>  <device>\n", argv[0]);
    		return EXIT_FAILURE;
	}
    cudaProfilerStart();
    
    int N = atoi(argv[1]);    
    size_t size = N * sizeof(float);
    
    int devId = atoi(argv[2]);
    checkCuda( cudaSetDevice(devId) );
    cudaDeviceReset();

    cudaDeviceProp prop;
    checkCuda( cudaGetDeviceProperties(&prop, devId) );
    printf("Device: %s\n", prop.name);

    // Allocate input vectors h_A and h_B in host memory
    h_A = (float*)malloc(size);
    h_B = (float*)malloc(size);

    // Initialize input vectors
    RandomInit(h_A, N);

    // Allocate vectors in device memory
    checkCuda(cudaMalloc((void**)&d_A, size * sizeof(float))) ;

    // Copy vectors from host memory to device memory
    checkCuda(cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice)) ;

    for(int i; i<10; i++) printf("%f, ", h_A[i]);
    printf("\n");

    // Invoke kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
//	GpuProfiling::prepareProfiling( blocksPerGrid, threadsPerBlock );
    transFloat<<<blocksPerGrid, threadsPerBlock>>>(d_A, N);
//	GpuProfiling::addResults("VecAdd");
//    cutilCheckMsg("kernel launch failure");
#ifdef _DEBUG
    checkCuda( cudaThreadSynchronize() );
#endif

    // Copy result from device memory to host memory
    // h_C contains the result in host memory
    checkCuda(cudaMemcpy(h_B, d_A, size, cudaMemcpyDeviceToHost)) ;

    for(int i; i<10; i++) printf("%f, ", h_B[i]);
    printf("\n");

    free(h_A);
    free(h_B);
    cudaFree(d_A);
    cudaThreadExit() ;

    return 0;
    cudaProfilerStop();

}



// Allocates an array with random float entries.
void RandomInit(float* data, int n)
{
    for (int i = 0; i < n; ++i)
        data[i] = ((rand() / (float)RAND_MAX)*FLT_MAX) + (rand() / (float)RAND_MAX);
}

