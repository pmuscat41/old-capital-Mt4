//+------------------------------------------------------------------+
//|                                       Camarilla indicator v1.mq4 |
//|                                      Copyright 2022, Paul Muscat |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Paul Muscat"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
extern color StandardFontColor = White;
extern int StandardFontSize = 8;

// global variables


double High_3=iHigh(Symbol(),PERIOD_D1, 3);
double Low_3=iLow(Symbol(),PERIOD_D1,3);
double Close_3=iClose (Symbol(),PERIOD_D1,3);
double Range_3=High_3-Low_3; 

double High_2=iHigh(Symbol(),PERIOD_D1, 2);
double Low_2=iLow(Symbol(),PERIOD_D1,2);
double Close_2=iClose (Symbol(),PERIOD_D1,2);
double Range_2=High_2-Low_2; 

double High_1=iHigh(Symbol(),PERIOD_D1, 1);
double Low_1=iLow(Symbol(),PERIOD_D1,1);
double Close_1=iClose (Symbol(),PERIOD_D1,1);
double Range_1=High_1-Low_1; 

double High_0=iHigh(Symbol(),PERIOD_D1, 0);
double Low_0=iLow(Symbol(),PERIOD_D1,0);
double Close_0=iClose (Symbol(),PERIOD_D1,0);
double Range_0=High_0-Low_0; 











//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {



 
 
 ObjectDelete (0,"H5_3");
ObjectDelete (0,"H5_3 label");

ObjectDelete (0,"H4_3");
ObjectDelete (0,"H4_3 label");
 

ObjectDelete (0,"H3_3");
ObjectDelete (0,"H3_3 label");

ObjectDelete (0,"L3_3");
ObjectDelete (0,"L3_3 label");


ObjectDelete (0,"L4_3");
ObjectDelete (0,"L4_3 label");



ObjectDelete (0,"L5_3");
ObjectDelete (0,"L5_3 label");
 
ObjectDelete (0,"H5_2");
ObjectDelete (0,"H5_2 label");

ObjectDelete (0,"H4_2");
ObjectDelete (0,"H4_2 label");
 

ObjectDelete (0,"H3_2");
ObjectDelete (0,"H3_2 label");

ObjectDelete (0,"L3_2");
ObjectDelete (0,"L3_2 label");


ObjectDelete (0,"L4_2");
ObjectDelete (0,"L4_2 label");



ObjectDelete (0,"L5_2");
ObjectDelete (0,"L5_2 label");



////////


ObjectDelete (0,"H5_1");
ObjectDelete (0,"H5_1 label");

ObjectDelete (0,"H4_1");
ObjectDelete (0,"H4_1 label");
 

ObjectDelete (0,"H3_1");
ObjectDelete (0,"H3_1 label");

ObjectDelete (0,"L3_1");
ObjectDelete (0,"L3_1 label");


ObjectDelete (0,"L4_1");
ObjectDelete (0,"L4_1 label");



ObjectDelete (0,"L5_1");
ObjectDelete (0,"L5_1 label");

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

      

 if (!newBar()) return;  //only trade on new bar

// global variables

double High_3,Low_3,Close_3,Range_3,High_2,Low_2, Close_2, Range_2, High_1,Low_1,Close_1,Close_0;








if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,3)) !=0)

{
 High_3=iHigh(Symbol(),PERIOD_D1, 3);
 Low_3=iLow(Symbol(),PERIOD_D1,3);
 Close_3=iClose (Symbol(),PERIOD_D1,3);
 Range_3=High_3-Low_3; }

else


{
 High_3=iHigh(Symbol(),PERIOD_D1, 4);
 Low_3=iLow(Symbol(),PERIOD_D1,4);
 Close_3=iClose (Symbol(),PERIOD_D1,4);
 Range_3=High_3-Low_3; }




if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,2)) !=0)
 {
  High_2=iHigh(Symbol(),PERIOD_D1, 2);
  Low_2=iLow(Symbol(),PERIOD_D1,2);
  Close_2=iClose (Symbol(),PERIOD_D1,2);
  Range_2=High_2-Low_2;
  } 
else

 {
  High_2=iHigh(Symbol(),PERIOD_D1, 3);
  Low_2=iLow(Symbol(),PERIOD_D1,3);
  Close_2=iClose (Symbol(),PERIOD_D1,3);
  Range_2=High_2-Low_2;
  } 


