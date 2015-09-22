/***************************************************************************************************
* This software module was originally developed by:
*  Toni Zgaljic, Telegra d.o.o.
*
*
* Module Name:
*   Source file for general functions
*  
* Abstract:
*   General util functions and classes used in the software.
*   
***************************************************************************************************/

#include "general.h"
#include "common.h"
#ifdef __SFEC_APP_STANDALONE
#include "libnsgif.h"
#endif

#define MEAS_TIME_LINUX 1

void Error(const string &s)
{
  assert(s.length() != 0);
  cout << endl << "\aError: " << s << endl;
  cout << "  Execution terminated!\n" << endl;
  exit(1);
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//integer square root
long lsqrt (long x)
{
  long   squaredbit, remainder, root;

   if (x<1) return 0;
  
   /* Load the binary constant 01 00 00 ... 00, where the number
    * of zero bits to the right of the single one bit
    * is even, and the one bit is as far left as is consistant
    * with that condition.)
    */
   squaredbit  = (long) ((((unsigned long) ~0L) >> 1) & 
                        ~(((unsigned long) ~0L) >> 2));
   
   /* Form bits of the answer. */
   remainder = x;  root = 0;
   while (squaredbit > 0)
   {
     if (remainder >= (squaredbit | root)) {
         remainder -= (squaredbit | root);
         root >>= 1; root |= squaredbit;
     }
     else
     {
         root >>= 1;
     }
     squaredbit >>= 2; 
   }

   return root;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void ChangeExtension(char *FName, string extension)
{
  Int32 LastDotPos = 0;
  char *auxPt = FName;

  while(*auxPt != '\0')
  {
    if (*auxPt == '.')
      LastDotPos = auxPt - FName;
    auxPt++;
  }
  FName[LastDotPos+1] = extension[0];
  FName[LastDotPos+2] = extension[1];
  FName[LastDotPos+3] = extension[2];
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
string GetExtension(string name)
{
  Int32 LastDotPos = 0;
  const char *auxPt = name.c_str();
  string ret_val("");

  while(*auxPt != '\0')
  {
    if (*auxPt == '.')
      LastDotPos = auxPt - name.c_str();
    auxPt++;
  }
  ret_val.append(name.c_str() + LastDotPos);
  return ret_val;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void *libnsgif_bitmap_create(int width, int height)
{
	return calloc(width * height, 4);
}
void libnsgif_bitmap_set_opaque(void *bitmap, bool opaque)
{
	(void) opaque;  /* unused */
	assert(bitmap);
}
bool libnsgif_bitmap_test_opaque(void *bitmap)
{
	assert(bitmap);
	return false;
}
unsigned char *libnsgif_bitmap_get_buffer(void *bitmap)
{
	assert(bitmap);
	return static_cast<unsigned char*> (bitmap);
}
void libnsgif_bitmap_destroy(void *bitmap)
{
	assert(bitmap);
	free(bitmap);
}
void libnsgif_bitmap_modified(void *bitmap)
{
	assert(bitmap);
	return;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Coord decode_gif(FILE* inFile, Uint8 **decIm, bool rotate, long int *error)
{
#ifdef __SFEC_APP_STANDALONE
  gif_bitmap_callback_vt bitmap_callbacks = 
  {
    libnsgif_bitmap_create,
    libnsgif_bitmap_destroy,
    libnsgif_bitmap_get_buffer,
    libnsgif_bitmap_set_opaque,
    libnsgif_bitmap_test_opaque,
    libnsgif_bitmap_modified
  };
  gif_animation gif;
  gif_result code;
  unsigned int i, k = 0;
  gif_create(&gif, &bitmap_callbacks);
  fseek(inFile,0,SEEK_END);
  Int32 fsiz = ftell(inFile);
  fseek(inFile,0,SEEK_SET);
  unsigned char *gif_data = new unsigned char[fsiz];
  fread(gif_data, 1, fsiz, inFile);
  if (error != NULL)
	  *error = 0;
  do 
  {
    code = gif_initialise(&gif, fsiz, gif_data);
	  if (code != GIF_OK && code != GIF_WORKING) 
	  {
		  if (error != NULL)
		  {
			  *error = 1;
			  delete [] gif_data;
			  return ::Coord(0,0);
		  }
		  else
			  Error("Something went wrong with decoding the input gif file");
	  }
  } 
  while (code != GIF_OK);
  *decIm = new unsigned char [gif.height * gif.width];
  
  for (i = 0; i != gif.frame_count; i++)
  {
		unsigned int row, col;
		unsigned char *image;

		code = gif_decode_frame(&gif, i);
		
		image = (unsigned char *) gif.frame_image;
    for (row = 0; row != gif.height; row++)
    {
			for (col = 0; col != gif.width; col++)
      {
        size_t z;
        z = (row * gif.width + col) * 4;
        if (!rotate)
          decIm[0][k++] = image[z] >> 7;
        else
          decIm[0][(gif.width - col - 1) * gif.height + row] = image[z] >> 7;
      }
    }
  }
  /* clean up */
	gif_finalise(&gif);
  delete [] gif_data;
  if (!rotate)
    return ::Coord(gif.height, gif.width);
  else
    return ::Coord(gif.width, gif.height);
#else
  return ::Coord(0,0);
#endif
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#ifdef MEAS_TIME_LINUX
unsigned long get_time_mseconds(unsigned long& seconds)
{
	struct timespec tp;
	clock_gettime(CLOCK_REALTIME, &tp);
	seconds = tp.tv_sec;
	return (unsigned long)(tp.tv_nsec/1000000);
}
unsigned long time_diff_mseconds(unsigned long ssec, unsigned long smsec, unsigned long esec, unsigned long emsec)
{
	unsigned long msdiff = (esec - ssec) * 1000;
	if (emsec >= smsec)
		msdiff += emsec - smsec;
	else
		msdiff -= smsec - emsec;
	return msdiff;
}
#endif

