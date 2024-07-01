//+------------------------------------------------------------------+
//|                                                        Bands.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "STDV Bands of MA"
#property strict
#property version  "2.00"

//#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 15
//#property indicator_color1 color=DarkOrange
/*enum ENUM_price_type
{
 Enum_close,
 Enum_open,
 Enum_high,
 Enum_low,
};*/
//--- indicator parameters
int    InpPeriod=47;      // Bands Period
input double InpSTDV_Band=0.0005;        // Band STDV
input ENUM_APPLIED_PRICE InpPriceType=PRICE_CLOSE;
input  color Inpcolor=clrDarkOrange;
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=1.0; // Bands Deviations
//--- buffers
double ExtMA_7[];
double ExtUpLevel_1_MA_7[];
double ExtLowLevel_1_MA_7[];
double ExtUpLevel_2_MA_7[];
double ExtLowLevel_2_MA_7[];

double ExtMA_29[];
double ExtUpLevel_1_MA_29[];
double ExtLowLevel_1_MA_29[];
double ExtUpLevel_2_MA_29[];
double ExtLowLevel_2_MA_29[];

double ExtMA_47[];
double ExtUpLevel_1_MA_47[];
double ExtLowLevel_1_MA_47[];
double ExtUpLevel_2_MA_47[];
double ExtLowLevel_2_MA_47[];

const string symbol="EURUSD";
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
   int i,limit;

//---
   if(rates_total<=InpPeriod || InpPeriod<=0)
      return(0);

//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
     {
      ExtMovingBuffer[i]=iMA(symbol,0,InpPeriod,0,MODE_SMA,InpPriceType,i);
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
