#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <cuda_profiler_api.h>



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


__global__ void matMul(float* Pd, float* Md, float* Nd, int Width) {
  float Pvalue = 0.0;

  int j = blockIdx.x * Tile_Width + threadIdx.x;
  int i = blockIdx.y * Tile_Width + threadIdx.y;

  for (int k = 0; k < Width; ++k) {
    Pvalue += Md[i * Width + k] * Nd[k * Width + j];
  }

  Pd[i * Width + j] = Pvalue;
}


// Allocates a matrix with random float entries.
void randomInit(float* data, int size) {
  for (int k = 0; k < size; ++k) {
     data[k] = (float)drand48();
  }
}

int main(int argc, char* argv[])
{

  if (argc != 3) {
    fprintf(stderr, "Syntax: %s <matrix size Width> <device id>\n", argv[0]);
    return EXIT_FAILURE;
  }

  int Width = atoi(argv[1]);
  int devId = atoi(argv[2]);

  checkCuda( cudaSetDevice(devId) );
  cudaDeviceReset();

  // allocate host memory for matrices M and N
  printf("Allocate host memory for matrices M and N...\n");
  float* M = (float*) malloc(Width * Width * sizeof(float));
  float* N = (float*) malloc(Width * Width * sizeof(float));
  float* P = (float*) malloc(Width * Width * sizeof(float));

  // set seed for drand48()
  srand48(42);

  // initialize host matrices
  printf("Initialize host matrices...\n");
  randomInit(M, Width*Width);
  randomInit(N, Width*Width);

  // allocate device matrices (linearized)
  printf("Allocate device matrices (linearized)...\n");
  float* Md = NULL; 
  float* Nd = NULL;
  float* Pd = NULL;
  checkCuda( cudaMalloc((void**) &Md, Width * Width * sizeof(float)) );
  checkCuda( cudaMalloc((void**) &Nd, Width * Width * sizeof(float)) );
  checkCuda( cudaMalloc((void**) &Pd, Width * Width * sizeof(float)) );

  // copy host memory to device
  checkCuda( cudaMemcpy(Md, M, Width*Width*sizeof(float), cudaMemcpyHostToDevice) );
  checkCuda( cudaMemcpy(Nd, N, Width*Width*sizeof(float), cudaMemcpyHostToDevice) );

  // execute the kernel
  printf("Execute the kernel...\n");

  int GridSize = (Width + Tile_Width-1) / Tile_Width;
  dim3 gridDim(GridSize, GridSize);
  dim3 blockDim(Tile_Width, Tile_Width);
  

  cudaProfilerStart(); 
  matMul<<< gridDim, blockDim >>>(Pd, Md, Nd, Width);
  cudaProfilerStop();

  // copy result from device to host
  checkCuda( cudaMemcpy( P, Pd, Width * Width * sizeof(float),cudaMemcpyDeviceToHost) );

  cudaDeviceProp prop;
  checkCuda( cudaGetDeviceProperties(&prop, devId) );
  printf("Device: %s\n", prop.name);

  /* print result
  FILE *ptr_file;
  ptr_file =fopen("matMul_gpu_globalmem.out", "w");
  if (!ptr_file) return 1;

  for (int i=0; i < Width; i++){
      for (int j=0; j < Width; j++) fprintf(ptr_file,"%6.2f ", P[i * Width + j]);
      fprintf(ptr_file,"\n");
  }
  fclose(ptr_file); */


  // clean up memory
  free(M);
  free(N);
  free(P);
  checkCuda( cudaFree(Md) );
  checkCuda( cudaFree(Nd) );
  checkCuda( cudaFree(Pd) );

  return 0;
}

