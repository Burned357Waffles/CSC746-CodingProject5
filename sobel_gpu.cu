//
// (C) 2021, E. Wes Bethel
// sobel_gpu.cpp
// usage:
//      sobel_gpu [no args, all is hard coded]
//

#include <iostream>
#include <vector>
#include <chrono>
#include <unistd.h>
#include <string.h>
#include <math.h>

// see https://en.wikipedia.org/wiki/Sobel_operator


// easy-to-find and change variables for the input.
// specify the name of a file containing data to be read in as bytes, along with 
// dimensions [columns, rows]

// this is the original laughing zebra image
//static char input_fname[] = "../data/zebra-gray-int8";
//static int data_dims[2] = {3556, 2573}; // width=ncols, height=nrows
//char output_fname[] = "../data/processed-raw-int8-cpu.dat";

// this one is a 4x augmentation of the laughing zebra
static char input_fname[] = "../data/zebra-gray-int8-4x";
static int data_dims[2] = {7112, 5146}; // width=ncols, height=nrows
char output_fname[] = "../data/processed-raw-int8-4x-cpu.dat";

// see https://stackoverflow.com/questions/14038589/what-is-the-canonical-way-to-check-for-errors-using-the-cuda-runtime-api
// macro to check for cuda errors. basic idea: wrap this macro around every cuda call
#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

//
// this function is callable only from device code
//
// perform the sobel filtering at a given i,j location
// input: float *s - the source data
// input: int i,j - the location of the pixel in the source data where we want to center our sobel convolution
// input: int nrows, ncols: the dimensions of the input and output image buffers
// input: float *gx, gy:  arrays of length 9 each, these are logically 3x3 arrays of sobel filter weights
//
// this routine computes Gx=gx*s centered at (i,j), Gy=gy*s centered at (i,j),
// and returns G = sqrt(Gx^2 + Gy^2)

// see https://en.wikipedia.org/wiki/Sobel_operator
//
__device__ float
sobel_filtered_pixel(float *s, int i, int j , int ncols, int nrows, float *gx, float *gy)
{

   float t=0.0;
   float calculatedGx = 0.0, calculatedGy = 0.0;

   int ix_start = i - 1;
   int jy_start = j - 1;

   for(int x = 0; x < 3; x++)
   {
      int ix = ix_start + x;
      if(ix < 0) ix = 0;
      if(ix >= nrows) ix = nrows - 1;
      
      for(int y = 0; y < 3; y++)
      {
         int jy = jy_start + y;
         if(jy < 0) jy = 0;
         if(jy >= ncols) jy = ncols - 1;

         float pixel = s[ix * ncols + jy];
         calculatedGx += pixel * gx[x * 3 + y];
         calculatedGy += pixel * gy[x * 3 + y];
      }
   }

   t = sqrt(calculatedGx * calculatedGx + calculatedGy * calculatedGy);
   return t;
}

//
// this function is the kernel that runs on the device
// 
// this code will look at CUDA variables: blockIdx, blockDim, threadIdx, blockDim and gridDim
// to compute the index/stride to use in striding through the source array, calling the
// sobel_filtered_pixel() function at each location to do the work.
//
// input: float *s - the source data, size=rows*cols
// input: int i,j - the location of the pixel in the source data where we want to center our sobel convolution
// input: int nrows, ncols: the dimensions of the input and output image buffers
// input: float *gx, gy:  arrays of length 9 each, these are logically 3x3 arrays of sobel filter weights
// output: float *d - the buffer for the output, size=rows*cols.
//


__global__ void
sobel_kernel_gpu(float *s,  // source image pixels
      float *d,  // dst image pixels
      int n,  // size of image cols*rows,
      int nrows,
      int ncols,
      float *gx, float *gy) // gx and gy are stencil weights for the sobel filter
{
   // ADD CODE HERE: insert your code here that iterates over every (i,j) of input,  makes a call
   // to sobel_filtered_pixel, and assigns the resulting value at location (i,j) in the output.

   // because this is CUDA, you need to use CUDA built-in variables to compute an index and stride
   // your processing motif will be very similar here to that we used for vector add in Lab #2

   int index = blockIdx.x * blockDim.x + threadIdx.x;
   int stride = blockDim.x * gridDim.x;

   for(int i = index; i < nrows; i += stride)
   {
      float* outPtr = d + i * ncols;
      for(int j = 0; j < ncols; j++){
         outPtr[j] = sobel_filtered_pixel(s, i, j, ncols, nrows, gx, gy);
      }
   }
}

