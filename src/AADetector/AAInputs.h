/***************************************************************************************************
* This software module was originally developed by:
*  Marijo Simunovic, Telegra d.o.o.
*
*  
* Abstract:
*   Decision parameters for auxiliary axle detection
*   
***************************************************************************************************/

#ifndef AAINPUTS_H
#define AAINPUTS_H

//Auxiliary Axle Detector Input Parameter Definition File

/*
MIN_TYRE_WIDTH - min tyre width in pixels
MAX_PIXEL_VARATION - maximum pixel variation between two neighbor minima
MAX_LIFTED_HEIGHT - lowest point of lifted tyre in pixels
MIN_TYRE_RADIUS - min lifted tyre radius 	
MAX_EDGE_HEIGHT_RATIO - ratio between tyre left and right edge heights
WIDTH_PERCENTAGE - min percentage of real axle width in candidates
WIDTH_PERCENTAGE2 - min percentage of real axle width if candidate min position > 10 px
MAIN_AXLE_RATIO - ratio between two bigges main axles, determines allowed aux axle length
-----------
MIN_ACCEPTED_LEN - minimum required vehicle length, smaller vehicles are skipped
MAX_ACCEPTED_LEN - maximum allowed vehicle length, bigger vehicles are skipped
ALLOWED_HAX_RATIO - max allowed length ratio of two detected axle half widths
MIN_POS_IND - min allowed absolute position of the axle from the beginning of the vehicle
MIN_REL_POS - min allowed position of the axle relative to the vehicle total length
MIN_AXLE_HHEIGHT - half of the min allowd axle height
MAX_EDGE_HEIGHT_DIFF - max allowed height difference between left and right axle edge
MAX_CNTRY - max allowd height of the axle center
MIN_AXLE_HWIDTH = half of the minimal axle width
MIN_AREA_RATIO = min allowed ratio between detected axle area and projected ellipse
MIN_AREA_RATIO_8 - MIN_AREA_RATIO for profiles with min point height over 8 pixels
MAX_AREA_RATIO = max allowed ratio between detected axle area and projected ellipse
MAX_AREA_RATIO_8 - MAX_AREA_RATIO for profiles with min point height over 8 pixels
REAL_WIDTH_ROW1_PC - percentage of black pixels in the first row of the lower axle half
REAL_WIDTH_ROW2_PC - percentage of black pixels in the second row of the lower axle half
LOWER_PART - number of lower profile pixels used in axle detection
AXLE_SIDE_VARIABILITY_8 - percentage of required axle edge variability (min point height over 8 pixels)
*/

//USED ON FILTERED VEHICLE EDGE
const Uint8   MIN_TYRE_WIDTH = 20;
const Uint8   MAX_PIXEL_VARIATION = 3;
const Uint8   MIN_TYRE_RADIUS = 5;
const float   MAX_LIFTED_HEIGHT = 15.0f;
const float   MAX_EDGE_HEIGHT_RATIO = 4.0f;
const float   WIDTH_PERCENTAGE = 0.5f;
const float   WIDTH_PERCENTAGE2 = 0.7f;
const float   MAIN_AXLE_RATIO = 1.2f;

//USED ON RAW VEHICLE EDGE
const Uint16  MIN_ACCEPTED_LEN = 400;
const Uint16  MAX_ACCEPTED_LEN = 65534;
const Uint16  ALLOWED_HAX_RATIO = 200;
const Uint16  MIN_POS_IND = 350;
const Uint8   MIN_REL_POS = 20;
const Uint8   MIN_AXLE_HHEIGHT = 7;
const Uint8   MAX_EDGE_HEIGHT_DIFF = 20;
const Uint8   MAX_CNTRY = 34; //this should not be bigger
const Uint8   MIN_AXLE_HWIDTH = 10;
const Uint8   MIN_AREA_RATIO = 85;
const Uint8   MAX_AREA_RATIO = 130;
const Uint8   MIN_AREA_RATIO_8 = 90;
const Uint8   MAX_AREA_RATIO_8 = 115;
const Uint8   REAL_WIDTH_ROW1_PCT = 85; //percent
const Uint8   REAL_WIDTH_ROW2_PCT = 85; //percent
const Uint8   LOWER_PART = 70;
const Uint8   AXLE_SIDE_VARIABILITY_8 = 50; //percent

#endif//AAINPUTS_H
