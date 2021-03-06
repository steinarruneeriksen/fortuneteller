//+------------------------------------------------------------------+
//|                                       BlackSwan_ForexInclude.mq4 |
//|                                      Copyright © 2010, Blackswan |
//|                                          http://www.blackswan.no |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Blackswan"
#property link      "http://www.blackswan.no"
 
#define SESSION_LONDON 1
#define SESSION_NEWYORK 2
#define SESSION_TOKYO 3

#define SESSION_GMTOPEN_LONDON 7 
#define SESSION_GMTCLOSE_LONDON 15
#define SESSION_GMTOPEN_NEWYORK 12
#define SESSION_GMTCLOSE_NEWYORK 20
#define SESSION_GMTOPEN_TOKYO 23
#define SESSION_GMTCLOSE_TOKYO 7

int Crossing(double line1, double line1prev,double line2, double line2prev){
   
   if (line1<line2 && line1prev>=line2prev)
      return(-1);  // Descending across line 2
      
   if (line1>line2 && line1prev<=line2prev)
      return(1);  // Ascending across line 2
   return (0);
}


// -1 if bear trend, 1 if bull and 0 if range. periods are number of bars inside stddev1 and stddev 2 in the trend band
int CheckBollingerTrend(int periods){
   double checkBand=iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_MAIN,periods+2);
   double checkBand2=iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_MAIN,periods+3);
   int counter=0;
   bool trend=true;
   for( counter = 1; counter<= periods; counter++){
     double value= iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_LOWER,counter);
     double valueWider= iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,counter);
     if (iClose(NULL,0,counter)>value || iOpen(NULL,0,counter)>value || iHigh(NULL,0,counter)>value){
         trend=false;    
      }         

   }      
   if (trend==true){
      if (iClose(NULL,0,periods+2)>checkBand || iClose(NULL,0,periods+3)>checkBand2)
         return (-1);  
      else
         return (0);
   }    
   trend=true;
   for(counter = 1; counter<= periods; counter++){
     double value= iBands(NULL,0,20,1,0,PRICE_CLOSE,MODE_UPPER,counter);
     double valueWider= iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,counter);
     if (iClose(NULL,0,counter)<value || iOpen(NULL,0,counter)<value  || iLow(NULL,0,counter)<value){
      trend=false;    
      }
   }
   if (trend==true){
      if (iClose(NULL,0,periods+2)<checkBand || iClose(NULL,0,periods+3)<checkBand2)
         return (1);  
      else
         return (0);
   } 
   return (0);     
}



bool IsWithinRange(double value, double target, double range){
  // Print("Check IsWithinRange value, target, range "+  value + " " + target + " " + range);
   if (value>(target-range) && value<(target+range)){
      return (true);
   }
   return (false);
}

bool IsStartOfBar(datetime Timestamp,datetime Prevtimestamp, int BarType){
   
   int iBarCurrent = TimeHour(Timestamp);   
   int iBarPrevious = TimeHour(Prevtimestamp);  
   datetime test=iTime(Symbol(),BarType, 0);
   int iBarTarget=TimeHour(test); 
   Print("Currc:" + TimeToStr(Timestamp, TIME_DATE|TIME_SECONDS) +",prev:" + TimeToStr(Prevtimestamp, TIME_DATE|TIME_SECONDS) +", Bar:" + TimeToStr(test,TIME_DATE|TIME_SECONDS) );
   Print("CurrBar:" + iBarCurrent +",prev:" + iBarPrevious +", Bar:" + iBarTarget);
 
  
   if (iBarPrevious<iBarTarget && iBarCurrent>=iBarTarget){
         Print("Entering new bar");
         return (true);
   }
   return (false);
}


bool IsStartOfSession(datetime timestamp,datetime prevtimestamp, int session){
   int iBarHour = TimeHour(timestamp);   
   int iBarPrevHour = TimeHour(prevtimestamp);  
   //Print("iBarHour " + iBarHour + " iBarPrevHour " + iBarPrevHour);
   if (session==SESSION_LONDON){
      if (iBarPrevHour<SESSION_GMTOPEN_LONDON && iBarHour>=SESSION_GMTOPEN_LONDON)
         return (true);
   }
   if (session==SESSION_NEWYORK){
      if (iBarPrevHour<SESSION_GMTOPEN_NEWYORK && iBarHour>=SESSION_GMTOPEN_NEWYORK)
         return (true);
   }
   return (false);
}

string GetTimeframeStr(int Timeframe){

   string res="";
   if (Timeframe==PERIOD_M5)
      res="M5";
    else if (Timeframe==PERIOD_M15)
      res="M15";
    else if (Timeframe==PERIOD_M30)
      res="M30";
    else if (Timeframe==PERIOD_H1)
      res="H1";
    else if (Timeframe==PERIOD_H4)
      res="H4";
    else if (Timeframe==PERIOD_D1)
      res="D1";
   return (res);
}
int GetMajorTimeframe(int CurrentTimeFrame){

   int res=0;
   if (CurrentTimeFrame==PERIOD_M5)
      res=PERIOD_H1;
    else if (CurrentTimeFrame==PERIOD_M15)
      res=PERIOD_H4;
    else if (CurrentTimeFrame==PERIOD_M30)
      res=PERIOD_H4;
    else if (CurrentTimeFrame==PERIOD_H1)
      res=PERIOD_H4;
    else if (CurrentTimeFrame==PERIOD_H4)
      res=PERIOD_D1;
    else if (CurrentTimeFrame==PERIOD_D1)
      res=PERIOD_W1;
   return (res);
}
double GetPipPoint(string Currency){
double CalcPoint=0;
   int CalcDigits = MarketInfo(Currency, MODE_DIGITS);
   if (CalcDigits==2 || CalcDigits == 3)  CalcPoint = 0.01;
   else if (CalcDigits==4 || CalcDigits == 5)  CalcPoint = 0.0001;
   
   return(CalcPoint);
}


int GetSlippage(string Currency, int SlippagePips){
double CalcSlippage=0;
   int CalcDigits = MarketInfo(Currency, MODE_DIGITS);
   if (CalcDigits==2 || CalcDigits == 3)  CalcSlippage = SlippagePips;
   else if (CalcDigits==4 || CalcDigits == 5)  CalcSlippage = SlippagePips*10;
   return(CalcSlippage);
}

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2005

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);

// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import

//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex4"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+