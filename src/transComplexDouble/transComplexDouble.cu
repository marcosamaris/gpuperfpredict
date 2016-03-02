#include <complex>
#include <stdio.h>
#include <cmath>
#include <float.h>
#include <cuda.h>
#include <math.h>
#include <cuComplex.h>
#include <cuda_profiler_api.h>


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

cuDoubleComplex *h_A;
cuDoubleComplex *h_B;
cuDoubleComplex z;

__global__ void transComplexDouble(cuDoubleComplex *array, int N){
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N)
        i++;
}

int main(int argc, char** argv ) {
    
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

    h_A = new cuDoubleComplex[N];
    h_B = new cuDoubleComplex[N];

    for(int i = 0; i < N; ++i){
        double Ti = ((rand() / (float)RAND_MAX)*DBL_MAX) + (rand() / (float)RAND_MAX);
        double Tj = ((rand() / (float)RAND_MAX)*DBL_MAX) + (rand() / (float)RAND_MAX);
        z = make_cuDoubleComplex(Ti, Tj);
        h_A[i] = make_cuDoubleComplex(cuCreal(z), cuCimag(z));
        h_B[i] = make_cuDoubleComplex(0., 0.);      
    }

  
  //Allocate and copy memory to device
  cuDoubleComplex *d_A;
  checkCuda(cudaMalloc((void**)&d_A, sizeof(cuDoubleComplex)*N));
  checkCuda(cudaMemcpy(d_A, h_A, sizeof(cuDoubleComplex)*N, cudaMemcpyHostToDevice));

    for(int i = 0; i < 10; ++i) printf("%lf + i%lf ", cuCreal(h_A[i]), cuCimag(h_A[i]));
    printf("\n");

    // Invoke kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;    
    transComplexDouble<<<blocksPerGrid, threadsPerBlock>>>(d_A, N);

    checkCuda(cudaMemcpy(h_B, d_A, sizeof(cuDoubleComplex)*(N), cudaMemcpyDeviceToHost));  

    for(int i = 0; i < 10; ++i) printf("%lf + i%lf ", cuCreal(h_B[i]), cuCimag(h_B[i]));
    printf("\n");


  //free memmory
  cudaFree(d_A);

  free(h_A);
  free(h_B);

  
  return 0;

}
