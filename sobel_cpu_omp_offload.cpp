//
// (C) 2021, E. Wes Bethel
// sobel_cpu_omp_offload.cpp
// usage:
//      sobel_cpu_omp_offload [no args, all is hard coded]
//

#include <iostream>
#include <vector>
#include <chrono>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <omp.h>

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


// see https://en.wikipedia.org/wiki/Sobel_operator

//
// sobel_filtered_pixel(): perform the sobel filtering at a given i,j location
//
// input: float *s - the source data
// input: int i,j - the location of the pixel in the source data where we want to center our sobel convolution
// input: int nrows, ncols: the dimensions of the input and output image buffers
// input: float *gx, gy:  arrays of length 9 each, these are logically 3x3 arrays of sobel filter weights
//
// this routine computes Gx=gx*s centered at (i,j), Gy=gy*s centered at (i,j),
// and returns G = sqrt(Gx^2 + Gy^2)

// see https://en.wikipedia.org/wiki/Sobel_operator
//
float
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
//  do_sobel_filtering() will iterate over all input image pixels and invoke the
//  sobel_filtered_pixel() function at each (i,j) location of input to compute the
//  sobel filtered output pixel at location (i,j) in output.
//
// input: float *in - the source data, size=rows*cols
// input: int i,j - the location of the pixel in the source data where we want to center our sobel convolution
// input: int nrows, ncols: the dimensions of the input and output image buffers
// input: float *gx, gy:  arrays of length 9 each, these are logically 3x3 arrays of sobel filter weights
// output: float *out - the buffer for the output, size=rows*cols.
//
void
do_sobel_filtering(float *in, float *out, int ncols, int nrows)
{
   float Gx[] = {1.0, 0.0, -1.0, 2.0, 0.0, -2.0, 1.0, 0.0, -1.0};
   float Gy[] = {1.0, 2.0, 1.0, 0.0, 0.0, 0.0, -1.0, -2.0, -1.0};

   off_t out_indx = 0;
   int width, height, nvals;

   width=ncols;
   height=nrows;
   nvals=width*height;

// define the data mapping from the host to the device
// some of the data we only need to send: in, Gx, Gy, width, height
// some of the data we only need to retrieve: out

#pragma omp target data map(to:in[0:nvals]) map(to:width) map(to:height) map(to:Gx[0:9]) map(to:Gy[0:9]) map(from:out[0:nvals])
   {
      #pragma omp target teams distribute parallel for
      for(int i = 0; i < nrows; i++)
      {
         float* outPtr = out + i * ncols;
         for(int j = 0; j < ncols; j++)
            outPtr[j] = sobel_filtered_pixel(in, i, j, ncols, nrows, Gx, Gy);
      }
   }// end pragma omp target data
}


int
main (int ac, char *av[])
{
   // filenames, etc, hard coded at the top of the file
   // load input data
//    char input_fname[]="../data/zebra-gray-raw-int8.dat";
//   int data_dims[2] = {3556, 2573};
//   char output_fname[] = "../data/processed-raw-int8-cpu.dat";

   off_t nvalues = data_dims[0]*data_dims[1];
   unsigned char *in_data_bytes = (unsigned char *)malloc(sizeof(unsigned char)*nvalues);

   FILE *f = fopen(input_fname,"r");
   if (f == NULL)
   {
      printf(" Error opening the input file: %s \n", input_fname);
      return 1;
   }
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

   // now convert from byte, in range 0..255, to float, in range 0..1
   float *in_data_floats = (float *)malloc(sizeof(float)*nvalues);
   for (off_t i=0; i<nvalues; i++)
      in_data_floats[i] = (float)in_data_bytes[i] * ONE_OVER_255;

   // now, create a buffer for output
   float *out_data_floats = (float *)malloc(sizeof(float)*nvalues);

   // do the processing =======================
   std::chrono::time_point<std::chrono::high_resolution_clock> start_time = std::chrono::high_resolution_clock::now();

   do_sobel_filtering(in_data_floats, out_data_floats, data_dims[0], data_dims[1]);

   std::chrono::time_point<std::chrono::high_resolution_clock> end_time = std::chrono::high_resolution_clock::now();

   std::chrono::duration<double> elapsed = end_time - start_time;
   std::cout << " Elapsed time is : " << elapsed.count() << " " << std::endl;

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
