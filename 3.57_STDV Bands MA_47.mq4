//+------------------------------------------------------------------+
//|                                                        Bands.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Bollinger Bands"
#property strict

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 DarkOrange
#property indicator_color2 DarkOrange
#property indicator_color3 DarkOrange
#property indicator_color4 DarkOrange
#property indicator_color5 DarkOrange
//--- indicator parameters
input int    InpBandsPeriod=47;      // Bands Period
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=1.0; // Bands Deviations

double InpSTDV_Band=0;        // Band STDV
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
   switch(Period())
     {
      case 1:
         InpSTDV_Band=0.00062;
         break;

      case 5:
         InpSTDV_Band=0.00116;
         break;

      case 15:
         InpSTDV_Band=0.00236;
         break;

      case 30:
         InpSTDV_Band=0.00320;
         break;

      case 60:
         InpSTDV_Band=0.00517;
         break;

      case 240:
         InpSTDV_Band=0.00818;
         break;

     }

//--- 1 additional buffer used for counting.
   IndicatorBuffers(5);
   IndicatorDigits(Digits);
//--- middle line
   if(InpBandsPeriod==47)
      SetIndexStyle(0,DRAW_LINE,EMPTY,EMPTY,clrDarkOrange);
   else
      SetIndexStyle(0,DRAW_LINE,EMPTY,2,clrLightPink);
   SetIndexBuffer(0,ExtMovingBuffer);
   SetIndexShift(0,InpBandsShift);
   SetIndexLabel(0,"Bands SMA");
//--- uplevel_1 band
   if(InpBandsPeriod==47)
      SetIndexStyle(1,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrDarkOrange);
   else
      SetIndexStyle(1,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrLightPink);
   SetIndexBuffer(1,ExtUpLevel_1Buffer);
   SetIndexShift(1,InpBandsShift);
   SetIndexLabel(1,"UpLevel_1 STDV Bands");
//--- lowlevel_1 band
   if(InpBandsPeriod==47)
      SetIndexStyle(2,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrDarkOrange);
   else
      SetIndexStyle(2,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrLightPink);
   SetIndexBuffer(2,ExtLowLevel_1Buffer);
   SetIndexShift(2,InpBandsShift);
   SetIndexLabel(2,"LowLevel_1 STDV Bands");
//--- uplevel_2 band
   if(InpBandsPeriod==47)
      SetIndexStyle(3,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrDarkOrange);
   else
      SetIndexStyle(3,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrLightPink);
   SetIndexBuffer(3,ExtUpLevel_2Buffer);
   SetIndexShift(3,InpBandsShift);
   SetIndexLabel(3,"UpLevel_2 STDV Bands");
//--- lowlevel_2 band
   if(InpBandsPeriod==47)
      SetIndexStyle(4,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrDarkOrange);
   else
      SetIndexStyle(4,DRAW_LINE,STYLE_DASHDOT,EMPTY,clrLightPink);
   SetIndexBuffer(4,ExtLowLevel_2Buffer);
   SetIndexShift(4,InpBandsShift);
   SetIndexLabel(4,"LowLevel_2 STDV Bands");
//--- work buffer
//SetIndexBuffer(3,ExtStdDevBuffer);
//--- check for input parameter
   if(InpBandsPeriod<=0)
     {
      Print("Wrong input parameter Bands Period=",InpBandsPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(1,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(2,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(3,InpBandsPeriod+InpBandsShift);
   SetIndexDrawBegin(4,InpBandsPeriod+InpBandsShift);
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
   if(rates_total<=InpBandsPeriod || InpBandsPeriod<=0)
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
      for(i=0; i<InpBandsPeriod; i++)
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
      ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,close);
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
