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

//--- to collect ZigZagMax data
struct ZigZagMaxData
{
   double   doubleHigh;
   double   doubleLow;
   datetime timeHigh;
   datetime timeLow;
};