//+------------------------------------------------------------------+
//|                                                        Bands.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "STDV Bands of MA"
#property strict
#property version  "1.00" 
#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 5
//#property indicator_color1 color=DarkOrange
/*enum ENUM_price_type
{
 Enum_close,
 Enum_open,
 Enum_high,
 Enum_low,
};*/
//--- indicator parameters
input int    InpPeriod=47;      // Bands Period
input double InpSTDV_Band=0.0005;        // Band STDV
//input ENUM_price_type InpPriceType=Enum_close;
input  color Inpcolor=clrDarkOrange; 
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=1.0; // Bands Deviations
//--- buffers
double ExtMovingBuffer[];
double ExtUpLevel_1Buffer[];
double ExtLowLevel_1Buffer[];
double ExtUpLevel_2Buffer[];
double ExtLowLevel_2Buffer[];
//double ExtStdDevBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   
   
//--- 1 additional buffer used for counting.
   IndicatorBuffers(5);
   IndicatorDigits(Digits);
//--- middle line
   
   SetIndexStyle(0,DRAW_LINE,EMPTY,EMPTY,Inpcolor);
   SetIndexBuffer(0,ExtMovingBuffer);
   SetIndexShift(0,InpBandsShift);
   SetIndexLabel(0,"Banded_MA"+IntegerToString(InpPeriod)+"");
//--- uplevel_1 band
   SetIndexStyle(1,DRAW_LINE,STYLE_DASHDOT,EMPTY,Inpcolor);
   SetIndexBuffer(1,ExtUpLevel_1Buffer);
   SetIndexShift(1,InpBandsShift);
   SetIndexLabel(1,"Up_1");
//--- lowlevel_1 band
   SetIndexStyle(2,DRAW_LINE,STYLE_DASHDOT,EMPTY,Inpcolor);
   SetIndexBuffer(2,ExtLowLevel_1Buffer);
   SetIndexShift(2,InpBandsShift);
   SetIndexLabel(2,"Low_1");
//--- uplevel_2 band
   SetIndexStyle(3,DRAW_LINE,STYLE_DASHDOT,EMPTY,Inpcolor);
   SetIndexBuffer(3,ExtUpLevel_2Buffer);
   SetIndexShift(3,InpBandsShift);
   SetIndexLabel(3,"Up_2");
//--- lowlevel_2 band
   SetIndexStyle(4,DRAW_LINE,STYLE_DASHDOT,EMPTY,Inpcolor);
   SetIndexBuffer(4,ExtLowLevel_2Buffer);
   SetIndexShift(4,InpBandsShift);
   SetIndexLabel(4,"Low_2");
//--- work buffer
   //SetIndexBuffer(3,ExtStdDevBuffer);
//--- check for input parameter
   if(InpPeriod<=0)
     {
      Print("Wrong input parameter Bands Period=",InpPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpPeriod+InpBandsShift);
   SetIndexDrawBegin(1,InpPeriod+InpBandsShift);
   SetIndexDrawBegin(2,InpPeriod+InpBandsShift);
   SetIndexDrawBegin(3,InpPeriod+InpBandsShift);
   SetIndexDrawBegin(4,InpPeriod+InpBandsShift);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int i,pos;
 
   
 
//---
   if(rates_total<=InpPeriod || InpPeriod<=0)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtMovingBuffer,false);
   ArraySetAsSeries(ExtUpLevel_1Buffer,false);
   ArraySetAsSeries(ExtLowLevel_1Buffer,false);
   ArraySetAsSeries(ExtUpLevel_2Buffer,false);
   ArraySetAsSeries(ExtLowLevel_2Buffer,false);
   //ArraySetAsSeries(ExtStdDevBuffer,false);
   ArraySetAsSeries(close,false);
//--- initial zero
   if(prev_calculated<1)
     {
      for(i=0; i<InpPeriod; i++)
        {
         ExtMovingBuffer[i]=EMPTY_VALUE;
         ExtUpLevel_1Buffer[i]=EMPTY_VALUE;
         ExtLowLevel_1Buffer[i]=EMPTY_VALUE;
         ExtUpLevel_2Buffer[i]=EMPTY_VALUE;
         ExtLowLevel_2Buffer[i]=EMPTY_VALUE;
        }
     }
//--- starting calculation
   if(prev_calculated>1)
      pos=prev_calculated-1;
   else
      pos=0;
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- middle line
      ExtMovingBuffer[i]=SimpleMA(i,InpPeriod,close);
      //--- calculate and write down StdDev
      //ExtStdDevBuffer[i]=StdDev_Func(i,close,ExtMovingBuffer,InpBandsPeriod);
      //--- uplevel_1 line
      ExtUpLevel_1Buffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*InpSTDV_Band;
      //--- lowlevel_1 line
      ExtLowLevel_1Buffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*InpSTDV_Band;
      //--- uplevel_2 line
      ExtUpLevel_2Buffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*2*InpSTDV_Band;
      //--- lowlevel_2 line
      ExtLowLevel_2Buffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*2*InpSTDV_Band;
      //---
     }
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position>=period)
     {
      //--- calcualte StdDev
      for(int i=0; i<period; i++)
         StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
      StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
     }
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
