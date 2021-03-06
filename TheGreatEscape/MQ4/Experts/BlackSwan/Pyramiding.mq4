//+------------------------------------------------------------------+
//|                                                   GridTrader.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Steinar R. Eriksen"
#property link          "http://www.blackswan.no"
#property version   "1.00"
#property strict

#include <BlackSwan/TradeHelper.mqh>
#include <BlackSwan/TrendSignals.mqh>

sinput string TradeSettings;    // Trade Settings
input int MagicNumber = 666;
input int Slippage = 10;
input int OrderSteps=5;
input double LotSize=0.1;
input bool TradeOnBarOpen = true;
input bool AutomaticClosing=false;


enum ENUM_GRIDTYPE
 { 
  DEFAULT= 1 , 
  TIGHT= 2 
 };
input ENUM_GRIDTYPE GridType=DEFAULT;


sinput string TrendSettings;    // Trend Settings
input int RegressionCount = 14;
input int RegressionStart=0;
input int  RegressionStop=5;
input bool CounterTrend=false;

input int MaxLosers=2;

sinput string MoneyManagement;    // MonMan Settings
input int BarsMaxOpenPending = 10;
input int BarsMaxOpenOrders = 10;
input double MaxOpenPos=2.0;

input int InitialStopPoints=500;
input int InitialProfPoints=200;

sinput string TrailingStopSettings;   	// Trailing Stop
input bool UseTrailingStop = true;
input int TrailingStop = 200;
input int MinProfit = 100;
input int Step = 10;
 
double UsePoint=0;
double BuyPos=0;
double SellPos=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Trade.SetMagicNumber(MagicNumber);
   Trade.SetSlippage(Slippage);
   UsePoint=GetPipPoint(Symbol());
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool newBar = true;
   int barShift = 0;
   
   if(TradeOnBarOpen == true)
   {
      newBar = NewBar.CheckNewBar(_Symbol,_Period);
      barShift = 1;
   }
   if(newBar == true)
   {


      
     // Print("BuyPos=", BuyPos, " SellPos=", SellPos);
     // Trade.CloseExpiredOrders(BarsMaxOpenOrders);
      //Trade.CloseExpiredPendingOrders(BarsMaxOpenPending);     
      BuyPos=GetOpenPos(Symbol(),OP_BUY,MagicNumber);
      SellPos=GetOpenPos(Symbol(),OP_SELL,MagicNumber); 
      int trend= CalcRegressionTrend( RegressionStart,  RegressionStop,  RegressionCount);
    //  if (Close[1]<Open[1]) trend=1; else trend=-1;
      
      if (MaxOpenPos==0 || (BuyPos<MaxOpenPos && SellPos<MaxOpenPos)){
      
            int losers=0;
            for(int order = 0; order <= OrdersTotal() - 1; order++)
            {
               OrderSelect(order,SELECT_BY_POS);
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber ){
                  if (OrderProfit()<0) losers+=1;
               }
            }
       //  double OpenProf=GetOpenProf(Symbol(), MagicNumber);
      // Print("Losers", losers);
         if (BuyPos>0){
            if (losers<MaxLosers)
             Trade.OpenBuyOrder(Symbol(), LotSize);
            else  Trade.CloseAllMarketOrders();
         }else if (SellPos>0){
        
            if (losers<MaxLosers)
             Trade.OpenSellOrder(Symbol(), LotSize);
            else  Trade.CloseAllMarketOrders();
         }else {
             if (trend>0) Trade.OpenBuyOrder(Symbol(), LotSize); else  Trade.OpenSellOrder(Symbol(), LotSize);
          }
         
      }
     
   }
   
   
   // Trailing stop
   if(UseTrailingStop == true)
   {
      TrailingStopAll(TrailingStop, MinProfit,Step);
   } 
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