if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,1)) !=0)
{
  High_1=iHigh(Symbol(),PERIOD_D1, 1);
  Low_1=iLow(Symbol(),PERIOD_D1,1);
  Close_1=iClose (Symbol(),PERIOD_D1,1);
  Range_1=High_1-Low_1; 
}

else

{
  High_1=iHigh(Symbol(),PERIOD_D1, 2);
  Low_1=iLow(Symbol(),PERIOD_D1,2);
  Close_1=iClose (Symbol(),PERIOD_D1,2);
  Range_1=High_1-Low_1; 
}



if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,1)) !=0)

  { High_0=iHigh(Symbol(),PERIOD_D1, 0);
  Low_0=iLow(Symbol(),PERIOD_D1,0);
  Close_0=iClose (Symbol(),PERIOD_D1,0);
  Range_0=High_0-Low_0;}
  
  else
  
   
  { High_0=iHigh(Symbol(),PERIOD_D1, 1);
  Low_0=iLow(Symbol(),PERIOD_D1,1);
  Close_0=iClose (Symbol(),PERIOD_D1,1);
  Range_0=High_0-Low_0;}








      
      
//Pivots for day 3
   double H5_3= (High_3/Low_3)*Close_3;
   double H4_3= Close_3+(Range_3*1.1/2);
   double H3_3= Close_3+(Range_3*1.1/4);
   double H2_3= Close_3+(Range_3*1.1/6);
   double H1_3= Close_3+(Range_3*1.1/12);

   double L1_3= Close_3-(Range_3*1.1/12);
   double L2_3= Close_3-(Range_3*1.1/6);
   double L3_3= Close_3-(Range_3*1.1/4);
   double L4_3= Close_3-(Range_3*1.1/2);
   double L5_3= Close_3-(H5_3-Close_3);

   
   

//Pivots for day 2
   double H5_2= (High_2/Low_2)*Close_2;
   double H4_2= Close_2+(Range_2*1.1/2);
   double H3_2= Close_2+(Range_2*1.1/4);
   double H2_2= Close_2+(Range_2*1.1/6);
   double H1_2= Close_2+(Range_2*1.1/12);

   double L1_2= Close_2-(Range_2*1.1/12);
   double L2_2= Close_2-(Range_2*1.1/6);
   double L3_2= Close_2-(Range_2*1.1/4);
   double L4_2= Close_2-(Range_2*1.1/2);
   double L5_2= Close_2-(H5_2-Close_2);


//Pivots for day 1
     
   double H5_1= (High_1/Low_1)*Close_1;
   double H4_1= Close_1+(Range_1*1.1/2);
   double H3_1= Close_1+(Range_1*1.1/4);
   double H2_1= Close_1+(Range_1*1.1/6);
   double H1_1= Close_1+(Range_1*1.1/12);

   double L1_1= Close_1-(Range_1*1.1/12);
   double L2_1= Close_1-(Range_1*1.1/6);
   double L3_1= Close_1-(Range_1*1.1/4);
   double L4_1= Close_1-(Range_1*1.1/2);
   double L5_1= Close_1- (H5_1-Close_1);


//Pivots for day 0
  
   double H5_0= (High_0/Low_0)*Close_0;
   double H4_0= Close_0+(Range_0*1.1/2);
   double H3_0= Close_0+(Range_0*1.1/4);
   double H2_0= Close_0+(Range_0*1.1/6);
   double H1_0= Close_0+(Range_0*1.1/12);

   double L1_0= Close_0-(Range_0*1.1/12);
   double L2_0= Close_0-(Range_0*1.1/6);
   double L3_0= Close_0-(Range_0*1.1/4);
   double L4_0= Close_0-(Range_0*1.1/2);
   double L5_0= Close_0= (H5_0-Close_0);
 
//---- exit if period is greater than daily charts
if(Period() > 1440)
      {     
         Print("Error - Chart period is greater than 1 day.");
         return; // then exit   
      }
 
 //  CLEAR ALL OLD DRAWINGS
 
 
 
 ObjectDelete (0,"H5_3");
ObjectDelete (0,"H5_3 label");

ObjectDelete (0,"H4_3");
ObjectDelete (0,"H4_3 label");
 

ObjectDelete (0,"H3_3");
ObjectDelete (0,"H3_3 label");

ObjectDelete (0,"L3_3");
ObjectDelete (0,"L3_3 label");


ObjectDelete (0,"L4_3");
ObjectDelete (0,"L4_3 label");



ObjectDelete (0,"L5_3");
ObjectDelete (0,"L5_3 label");



////////
ObjectDelete (0,"H5_2");
ObjectDelete (0,"H5_2 label");

