//+------------------------------------------------------------------+
//|                                                ZigZagMaxData.mqh |
//|                            Copyright 2022. Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022. Diamond Systems Corp."
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
      ZigZagMaxData     m_ZzmData[];
      datetime          m_TimeFirstBar;
      datetime          m_TimeLastBar;
   
   protected:
      bool              SetFirstBarTime();
      
   public:
                        CZigZagMaxData(void): m_Init(false), m_HandleZzm(INVALID_HANDLE), m_TimeLastBar(0) {};
                       ~CZigZagMaxData(void) {};
      //---
      bool              Init(const string symbol, const ENUM_TIMEFRAMES period, const int calcBarsCount);
      bool              Calculate();
      //---
      string            Symbol()          { return m_Symbol;    };
      ENUM_TIMEFRAMES   Period()          { return m_Period;    };
      int               IndicatorHandle() { return m_HandleZzm; };
};

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
   if (m_TimeLastBar == newBarTime)
      return true;
   
   //--- the first point of reference
   if (m_TimeLastBar == 0 && ! SetFirstBarTime())
      return false;
   
   //--- get data from the indicator
   double zzmTrend[];
   int zzmCnt = CopyBuffer(m_HandleZzm, 2, m_TimeLastBar, newBarTime, zzmTrend);
   
   if (zzmCnt < 2 || m_TimeLastBar != iTime(m_Symbol, m_Period, zzmCnt))
      return false;
   
   //---
   Print(1);
   
   //m_TimeLastBar = newBarTime;
   
//   //--- calc
//   int bars = Bars(m_Symbol, m_Period);
//   
//   if (bars == 0 || bars < ZZMD_CALC_BARS_MIN)
//      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Set the time of the first bar                                    |
//+------------------------------------------------------------------+
bool CZigZagMaxData::SetFirstBarTime()
{
   if (! TerminalInfoInteger(TERMINAL_CONNECTED))
      return false;
   
   int barCnt = iBars(m_Symbol, m_Period);
   if (barCnt < ZZMD_CALC_BARS_MIN)
      return false;
   
   if (m_CalcBarsCount > barCnt)
      m_CalcBarsCount = barCnt;
   
   m_TimeLastBar = iTime(m_Symbol, m_Period, m_CalcBarsCount-1);
   
   return (m_TimeLastBar > 0);
}

//+------------------------------------------------------------------+