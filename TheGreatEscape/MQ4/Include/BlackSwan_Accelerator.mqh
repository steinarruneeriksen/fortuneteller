//+------------------------------------------------------------------+
//|                                        BlackSwan_Accelerator.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


double AcceleratorMax=0;
double AcceleratorRatio=0;
double AcceleratorLast=0;
double AcceleratorPrev=0;

void UpdateAccelerator(){
   double AcceleratorLast=iAC(NULL, 0, 0);
   double AcceleratorPrev=iAC(NULL, 0, 1);
   if (MathAbs(AcceleratorLast)>AcceleratorMax){
      AcceleratorMax=MathAbs(AcceleratorLast);         
   }  
   AcceleratorRatio=MathAbs(AcceleratorLast)/AcceleratorMax;
}



int CalcAcceleration(int timeFrame, int periods){

   double value=iAC(NULL, timeFrame, periods-1);
   double valueLast=iAC(NULL, timeFrame, periods-2);
   double temp=0;int i=0;
   if (value<valueLast && value<0){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAC(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
 
      }   
      
      if ((value<0 && valueLast<0))
         return (-1);
   }else if (value>valueLast && value>0){
   
      for (i=(periods-3);i>=0;i--){
         temp=iAC(NULL, timeFrame, i);
         if (temp<valueLast)
            return (0);
         valueLast=temp;
      }   
      if ((value>0 && valueLast>0))
      return (1);   
   
   }   
return (0);
}



int CalcAcceleratorColor(int timeFrame, int periods){

   double value=iAC(NULL, timeFrame, periods-1);
   double valueLast=iAC(NULL, timeFrame, periods-2);
   double temp=0;int i=0;
   if (valueLast>value){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (valueLast>temp)
            return (0);
         valueLast=temp;
      }   

         return (1);
   }else{
   
      for (i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
      }   

      return (-1);   
   
   }   
return (0);
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