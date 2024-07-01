//+------------------------------------------------------------------+
//|                                       Differance Price to MA.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

input int TimeFrame=15;
input int MA_Period=7;

double now_close;
double now_ma;
uint shift_counter=0;
uint number_of_sampels=4700;


string refrence_diff = "MA";
string InpDirectoryName="TEST";        // Folder name 
const string symbol = "EURUSD";

//+------------------------------------------------------------------+
//|VAREABLES          |
//+------------------------------------------------------------------+
void VAREABLEs()
{
 now_close=iClose(symbol,TimeFrame,shift_counter);
 
 
 now_ma = iMA(symbol,TimeFrame,MA_Period,0,MODE_SMA,PRICE_CLOSE,shift_counter);
 now_ma = NormalizeDouble(now_ma,Digits);
//---
return;
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   while(number_of_sampels>0)
   {
    
    shift_counter++;
    VAREABLEs();
   
    double Diff_Price_to_MA = NormalizeDouble(now_ma - now_close,Digits);
    datetime time=iTime(symbol,TimeFrame,shift_counter);
    
    
    string InpFileName = StringFormat("DifPrice_MA%d_%d.csv",MA_Period,TimeFrame);
 
    int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
    
    if(file_handle!=INVALID_HANDLE) 
    { 
     //PrintFormat("%s file is available for writing",InpFileName); 
     //PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
     //--- first, write the number of signals
     FileSeek(file_handle,0,SEEK_END); 
     FileWrite(file_handle,time,Diff_Price_to_MA);   
     //--- close the file 
     FileClose(file_handle); 
     //PrintFormat("Data is written, %s file is closed",InpFileName); 
    } 
    else 
    {PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
     ERROR_SOUND_GEN();}
     
     number_of_sampels--;
  }
  
//---
   
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|SOUND GENERATOR                                 |
//+------------------------------------------------------------------+
void ERROR_SOUND_GEN()
{
 ResetLastError();
 
 if(!PlaySound("timeout.wav"))
   Print("Play sound failed! and error= ",GetLastError());
   
   Sleep(1500);
//---
return;   
}