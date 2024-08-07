//+------------------------------------------------------------------+
//|                                                ZigZagMaxData.mqh |
//|                       Copyright 2022-2024. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024. Diamond Systems Corp."
#property link      "https://github.com/mql-systems"

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| CZigZagMaxData class                                             |
//| ----------------------                                           |
//| A class that simplifies working with ZigZagMax indicator data    |
//+------------------------------------------------------------------+
class CZigZagMaxData
{
   private:
      bool              m_Init;
      int               m_CalcBarsCount;
      int               m_HandleZzm;
      string            m_Symbol;
      ENUM_TIMEFRAMES   m_Period;
      //---
      ZigZagMaxInfo     m_ZzmData[];
      int               m_ZzmTotal;
      //---
      datetime          m_InitialTime;
      datetime          m_TimeLastBar;
      datetime          m_NewBarTime;
   
   protected:
      bool              Add(const int zzmTrend, const datetime time, const double priceHigh, const double priceLow);
      bool              SetFirstBarTime();
      
   public:
                        CZigZagMaxData(void);
                       ~CZigZagMaxData(void);
      //---
      bool              Init(const string symbol, const ENUM_TIMEFRAMES period, const int calcBarsCount);
      bool              Calculate();
      //---
      string            Symbol()          { return m_Symbol;      };
      ENUM_TIMEFRAMES   Period()          { return m_Period;      };
      int               IndicatorHandle() { return m_HandleZzm;   };
      int               Total()           { return m_ZzmTotal;    };
      datetime          InitialTime()     { return m_InitialTime; };
      datetime          RecentTime()      { return m_TimeLastBar; };
      ZigZagMaxInfo     At(const int pos) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CZigZagMaxData::CZigZagMaxData(void):m_Init(false),
                                          m_HandleZzm(INVALID_HANDLE),
                                          m_NewBarTime(0),
                                          m_ZzmTotal(0)
{}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CZigZagMaxData::~CZigZagMaxData(void)
{}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CZigZagMaxData::Init(const string symbol, const ENUM_TIMEFRAMES period, const int calcBarsCount)
{
   //--- initialization check
   if (m_Init)
      return (StringCompare(m_Symbol, symbol) == 0 && m_Period == period);
   
   //--- load ZigZagMax indicator
   m_HandleZzm = iCustom(symbol, period, "::"+ZZMD_INDICATOR_ZZM);
   if (m_HandleZzm == INVALID_HANDLE)
      return false;
  
   //---
   m_Symbol = symbol;
   m_Period = period;
   m_CalcBarsCount = MathMin(MathMax(calcBarsCount, ZZMD_CALC_BARS_MIN), ZZMD_CALC_BARS_MAX);
 
   return m_Init = true;
}

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
bool CZigZagMaxData::Calculate()
{
   if (! m_Init)
      return false;
   
   //--- new bar
   datetime newBarTime = iTime(m_Symbol, m_Period, 1);
   
   if (newBarTime == 0)
      return false;
   if (m_NewBarTime == newBarTime)
      return true;
   
   //--- the first point of reference
   if (m_NewBarTime == 0 && ! SetFirstBarTime())
      return false;
   
   //--- get data from the indicator
   double zzmTrend[];
   int zzmCnt = CopyBuffer(m_HandleZzm, 2, newBarTime, m_TimeLastBar, zzmTrend);
   if (zzmCnt < 2)
      return false;
   
   MqlRates barRates[];
   if (CopyRates(m_Symbol, m_Period, 1, zzmCnt, barRates) != zzmCnt || m_TimeLastBar != barRates[0].time)
      return false;
   
   //--- calc
   int i = 1; // the zero element is always calculated
   for (; i<zzmCnt; i++)
   {
      if (zzmTrend[i] == 0)
         break;
      if (! Add((int)zzmTrend[i], barRates[i].time, barRates[i].high, barRates[i].low))
         return false;
      
      m_TimeLastBar = barRates[i].time;
   }
   
   m_NewBarTime = newBarTime;
   
   return true;
}

//+------------------------------------------------------------------+
//| Add ZigZagMaxInfo                                                |
//+------------------------------------------------------------------+
bool CZigZagMaxData::Add(const int zzmTrend, const datetime time, const double priceHigh, const double priceLow)
{
   if (zzmTrend == 0 || zzmTrend > 2 || zzmTrend < -2)
      return false;
   
   // Modification of the past trend
   switch (m_ZzmData[m_ZzmTotal-1].trend)
   {
      case ZZMD_TREND_UP:
         if (zzmTrend > ZZMD_TREND_NONE)
         {
            m_ZzmData[m_ZzmTotal-1].trend = (ENUM_ZZMD_TREND)zzmTrend;
            m_ZzmData[m_ZzmTotal-1].timeB = time;
            m_ZzmData[m_ZzmTotal-1].priceHigh = priceHigh;
            
            if (zzmTrend == ZZMD_TREND_UP_DOWN)
               m_ZzmData[m_ZzmTotal-1].priceThird = priceLow;
            
            return true;
         }
         break;
      
      case ZZMD_TREND_DOWN:
         if (zzmTrend < ZZMD_TREND_NONE)
         {
            m_ZzmData[m_ZzmTotal-1].trend = (ENUM_ZZMD_TREND)zzmTrend;
            m_ZzmData[m_ZzmTotal-1].timeB = time;
            m_ZzmData[m_ZzmTotal-1].priceLow = priceLow;
            
            if (zzmTrend == ZZMD_TREND_DOWN_UP)
               m_ZzmData[m_ZzmTotal-1].priceThird = priceHigh;
            
            return true;
         }
         break;
   }
   
   // Add a new trend
   if (ArrayResize(m_ZzmData, m_ZzmTotal+1, 16) == -1)
      return false;
   
   m_ZzmData[m_ZzmTotal].trend = (ENUM_ZZMD_TREND)zzmTrend;
   m_ZzmData[m_ZzmTotal].timeA = m_ZzmData[m_ZzmTotal-1].timeB;
   m_ZzmData[m_ZzmTotal].timeB = time;
   
   if (zzmTrend < ZZMD_TREND_NONE)
   {
      m_ZzmData[m_ZzmTotal].priceLow = priceLow;
      m_ZzmData[m_ZzmTotal].priceHigh = m_ZzmData[m_ZzmTotal-1].priceHigh;
   }
   else
   {
      m_ZzmData[m_ZzmTotal].priceLow = m_ZzmData[m_ZzmTotal-1].priceLow;
      m_ZzmData[m_ZzmTotal].priceHigh = priceHigh;
   }
   
   switch (zzmTrend)
   {
      case ZZMD_TREND_DOWN_UP: m_ZzmData[m_ZzmTotal].priceThird = priceHigh; break;
      case ZZMD_TREND_UP_DOWN: m_ZzmData[m_ZzmTotal].priceThird = priceLow;  break;
   }
   
   // Change the past double trend to a single one
   switch (m_ZzmData[m_ZzmTotal-1].trend)
   {
      case ZZMD_TREND_UP_DOWN:
         if (zzmTrend < ZZMD_TREND_NONE)
         {
            m_ZzmData[m_ZzmTotal-1].trend = ZZMD_TREND_UP;
            m_ZzmData[m_ZzmTotal-1].priceThird = 0.0;
         }
         break;
      
      case ZZMD_TREND_DOWN_UP:
         if (zzmTrend > ZZMD_TREND_NONE)
         {
            m_ZzmData[m_ZzmTotal-1].trend = ZZMD_TREND_DOWN;
            m_ZzmData[m_ZzmTotal-1].priceThird = 0.0;
         }
         break;
   }
   
   m_ZzmTotal++;
   
   return true;
}

//+------------------------------------------------------------------+
//| Set the time of the first bar                                    |
//+------------------------------------------------------------------+
bool CZigZagMaxData::SetFirstBarTime()
{
   if (! TerminalInfoInteger(TERMINAL_CONNECTED))
      return false;
   
   //--- We define the starting bar
   int barCnt = iBars(m_Symbol, m_Period);
   if (barCnt < ZZMD_CALC_BARS_MIN)
      return false;
   
   if (m_CalcBarsCount > barCnt)
      m_CalcBarsCount = barCnt;
   
   //--- Adding a suitable starting trend. To do this, we get and adjust to the starting trend buffer.
   MqlRates barRates[];
   if (CopyRates(m_Symbol, m_Period, m_CalcBarsCount-2, 2, barRates) != 2)
      return false;
   
   double zzmTrend[];
   if (CopyBuffer(m_HandleZzm, 2, barRates[1].time, 1, zzmTrend) != 1)
      return false;
   
   if (ArrayResize(m_ZzmData, 1, 16) == -1)
      return false;
   
   m_ZzmTotal = 1;
   m_ZzmData[0].timeA = barRates[0].time;
   
   if (int(zzmTrend[0]) > ZZMD_TREND_NONE)
   {
      m_ZzmData[0].trend = ZZMD_TREND_UP;
      m_ZzmData[0].priceLow = barRates[0].low;
   }
   else
   {
      m_ZzmData[0].trend = ZZMD_TREND_DOWN;
      m_ZzmData[0].priceHigh = barRates[0].high;
   }
   
   //--- Setting the starting time
   m_TimeLastBar = m_NewBarTime = m_InitialTime = barRates[0].time;
   
   return true;
}

//+------------------------------------------------------------------+
//| Access to data in the specified position                         |
//+------------------------------------------------------------------+
ZigZagMaxInfo CZigZagMaxData::At(const int pos) const
{
   if (pos > -1 && pos < m_ZzmTotal)
      return m_ZzmData[pos];
   
   ZigZagMaxInfo zzmInfo;
   return zzmInfo;
}

//+------------------------------------------------------------------+