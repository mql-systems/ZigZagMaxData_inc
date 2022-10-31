//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                            Copyright 2022. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022. Diamond Systems Corp."
#property link      "https://github.com/mql-systems"

#define ZZMD_CALC_BARS_MIN 100
#define ZZMD_CALC_BARS_MAX 8000

//--- ZigZagMax indicator resource
#ifndef ZZMD_INDICATOR_ZZM
   #ifdef __MQL4__
      #define ZZMD_INDICATOR_ZZM "ZigZagMax.ex4"
   #else
      #define ZZMD_INDICATOR_ZZM "ZigZagMax.ex5"
   #endif
#endif

#resource "\\"+ZZMD_INDICATOR_ZZM

//--- ZigZagMax Trend buffer
enum ENUM_ZZMD_TREND
{
   ZZMD_TREND_NONE      =  0, // 0
   ZZMD_TREND_UP        =  1, // 1
   ZZMD_TREND_UP_DOWN   =  2, // 2
   ZZMD_TREND_DOWN      = -1, // -1
   ZZMD_TREND_DOWN_UP   = -2  // -2
};

//--- to collect ZigZagMax data
struct ZigZagMaxInfo
{
   double   priceHigh;
   double   priceLow;
   double   priceThird;
   datetime timeA;
   datetime timeB;
   int      trend;
   //---
   void ZigZagMaxInfo(): priceThird(0.0) {}
};