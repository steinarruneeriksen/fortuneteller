//+------------------------------------------------------------------+
//|                                            BlackSwan_Awesome.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


double AwesomeMax=0;
double AwesomeRatio=0;
double AwesomeLast=0;
double AwesomePrev=0;
double AwesomePrev2=0;

void UpdateAwesome(){
   AwesomeLast=iAO(NULL, 0, 0);
   AwesomePrev=iAO(NULL, 0, 1);
   AwesomePrev2=iAO(NULL, 0, 2);
   if (MathAbs(AwesomeLast)>AwesomeMax){
      AwesomeMax=MathAbs(AwesomeLast);         
   }  
   AwesomeRatio=MathAbs(AwesomeLast)/AwesomeMax;
}


bool SimpleCross(double prev, double current){
   if (prev<0 && current>0)
      return (true);
   if (prev>0 && current<0)
      return (true);
  return (false);
}




int CalcAwesomeCrossShiftInPeriods(int timeFrame, int periods){
   int count=0;
   double value=iAO(NULL, timeFrame, periods-1);
   double valueLast=iAO(NULL, timeFrame, periods-2);
   
   if (SimpleCross(value, valueLast))
      count=count+1;
  int i=0;   
   double temp=0;
   if (valueLast>value){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (valueLast>temp)
            return (0);
         if (count>0)
            count=count+1;   
         else if (SimpleCross(valueLast, temp))
            count=1;
         valueLast=temp;
      }   

      if (value<0 && valueLast>0)
         return (count);
   }else{
   
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         if (count>0)
            count=count+1;   
         else if (SimpleCross(valueLast, temp))
            count=1;
         valueLast=temp;
      }   
      if (value>0 && valueLast<0)
      return (-count);   
   
   }   
return (0);
}



int CalcAwesomeCrosser(int timeFrame, int periods){
   double first=iAO(NULL, timeFrame, periods-1);
   double second=iAO(NULL, timeFrame, periods-2);
   double last=iAO(NULL, timeFrame, 0);
   if (last<0 && second>=0 && first>second)
      return (-1);
   if (last>0 && second<=0 && first<second)
      return (1);
return (0);
}

int CalcAwesomeCrossShift(int timeFrame, int periods){
   double value=iAO(NULL, timeFrame, periods-1);
   double valueLast=iAO(NULL, timeFrame, periods-2);
   double temp=0;int i=0;
   if (valueLast>value){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (valueLast>temp)
            return (0);
         valueLast=temp;
      }   
      if (((value<0 ) && valueLast>0)&& (AwesomeRatio>0.05 && AwesomeRatio<0.15))
         return (1);
   }else{
   
      for (i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
      }   
      if (((value>0)&& valueLast<0)&& (AwesomeRatio>0.05 && AwesomeRatio<0.15))
      return (-1);   
   
   }   
return (0);
}



int CalcAwesomeColor(int timeFrame, int periods){

   double value=iAO(NULL, timeFrame, periods-1);
   double valueLast=iAO(NULL, timeFrame, periods-2);
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


int CalcAwesomeTopBottomShift(int timeFrame, int periods, bool strict){

   double value=iAO(NULL, timeFrame, periods-1);
   double valueLast=iAO(NULL, timeFrame, periods-2);
   double temp=0;int i=0;
   if (value<valueLast){
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
      }   
      return (-1);
   }else{
   
      for (i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp<valueLast)
            return (0);
         valueLast=temp;
      }   
      return (1);   
   }   
return (0);
}

int CalcAwesomeTrendShift(int timeFrame, int periods, bool strict){

   double value=iAO(NULL, timeFrame, periods-1);
   //Print("1:" + value);
   double valueLast=iAO(NULL, timeFrame, periods-2);
   //Print("2:" + valueLast);
   double temp=0;
   int i=0;
   if (value<valueLast){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
        // Print("3:" + valueLast);
      }   
      
      if (((value>0 && valueLast<0) || (strict==false))&& (AwesomeRatio>0.05 && AwesomeRatio<0.2))
         return (-1);
   }else{
   
      for (i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp<valueLast)
            return (0);
         valueLast=temp;
      }   
      if (((value<0 && valueLast>0)|| (strict==false))&& (AwesomeRatio>0.05 && AwesomeRatio<0.2))
      return (1);   
   
   }   
return (0);
}

int CalcAwesomeSaucer(int timeFrame, int periods){

   double value=iAO(NULL, timeFrame, periods-1);
   double valueLast=iAO(NULL, timeFrame, periods-2);
   double temp=0;
   int i=0;
   if (value<valueLast){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
 
      }   
      
      if ((value<0 && valueLast<0)&& (MathAbs(value)<(2*MathAbs(valueLast))))
         return (-1);
   }else{
   
      for (i=(periods-3);i>=0;i--){
         temp=iAO(NULL, timeFrame, i);
         if (temp<valueLast)
            return (0);
         valueLast=temp;
      }   
      if ((value>0 && valueLast>0) && (MathAbs(value)<(2*MathAbs(valueLast))))
      return (1);   
   
   }   
return (0);
}

int CalcAccelSaucer(int timeFrame, int periods){

   double value=iAC(NULL, timeFrame, periods-1);
   double valueLast=iAC(NULL, timeFrame, periods-2);
   double temp=0;int i=0;
   if (value<valueLast){
      
      for ( i=(periods-3);i>=0;i--){
         temp=iAC(NULL, timeFrame, i);
         if (temp>valueLast)
            return (0);
         valueLast=temp;
 
      }   
      
      if ((value<0 && valueLast<0)&& (MathAbs(value)<(2*MathAbs(valueLast))))
         return (-1);
   }else{
   
      for (i=(periods-3);i>=0;i--){
         temp=iAC(NULL, timeFrame, i);
         if (temp<valueLast)
            return (0);
         valueLast=temp;
      }   
      if ((value>0 && valueLast>0) && (MathAbs(value)<(2*MathAbs(valueLast))))
      return (1);   
   
   }   
return (0);
}

int DetectAwesomeIncrease(){
  
   double ratio1=MathAbs(AwesomePrev2)/AwesomeMax;   
   double ratio2=MathAbs(AwesomePrev)/AwesomeMax; 
   double ratio3=MathAbs(AwesomeLast)/AwesomeMax; 
   double v3=AwesomePrev2;   
   double v2=AwesomePrev; 
   double v1=AwesomeLast;
   //Print("V1=" + v1 + " V2=" + v2 + " V3=" + v3); 
   double diff=0.5;
   //Print("(v2*(1+diff)=" + (v2*(1+diff)) + " v3*(1+diff)=" + (v3*(1+diff)) + " (v1*(1+diff))=" + (v1*(1+diff)));
   if (v3>(v2*(1+diff)) && (v2>((1+diff)*v1)) && v1>0)
      return (-1);
   if (v3<(v2*(1+diff)) && (v2<((1+diff)*v1)) && v1<0)
      return (1);
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