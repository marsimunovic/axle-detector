/***************************************************************************************************
* This software module was originally developed by:
*  Toni Zgaljic, Telegra d.o.o.
*
*
* Module Name:
*   Header file for general functions
*  
* Abstract:
*   General util functions and classes used in the software.
*   
***************************************************************************************************/

#ifndef GENERAL_H
#define GENERAL_H

#include <cstdio>
#include <cassert>
#include <iostream>
#include <string>
#include <cstring>
#include <cmath>
#include <cstdlib>
#include <vector>
#include <time.h>
#include "common.h"

using namespace std;

const string IntroMessage = "Software for feature extraction and classification (SFEC)\nVer. 0.48\nTelegra d.o.o, Plesivicka 3, Sv. Nedjelja, Croatia\nFor internal use only!\n\n";

//----------type definitions-----------//
typedef signed char 	      Int8; //          -128 to           127
typedef unsigned char 	   Uint8; //             0 to           255
typedef signed short 	     Int16; //       -32,768 to        32,767
typedef unsigned short 	  Uint16; //             0 to        65,535
typedef signed long int    Int32; //-2,147,483,648 to 2,147,483,647
typedef unsigned long int Uint32; //             0 to 4,294,967,295
typedef long long Int64;

const Int32 MAX_INT_32 = 0x7FFFFFFF;