ObjectDelete (0,"H4_2");
ObjectDelete (0,"H4_2 label");
 

ObjectDelete (0,"H3_2");
ObjectDelete (0,"H3_2 label");

ObjectDelete (0,"L3_2");
ObjectDelete (0,"L3_2 label");


ObjectDelete (0,"L4_2");
ObjectDelete (0,"L4_2 label");



ObjectDelete (0,"L5_2");
ObjectDelete (0,"L5_2 label");



////////


ObjectDelete (0,"H5_1");
ObjectDelete (0,"H5_1 label");

ObjectDelete (0,"H4_1");
ObjectDelete (0,"H4_1 label");
 

ObjectDelete (0,"H3_1");
ObjectDelete (0,"H3_1 label");

ObjectDelete (0,"L3_1");
ObjectDelete (0,"L3_1 label");


ObjectDelete (0,"L4_1");
ObjectDelete (0,"L4_1 label");



ObjectDelete (0,"L5_1");
ObjectDelete (0,"L5_1 label");

//////
//////-------------------------------------------
//////




   ///  Draw lines Day 3 (DAY BEFORE YESTERDAY)
datetime linestart;
datetime lineend;
   
      if(ObjectFind("H5_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
             
            ObjectCreate ("H5_3",OBJ_TREND,0,
            linestart,H5_3, 
            lineend,H5_3);
            ObjectSetInteger(0,"H5_3",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_3",OBJPROP_RAY_RIGHT, false);
      
         }
         
      if(ObjectFind("H5_3 label") != 0)
      {
      ObjectCreate("H5_3 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,2), H5_3);
      ObjectSetText("H5_3 label", " H5_3", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("H4_3",OBJ_TREND,0,
            linestart,H4_3, 
            lineend,H4_3);
            ObjectSetInteger(0,"H4_3",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_3 label") != 0)
      {
      ObjectCreate("H4_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), H4_3);
      ObjectSetText("H4_3 label", " H4_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("H3_3",OBJ_TREND,0,
            linestart,H3_3, 
            lineend,H3_3);
            ObjectSetInteger(0,"H3_3",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_3 label") != 0)
      {
      ObjectCreate("H3_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), H3_3);
      ObjectSetText("H3_3 label", " H3_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("L3_3",OBJ_TREND,0,
            linestart,L3_3, 
            lineend,L3_3);
            ObjectSetInteger(0,"L3_3",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_3 label") != 0)
      {
      ObjectCreate("L3_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), L3_3);
      ObjectSetText("L3_3 label", " L3_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("L4_3",OBJ_TREND,0,
            linestart,L4_3, 
            lineend,L4_3);
            ObjectSetInteger(0,"L4_3",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_3 label") != 0)
      {
      ObjectCreate("L4_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), L4_3);
      ObjectSetText("L4_3 label", " L4_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("L5_3",OBJ_TREND,0,
            linestart,L5_3, 
            lineend,L5_3);
            ObjectSetInteger(0,"L5_3",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_3 label") != 0)
      {
      ObjectCreate("L5_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), L5_3);
      ObjectSetText("L5_3 label", " L5_3", StandardFontSize, "Arial", StandardFontColor);
      }






   ///  Draw lines Day 2 (YESTERDAY)
 
   
Comment ("H5_2 = ", H5_2,"\nH4_2= " ,H4_2);

      if(ObjectFind("H5_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
             
            ObjectCreate ("H5_2",OBJ_TREND,0,
            linestart,H5_2, 
            lineend,H5_2);
            ObjectSetInteger(0,"H5_2",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_2",OBJPROP_RAY_RIGHT, false);
      
         }
         
      if(ObjectFind("H5_2 label") != 0)
      {
      ObjectCreate("H5_2 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,1), H5_2);
      ObjectSetText("H5_2 label", " H5_2", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("H4_2",OBJ_TREND,0,
            linestart,H4_2, 
            lineend,H4_2);
            ObjectSetInteger(0,"H4_2",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_2 label") != 0)
      {
      ObjectCreate("H4_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), H4_2);
      ObjectSetText("H4_2 label", " H4_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("H3_2",OBJ_TREND,0,
            linestart,H3_2, 
            lineend,H3_2);
            ObjectSetInteger(0,"H3_2",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_2 label") != 0)
      {
      ObjectCreate("H3_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), H3_2);
      ObjectSetText("H3_2 label", " H3_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("L3_2",OBJ_TREND,0,
            linestart,L3_2, 
            lineend,L3_2);
            ObjectSetInteger(0,"L3_2",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_2 label") != 0)
      {
      ObjectCreate("L3_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), L3_2);
      ObjectSetText("L3_2 label", " L3_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("L4_2",OBJ_TREND,0,
            linestart,L4_2, 
            lineend,L4_2);
            ObjectSetInteger(0,"L4_2",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_2 label") != 0)
      {
      ObjectCreate("L4_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), L4_2);
      ObjectSetText("L4_2 label", " L4_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("L5_2",OBJ_TREND,0,
            linestart,L5_2, 
            lineend,L5_2);
            ObjectSetInteger(0,"L5_2",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_2 label") != 0)
      {
      ObjectCreate("L5_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), L5_2);
      ObjectSetText("L5_2 label", " L5_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
  
  
  
   ///  Draw lines Day 1 (TODAY)

   
Comment ("H5_1 = ", NormalizeDouble(H5_1,Digits),
         "\nH4_1= " ,NormalizeDouble(H4_1,Digits),
         "\nH3_1= " ,NormalizeDouble(H3_1,Digits),
         "\nL3_1= " ,NormalizeDouble(L3_1,Digits),
         "\nL4_1= " ,NormalizeDouble (L4_1, Digits),
         "\nL5_1= " ,NormalizeDouble(L5_1,Digits));
        

      if(ObjectFind("H5_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime(Symbol(),PERIOD_D1,0)+ Time[10];
             
            ObjectCreate ("H5_1",OBJ_TREND,0,
            linestart,H5_1, 
            lineend,H5_1);
            ObjectSetInteger(0,"H5_1",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_1",OBJPROP_RAY_RIGHT, true);
      
         }
         
      if(ObjectFind("H5_1 label") != 0)
      {
      ObjectCreate("H5_1 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,0), H5_1);
      ObjectSetText("H5_1 label", " H5_1", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime(Symbol(),PERIOD_D1,0)+Time[10];
            ObjectCreate ("H4_1",OBJ_TREND,0,
            linestart,H4_1, 
            lineend,H4_1);
            ObjectSetInteger(0,"H4_1",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_1",OBJPROP_RAY_RIGHT, true);
      
         }
     
      if(ObjectFind("H4_1 label") != 0)
      {
      ObjectCreate("H4_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), H4_1);
      ObjectSetText("H4_1 label", " H4_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime(Symbol(),PERIOD_D1,0)+Time[10];
            ObjectCreate ("H3_1",OBJ_TREND,0,
            linestart,H3_1, 
            lineend,H3_1);
            ObjectSetInteger(0,"H3_1",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_1",OBJPROP_RAY_RIGHT, true);
      
         }
     
      if(ObjectFind("H3_1 label") != 0)
      {
      ObjectCreate("H3_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), H3_1);
      ObjectSetText("H3_1 label", " H3_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime(Symbol(),PERIOD_D1,0)+Time[10];
            ObjectCreate ("L3_1",OBJ_TREND,0,
            linestart,L3_1, 
            lineend,L3_1);
            ObjectSetInteger(0,"L3_1",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_1",OBJPROP_RAY_RIGHT, true);
      
         }
     
      if(ObjectFind("L3_1 label") != 0)
      {
      ObjectCreate("L3_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), L3_1);
      ObjectSetText("L3_1 label", " L3_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime(Symbol(),PERIOD_D1,0)+Time[10];
            ObjectCreate ("L4_1",OBJ_TREND,0,
            linestart,L4_1, 
            lineend,L4_1);
            ObjectSetInteger(0,"L4_1",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_1",OBJPROP_RAY_RIGHT, true);
      
         }
     
      if(ObjectFind("L4_1 label") != 0)
      {
      ObjectCreate("L4_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), L4_1);
      ObjectSetText("L4_1 label", " L4_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime(Symbol(),PERIOD_D1,0)+Time[10];
            ObjectCreate ("L5_1",OBJ_TREND,0,
            linestart,L5_1, 
            lineend,L5_1);
            ObjectSetInteger(0,"L5_1",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_1",OBJPROP_RAY_RIGHT, true);
      
         }
     
      if(ObjectFind("L5_1 label") != 0)
      {
      ObjectCreate("L5_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), L5_1);
      ObjectSetText("L5_1 label", " L5_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
  
  
  
  
  
  
  
 } 
//+------------------------------------------------------------------+





bool newBar(){

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result =      (currentTime!=priorTime); //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
   }
   