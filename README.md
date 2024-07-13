# ZigZagMaxData

Library for convenient calculation of the [ZigZagMax](https://github.com/mql-systems/ZigZagMax_indicator) indicator buffer.

The data is collected in the form of a structural array with trend, max-min prices and the start-end time of the trend (one element, one pulse).

![ZigZagMaxData](https://github.com/mql-systems/ZigZagMaxData_inc/raw/main/image.png)


## Installation

Downloading and installing ZigZagMaxData

```bash
cd "YourMT4(5)TerminalPath\MQL4(5)\Include"
git clone https://github.com/mql-systems/ZigZagMaxData_inc.git MqlSystems/ZigZagMaxData
```

Now upload the [ZigZagMax](https://github.com/mql-systems/ZigZagMax_indicator#download) indicator itself to the folder `MqlSystems/ZigZagMaxData`. We upload `ZigZagMax.ex4` and `ZigZagMax.ex5` files.


## Examples

Script

```mql5
//+------------------------------------------------------------------+
//|                                            ZigZagMaxDataTest.mq5 |
//|                       Copyright 2022-2024. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024. Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"
#property script_show_inputs

#include <MqlSystems/ZigZagMaxData/ZigZagMaxData.mqh>

input int i_CalcBarsCount = 5000;    // Calc bars

CZigZagMaxData Zzmd;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   if (! Zzmd.Init(_Symbol, _Period, i_CalcBarsCount))
   {
      Alert("Error initializing ZigZagMaxData");
      return;
   }
   
   if (! Zzmd.Calculate())
   {
      Alert("Error when calculating ZigZagMaxData data");
      return;
   }
   
   int zzmdTotal = Zzmd.Total();
   ZigZagMaxInfo zzmdInfo;
   
   for (int i = 0; i < zzmdTotal; i++)
   {
      Print("========== ", i, " ==========");
      
      zzmdInfo = Zzmd.At(i);
      
      Print("trend: ", ZzmdTrendToStr(zzmdInfo.trend));
      Print("timeA: ", zzmdInfo.timeA);
      Print("timeB: ", zzmdInfo.timeB);
      Print("priceLow: ", zzmdInfo.priceLow);
      Print("priceHigh: ", zzmdInfo.priceHigh);
      Print("priceThird: ", zzmdInfo.priceThird);
   }
}

//+------------------------------------------------------------------+
//| Convert ZZM trend to string                                      |
//+------------------------------------------------------------------+
string ZzmdTrendToStr(const ENUM_ZZMD_TREND trend)
{
   switch(trend)
   {
      case ZZMD_TREND_NONE:    return "NONE";
      case ZZMD_TREND_UP:      return "UP";
      case ZZMD_TREND_UP_DOWN: return "UP_DOWN";
      case ZZMD_TREND_DOWN:    return "DOWN";
      case ZZMD_TREND_DOWN_UP: return "DOWN_UP";
      //---
      default: return "?";
   }
}

//+------------------------------------------------------------------+
```