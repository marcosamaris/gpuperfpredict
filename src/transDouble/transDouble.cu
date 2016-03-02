//#include <prof.cu>
// Includes
#include <stdio.h>
#include <float.h>
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
double* h_A;
double* h_B;
double* d_A;

// Functions
void RandomInit(double*, int);

// Device code
__global__ void transDouble(double* A, int N)
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
    size_t size = N * sizeof(double);
    
    int devId = atoi(argv[2]);
    checkCuda( cudaSetDevice(devId) );
    cudaDeviceReset();

    cudaDeviceProp prop;
    checkCuda( cudaGetDeviceProperties(&prop, devId) );
    printf("Device: %s\n", prop.name);

    // Allocate input vectors h_A and h_B in host memory
    h_A = (double*)malloc(size);
    h_B = (double*)malloc(size);

    // Initialize input vectors
    RandomInit(h_A, N);

    // Allocate vectors in device memory
    checkCuda(cudaMalloc((void**)&d_A, size * sizeof(double))) ;

    // Copy vectors from host memory to device memory
    checkCuda(cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice)) ;

    for(int i; i<10; i++) printf("%lf, ", h_A[i]);
    printf("\n");

    // Invoke kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
//  GpuProfiling::prepareProfiling( blocksPerGrid, threadsPerBlock );
    transDouble<<<blocksPerGrid, threadsPerBlock>>>(d_A, N);
//  GpuProfiling::addResults("VecAdd");
//    cutilCheckMsg("kernel launch failure");
#ifdef _DEBUG
    checkCuda( cudaThreadSynchronize() );
#endif

    // Copy result from device memory to host memory
    // h_C contains the result in host memory
    checkCuda(cudaMemcpy(h_B, d_A, size, cudaMemcpyDeviceToHost)) ;

    for(int i; i<10; i++) printf("%lf, ", h_B[i]);
    printf("\n");

    free(h_A);
    free(h_B);
    cudaFree(d_A);
    cudaThreadExit() ;

    return 0;
    cudaProfilerStop();

}



// Allocates an array with random double entries.
void RandomInit(double* data, int n)
{
    for (int i = 0; i < n; ++i)
        data[i] = ((rand() / (float)RAND_MAX)*DBL_MAX) + (rand() / (float)RAND_MAX);
}

