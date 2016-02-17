#include "common.h"

/* Convenience function for checking CUDA runtime API results can be
 * wrapped around any runtime API call. No-op in release builds. */
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

double calculate_elapsed_time(struct timespec start, struct timespec finish)
{
  double elapsed;
  elapsed = (finish.tv_sec - start.tv_sec);
  elapsed += (finish.tv_nsec - start.tv_nsec) / 1000000000.0;
  return elapsed;
}

bool compare_doubles(double n1, double n2, double epsilon)
{
  return fabs(n1 - n2) < epsilon;
}