int
main (int ac, char *av[])
{
   // input, output file names hard coded at top of file

   // load the input file
   off_t nvalues = data_dims[0]*data_dims[1];
   unsigned char *in_data_bytes = (unsigned char *)malloc(sizeof(unsigned char)*nvalues);

   FILE *f = fopen(input_fname,"r");
   if (fread((void *)in_data_bytes, sizeof(unsigned char), nvalues, f) != nvalues*sizeof(unsigned char))
   {
      printf("Error reading input file. \n");
      fclose(f);
      return 1;
   }
   else
      printf(" Read data from the file %s \n", input_fname);
   fclose(f);

#define ONE_OVER_255 0.003921568627451

   // now convert input from byte, in range 0..255, to float, in range 0..1
   float *in_data_floats;
   gpuErrchk( cudaMallocManaged(&in_data_floats, sizeof(float)*nvalues) );

   for (off_t i=0; i<nvalues; i++)
      in_data_floats[i] = (float)in_data_bytes[i] * ONE_OVER_255;

   // now, create a buffer for output
   float *out_data_floats;
   gpuErrchk( cudaMallocManaged(&out_data_floats, sizeof(float)*nvalues) );
   for (int i=0;i<nvalues;i++)
      out_data_floats[i] = 1.0;  // assign "white" to all output values for debug

   // define sobel filter weights, copy to a device accessible buffer
   float Gx[9] = {1.0, 0.0, -1.0, 2.0, 0.0, -2.0, 1.0, 0.0, -1.0};
   float Gy[9] = {1.0, 2.0, 1.0, 0.0, 0.0, 0.0, -1.0, -2.0, -1.0};
   float *device_gx, *device_gy;
   gpuErrchk( cudaMallocManaged(&device_gx, sizeof(float)*sizeof(Gx)) );
   gpuErrchk( cudaMallocManaged(&device_gy, sizeof(float)*sizeof(Gy)) );

   for (int i=0;i<9;i++) // copy from Gx/Gy to device_gx/device_gy
   {
      device_gx[i] = Gx[i];
      device_gy[i] = Gy[i];
   }
   
   // now, induce memory movement to the GPU of the data in unified memory buffers

   int deviceID=0; // assume GPU#0, always. OK assumption for this program
   cudaMemPrefetchAsync((void *)in_data_floats, nvalues*sizeof(float), deviceID);
   cudaMemPrefetchAsync((void *)out_data_floats, nvalues*sizeof(float), deviceID);
   cudaMemPrefetchAsync((void *)device_gx, sizeof(Gx)*sizeof(float), deviceID);
   cudaMemPrefetchAsync((void *)device_gy, sizeof(Gy)*sizeof(float), deviceID);

   // set up to run the kernel
   // int nBlocks=1, nThreadsPerBlock=256;

   // ADD CODE HERE: insert your code here to set a different number of thread blocks or # of threads per block
   int nBlocks, nThreadsPerBlock;

   printf("ac: %d\n", ac);
   // set nBlocks andnThreadsPerBlock based on av
   if (ac != 5)
   {
      printf("Usage: sobel_gpu -nb <nBlocks> -nt <nThreadsPerBlock> \n");
      return 1;
   }

   if (strcmp(av[1], "-nb") == 0)
   {
      nBlocks = atoi(av[2]);
      if (nBlocks <= 0)
      {
         printf("Error: Invalid number of blocks. Must be a positive integer.\n");
         return 1;
      }
   }

   if (strcmp(av[3], "-nt") == 0)
   {
      nThreadsPerBlock = atoi(av[4]);
      if (nThreadsPerBlock <= 0)
      {
         printf("Error: Invalid number of threads per block. Must be a positive integer.\n");
         return 1;
      }
   }


   printf(" GPU configuration: %d blocks, %d threads per block \n", nBlocks, nThreadsPerBlock);

   // invoke the kernel on the device
   sobel_kernel_gpu<<<nBlocks, nThreadsPerBlock>>>(in_data_floats, out_data_floats, nvalues, data_dims[1], data_dims[0], device_gx, device_gy);

   // wait for it to finish, check errors
   gpuErrchk (  cudaDeviceSynchronize() );

   // write output after converting from floats in range 0..1 to bytes in range 0..255
   unsigned char *out_data_bytes = in_data_bytes;  // just reuse the buffer from before
   for (off_t i=0; i<nvalues; i++)
      out_data_bytes[i] = (unsigned char)(out_data_floats[i] * 255.0);

   f = fopen(output_fname,"w");

   if (fwrite((void *)out_data_bytes, sizeof(unsigned char), nvalues, f) != nvalues*sizeof(unsigned char))
   {
      printf("Error writing output file. \n");
      fclose(f);
      return 1;
   }
   else
      printf(" Wrote the output file %s \n", output_fname);
   fclose(f);
}

// eof