#ifdef MEAS_TIME_LINUX
unsigned long get_time_mseconds(unsigned long& seconds);
unsigned long time_diff_mseconds(unsigned long ssec, unsigned long smsec, unsigned long esec, unsigned long emsec);
#endif

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
//  General fuctions                
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
void Error(const string &s); // Write error message and exit
long lsqrt (long x); // square root of a long number
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// square of a
template <typename Type> inline Type Pow2(Type a)
{
  return a * a;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// a ^ 3
template <typename Type> inline Type Pow3(Type a)
{
  return a * a * a;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// a ^ 4
template <typename Type> inline Type Pow4(Type a)
{
  return a * a * a * a;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// a ^ 5
template <typename Type> inline Type Pow5(Type a)
{
  return a * a * a * a * a;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// a ^ 2.5
template <typename Type> inline Type Pow2_5(Type a)
{
  return static_cast<Type> (sqrt(static_cast<double> (a)) * a * a );
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// maximum of a and b
template <typename Type> inline Type Max(Type a, Type b)
{
  return (a > b ? a : b);
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// maximum of a, b and c 
template <typename Type> inline Type Max(Type a, Type b, Type c)
{
  return Max(Max(a,b),c);
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// maximum of a, b, c and d
template <typename Type> inline Type Max(Type a, Type b, Type c, Type d)
{
  return Max(Max(a,b),Max(c,d));
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// minimum of a and b
template <typename Type> inline Type Min(Type a, Type b)
{
  return (a > b ? b : a);
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//square of a number
template <typename Type> inline Type Square(Type a)
{
  return a * a;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// mean of a vector
inline float Mean(Int16 *dataPt, Int32 nDatum)
{
  Int32 i;
  Int32 sum = 0;
  for (i = 0; i < nDatum; i++)
  {
    sum += dataPt[i];
  }

  if (nDatum > 0)
    return ((static_cast<float> (sum)) / nDatum);
  else
    return 0;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Sum of absolute differences from the mean of a vector
inline float averageSADM(Int16 *dataPt, Int32 nDatum)
{
  Int32 i; 
  float SADM = 0.0f;
  float mean = Mean(dataPt, nDatum);
  for (i = 0; i < nDatum; i++)
    SADM += fabs(dataPt[i] - mean);

  if (nDatum > 0)
    return (SADM / nDatum);
  else
    return 0;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// variance
inline float Variance(Int16 *dataPt, Int32 nDatum)
{
  Int32 i; 
  float VAR = 0.0f;
  float mean = Mean(dataPt, nDatum);
  for (i = 0; i < nDatum; i++)
    VAR += Square(dataPt[i] - mean);

  if (nDatum > 0)
    return (VAR / nDatum);
  else
    return 0;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// euclidean distance between two vectors (using integer calculations)
inline long EuclideanDist(long *vec1, long *vec2, long dim)
{
  int i;
  long sum = 0;
  long auxsum;
  for (i = 0; i < dim; i++)
  {
    auxsum = vec1[i] - vec2[i];
    sum += auxsum * auxsum; 
  }
  return lsqrt(sum);
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//check if a number is power of 2
inline bool IsPower2(Int32 x)
{
  return ( (x > 0) && ((x & (x - 1)) == 0) );
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// how many shift to perform on a number to get 1 (number must be power of two)
inline Int32 ShiftsToGetOne(Int32 x)
{
  assert(IsPower2(x));
  Int32 shift = 0;
  while(1)
  {
    if (x == 1)
      break;
    else
    {
      shift++;
      x >>= 1;
    }      
  }
  return shift;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// finsc closest power of two of a number x
inline Int32 FindClosestPow2(Int32 x)
{
  Int32 tmp_x = x;
  Int32 shift_cnt = 0, LB, HB;
  // find out in what range it falls
  while (tmp_x != 1)
  {
    tmp_x >>= 1;
    shift_cnt++;
  }
  LB = tmp_x << shift_cnt;
  HB = tmp_x << (shift_cnt + 1);
  if ((x - LB) <= (HB - x))
    return LB;
  else
    return HB;
}
// change extension part of the filename
void ChangeExtension(char *FName, string extension);
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
//  class Coord - used for coordinates and dimensions of 2D arrays//                
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
class Coord
{
public:
  Int32 row, col; // row coordinate and column coordinate
  //default constructor: coordinates are set to zero
  Coord(void)
  {
    row = 0;
    col = 0;
  }
  // constructor that sets initial coordinates
  Coord(Int32 i, Int32 j)
  {
    row = i;
    col = j;
  }
  // constructor that sets both coordinates to the same value: i
  Coord(Int32 i)
  {
    row = i;
    col = i;
  }
  // sets row and column coordinate to values i and j respectively
  inline void Set(Int32 i, Int32 j)
  {
    row = i;
    col = j;
  }
  // sets row and column coordinate to the value ij
  inline void Set(Int32 ij)
  {
    row = ij;
    col = ij;  
  }
  //checks if both row and col are equal
  bool operator &=(Int32 a) const 
  {
    return ((row == a) & (col == a));
  }
   //checks if either row or col are equal
  bool operator |=(Int32 a) const
  {
    return ((row == a) || (col == a));
  }
  //checks if coordinates are equal
  bool operator ==(Coord sc) const 
  {
    return ((row == sc.row) && (col == sc.col));
  }
  // add coordinates
  Coord operator +(Coord sc)
  {
    return Coord(row + sc.row, col + sc.col);
  }
  // subtract coordinates
  Coord operator -(Coord sc)
  {
    return Coord(row - sc.row, col - sc.col);
  }
  // add a number to both coordinates
  Coord operator +(Int32 a)
  {
    return Coord(row + a, col + a);
  }
  // subtract a number from both coordinates
  Coord operator -(Int32 a)
  {
    return Coord(row - a, col - a);
  }
  // multiply coordinates with a number
  Coord operator *(Int32 i)
  {
    return Coord(row * i, col * i);
  }
  // multiply coordinates with other coordinates, rows and columns separately
  Coord operator *(Coord sc)
  {
    return Coord(row * sc.row, col * sc.col);
  }
  // right shift both coordinates i times
  Coord operator >>(Int32 i)
  {
    Int32 nr = row >> i;
    Int32 nc = col >> i;
    return Coord(nr, nc);
  }
  Coord operator >>(Int32 i) const
  {
    Int32 nr = row >> i;
    Int32 nc = col >> i;
    return Coord(nr, nc);
  }
  // right shift coordinates i times and set result as new values for this object
  void operator >>=(Int32 i)
  {
    *this = *this >> i;
  }
  // left shift coordinates i times
  Coord operator <<(Int32 i)
  {
    Int32 nr = row << i;
    Int32 nc = col << i;
    return Coord(nr, nc);
  }
  // left shift coordinates i times and set result as new values for this object
  void operator <<=(Int32 i)
  {
    *this = *this << i;
  }
  //if any of the coordinates is larger
  bool operator >(Coord sc)
  {
    return ((row > sc.row) | (col > sc.col));
  }   
};

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
//                                class Array
//  a two-dimensional array and its corresponding operations
//
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
template<typename T> class Array
{
private: 
  T *all_data, *segment_data_; // pointers to the whole array and to a particular square area of the array
  Int32 total_nrows_, total_ncols_, total_length_; // number of rows of the whole array ,coloumns and the total number of elements
  Int32 curr_nrows_, curr_ncols_, curr_length_; // number of rows and colums of a particular area in the array, total number of elements in the area
  Int32 originrow_, origincol_; // origin row and column of a square area in the array, relative to top left corner of the whole array
  
public:
  // default constructor
  Array()
  {
    Init();
  };
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // constructor with matrix dimensions, separately for rows and columns 
  Array(Int32 rows, Int32 cols)
  {
    Init();
    Allocate(rows,cols);
  };
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //constructor for square array
  Array(Int32 dim) 
  {
    Init();
    Allocate(dim,dim);
  };
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //copy constructor
  Array(const Array &refArray): 
  all_data(new T[refArray.total_length_]),
  total_nrows_(refArray.total_nrows_),
	total_ncols_(refArray.total_ncols_),
	total_length_(refArray.total_length_),
  curr_nrows_(refArray.curr_nrows_),
	curr_ncols_(refArray.curr_ncols_),
	curr_length_(refArray.curr_length_),
  originrow_(refArray.originrow_), 
  origincol_(refArray.origincol_)
  {
    for (Int32 ind = 0; ind < total_length_; ind++) all_data[ind] = refArray.all_data[ind];
    segment_data_ = all_data + originrow_ * total_ncols_ + origincol_;
  };
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //destructor
  ~Array() {Release();}
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // initialise variables
  void Init()
  {
   all_data = segment_data_ = NULL;
	 total_nrows_ = total_ncols_ = total_length_ = 0;
   curr_nrows_ = curr_ncols_ = curr_length_ = 0;
   originrow_ = origincol_ = 0;
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  inline Int32 Rows() const {return curr_nrows_;}; // get number of rows
  inline Int32 Cols() const {return curr_ncols_;}; // get numner of columns
  inline Int32 TotalRows() const {return total_nrows_;}; // get number of rows
  inline Int32 TotalCols() const {return total_ncols_;}; // get numner of columns
  inline T *GetAllDatapt() const {return all_data;};
  inline Coord ArrayDim() const {return ::Coord(curr_nrows_,curr_ncols_);}; // get matrix dimensions
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // allocate memory for the matrix, row and column dimensions specified separately
  Int32 Allocate(Int32 rows, Int32 cols)
  {
    //assert((rows > 0) && (cols > 0));
    Int32 newsize = rows * cols;
    if (total_length_ != newsize) //else already allocated the same size
    {
      Release();
      total_length_ = curr_length_ = newsize;
      all_data = new T[total_length_];
      if (all_data == NULL)
      {
    	  //Error("Array::Allocate, could not allocate memory!");
    	  return -1;
      }
      segment_data_ = all_data;
    }
    total_nrows_ = curr_nrows_ = rows;
    total_ncols_ = curr_ncols_ = cols;
    originrow_ = origincol_ = 0;
    return (total_length_ * sizeof(T)); 
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // assigned preallocated memory space for the matrix, row and column dimensions specified separately
  Int32 AssignAllocatedArray(Uint8* impt, Int32 rows, Int32 cols)
  {
    total_length_ = curr_length_ = rows * cols;
    all_data = impt;
    segment_data_ = all_data;
    total_nrows_ = curr_nrows_ = rows;
    total_ncols_ = curr_ncols_ = cols;
    originrow_ = origincol_ = 0;
    return (total_length_ * sizeof(T)); 
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // rotates and adds white borders
  void RotateAndADDBorders(Uint8* impt, T value)
  {
	  Int32 r, c;
	  T *tmpdata = all_data;
	  T *srcpt;

	  //first row
	  fill(tmpdata, tmpdata + total_ncols_, value); //fills range [data_, data_ + curr_ncols_>
	  tmpdata += total_ncols_;

	  // middle rows
	  for (r = 1; r < this->total_nrows_-1; r++)
	  {
		  srcpt = impt + total_nrows_-3-(r-1);
		  // first column in a row
		  *(tmpdata++) = value;
		  // rest of columns in a row
		  for (c = 1; c < this->total_ncols_-1; c++)
		  {
			  *(tmpdata++) = *srcpt;
			  srcpt += total_nrows_-2;
		  }
		  //last column in a row
		  *(tmpdata++) = value;
	  }

	  // last row
	  fill(tmpdata, tmpdata + total_ncols_, value); //fills range [data_, data_ + curr_ncols_>
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // release memory of matrix and set all values to initial
  inline Int32 Release()
  {
    Int32 l = total_length_;
    segment_data_ = NULL;
    delete [] all_data;
    all_data = NULL;
    total_length_ = curr_length_ = 0;
    total_nrows_ = curr_nrows_ = 0;
    total_ncols_ = curr_ncols_ = 0;
    originrow_ = origincol_ = 0;
    return (l * sizeof(T));
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void Copy(Array &refArray)
  {
    all_data = new T[refArray.total_length_];
    total_nrows_ = refArray.total_nrows_;
	  total_ncols_ = refArray.total_ncols_;
	  total_length_ = refArray.total_length_;
    curr_nrows_ = refArray.curr_nrows_;
	  curr_ncols_ = refArray.curr_ncols_;
	  curr_length_ = refArray.curr_length_;
    originrow_ = refArray.originrow_;
    origincol_ = refArray.origincol_;
  
    for (Int32 ind = 0; ind < total_length_; ind++) all_data[ind] = refArray.all_data[ind];
    segment_data_ = all_data + originrow_ * total_ncols_ + origincol_;
  };
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // the following versions of overloaded function set new origin in the array, relative ot the upper left corner of the array
  // the size of the array is changed as well. i.e. the array behaves in the same way as if it was originally allocated this way
  inline void SetNewOrigin(Int32 pos, Coord newDim)
  {
    assert((pos < total_nrows_) && (pos < total_ncols_));
    segment_data_ = all_data + pos * total_ncols_ + pos;
    curr_nrows_ = newDim.row;
    curr_ncols_ = newDim.col;
    curr_length_ = curr_nrows_ * curr_ncols_;
    originrow_ = origincol_ = pos;
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  inline void SetNewOrigin(Int32 row, Int32 col, Int32 new_rows, Int32 new_cols)
  {
    assert((row < total_nrows_) && (col < total_ncols_));
    segment_data_ = all_data + row * total_ncols_ + col;
    curr_nrows_ = new_rows;
    curr_ncols_ = new_cols;
    curr_length_ = curr_nrows_ * curr_ncols_;
    originrow_ = row;
    origincol_ = col; 
  }  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  inline Coord GetCurrOrigin()
  {
    return ::Coord(originrow_,origincol_);
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  /* Reads data froom memory */
  Int32 ReadArea(Uint8 *mempt, Coord size)
  {
    assert(mempt != NULL);
    assert(sizeof(T) == 1);
    
    Int32 i, pos, pos1;
    //Int32 numel = 0;
    for (i = 0; i < size.row; i++)
    {
      pos = i * total_ncols_;
      pos1 = i * curr_ncols_;
      memcpy(&segment_data_[pos], &mempt[pos1], size.col);
    }

    return 1;
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  /* Reads data froom the input binary file */
  Int32 ReadArea(FILE *IFile, Coord size)
  {
    assert(IFile != NULL);
    
    Int32 i, pos;
    Int32 numel = 0;
    for (i = 0; i < size.row; i++)
    {
      pos = i * total_ncols_;
      numel += fread(&segment_data_[pos], sizeof(T), size.col, IFile);
    }

    assert(numel == (size.row * size.col));
    return numel;
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  /* writes data into the output binary file */
  Int32 WriteArea(FILE *OFile, Coord size)
  {
    assert(OFile != NULL);
    
    Int32 i, pos;
    Int32 numel = 0;
    for (i = 0; i < size.row; i++)
    {
      pos = i * total_ncols_;
      numel += fwrite(&segment_data_[pos], sizeof(T), size.col, OFile);
    }

    assert(numel == (size.row * size.col));
    return numel;
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  /* writes data into the output binary file */
  Int32 WriteChangedArea(FILE *OFile, Coord size)
  {
    assert(OFile != NULL);
    
    Int32 i, j, pos;
    Int32 numel = 0;
    T tmpval;
    for (i = 0; i < size.row; i++)
    {
      for (j = 0; j < size.col; j++)
      {
        pos = i * total_ncols_ + j;
        if (segment_data_[pos] == 1)
        {
          tmpval = 255;
          numel += fwrite(&tmpval, sizeof(T), 1, OFile);
        }
        else if (segment_data_[pos] == 2)
        {
          tmpval = 1;
          numel += fwrite(&tmpval, sizeof(T), 1, OFile);
        }
        else if (segment_data_[pos] == 3)
        {
          tmpval = 254;
          numel += fwrite(&tmpval, sizeof(T), 1, OFile);
        }
        else
        {
          tmpval = segment_data_[pos];
          numel += fwrite(&tmpval, sizeof(T), 1, OFile);
        }
      }
    }

    assert(numel == (size.row * size.col));
    return numel;
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  inline bool isNotFragmented()
  {
    if ((all_data == segment_data_) && (total_nrows_ == curr_nrows_) && (total_ncols_ == curr_ncols_) && (total_length_ == curr_length_)) return true;
    else return false;
	}
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  void PaddBorders(Int32 size, T value)
  {
    Int32 r, c;
    Int32 newR = total_nrows_ + (size << 1);
    Int32 newC = total_ncols_ + (size << 1);
    Int32 newsize = newR * newC;
   
    segment_data_ = new T[newsize];
    if (segment_data_ == NULL) Error("Array::PaddBorders, could not allocate memory!");
    T *init_all_data = all_data;
    T *init_segment_data_ = segment_data_;

    // copy old data with padded values
    // first fill top rows with padded values

    for (r = 0; r < size; r++)
    {
      for (c = 0; c < newC; c++)
      {
        *(segment_data_++) = value;
      }
    }

    for (r = 0; r < total_nrows_; r++)
    {
      for (c = 0; c < size; c++)
      {
        *(segment_data_++) = value;
      }
      memcpy(segment_data_, all_data, total_ncols_ * sizeof(T));
      segment_data_ += total_ncols_;
      all_data += total_ncols_;
      for (c = 0; c < size; c++)
      {
        *(segment_data_++) = value;
      }
    }

    for (r = 0; r < size; r++)
    {
      for (c = 0; c < newC; c++)
      {
        *(segment_data_++) = value;
      }
    }

    all_data = init_all_data;
    segment_data_ = init_segment_data_;

    delete [] all_data;

    all_data = segment_data_; 
    total_nrows_ = newR;
    total_ncols_ = newC;
    total_length_ = newR * newC;
    
    curr_nrows_ = total_nrows_;
    curr_ncols_ = total_ncols_;
    curr_length_ = total_length_; 
    originrow_ = origincol_ = 0;     
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // returns reference to the element with coordinates (row, col)
  inline T& operator() (Int32 row, Int32 col) const
  {
    return segment_data_[row*total_ncols_ + col];
  }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // returns reference to the element with coordinates (row, col)
  inline T& operator() (Coord pos) const
  {
    return segment_data_[pos.row*total_ncols_ + pos.col];
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  }
  //fill with a single value
  inline Array& operator= (const T& value) 
  {
    Int32 i;
    T *tmp_row = segment_data_;
    for (i = 0; i < curr_nrows_; i++)
    {
      fill(tmp_row, tmp_row + curr_ncols_, value); //fills range [data_, data_ + curr_ncols_>
      tmp_row += total_ncols_;
    }
    return *this;
  }
};
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
string GetExtension(string name);
Coord decode_gif(FILE* inFile, Uint8 **decIm, bool rotate, long int *error);
void *libnsgif_bitmap_create(int width, int height);
void libnsgif_bitmap_set_opaque(void *bitmap, bool opaque);
bool libnsgif_bitmap_test_opaque(void *bitmap);
unsigned char *libnsgif_bitmap_get_buffer(void *bitmap);
void libnsgif_bitmap_destroy(void *bitmap);
void libnsgif_bitmap_modified(void *bitmap);

#endif
