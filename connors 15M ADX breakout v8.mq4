//+------------------------------------------------------------------+
//|                                     connors 15M ADX breakout.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include  <MasterFile.mqh>
#include  <MasterFile 2.mqh>

input double   inHourtoTrade     = 8;// enter the hour to start trading
input double   inTP              = 0.005;// enter take profit
input double   inSL              = 0.005;// inp stoploss
input double   inpTarget         = 0.3;// enter factor to multiply average daily range for take profit
input bool     inpDynamicStops  = true;// Use dynamic trailing stops? T/F
input double   inpTrailFrom=    50;// Enter profit at which to start trailing
input double   inpOrderSize      =  0.3;  //Order size for each order
input double   inpMagicNumber    =  123; //Magic number
input string   inpTradeComments  =  "Connors 15M ADX breakout v8";  //Trade comment

int static ticket=0;
double SignalBarHigh;
double SignalBarLow;

bool shortsignal,tradelong;

bool longsignal;
static bool Notrade=true;
static bool SetTPSL=false;
 
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
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
 
 if (ticket>0)
 
 {
 /// manage trade 
 
 
 OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
 
 
 
 double TakeProfit= (GetAveragePeriodRange6(PERIOD_D1)*inpTarget);
 double BuyStop= SignalBarLow-inSL;
 double SellStop= SignalBarHigh+inSL;
 double BuyProfit= SignalBarHigh+TakeProfit+inTP;
 double SellProfit= SignalBarLow-TakeProfit+inTP;
 
 
 // when profit passes 100 - set SetTPSL to true- so that TP and SL is set.
 if (OrderProfit()>inpTrailFrom &&  SetTPSL==false) SetTPSL=true;
 
 if (inpDynamicStops==true && tradelong==false && SetTPSL == true) SetTPandTP (SellStop,SellProfit);
 if (inpDynamicStops==true && tradelong==true && SetTPSL == true) SetTPandTP (BuyStop,BuyProfit);
 
 if (inpDynamicStops==true && OrderProfit()>inpTrailFrom) DynamicTrailingStop (inpMagicNumber,ticket);
 
 if (tradelong==false && Ask >SellStop ) 
   
    {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Ask,15,Red);
       if (Closedeal==true) ticket=0; Notrade=true;}
      
     if ( tradelong==false   && Ask <SellProfit)
        {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Ask,15,Red);if (Closedeal==true) ticket=0;Notrade=true;SetTPSL=false;}
 
 
  if (tradelong==true && Bid<BuyStop) 
    {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Bid,15,Blue); if (Closedeal==true) ticket=0;Notrade=true;SetTPSL=false;}
      
      
 if (tradelong==true && Bid > BuyProfit)  
      {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Bid,15,Blue);if (Closedeal==true) ticket=0;Notrade=true;SetTPSL=false;}
 
 if (OrderCloseTime()!=0) {ticket=0;Notrade=true;SetTPSL=false;}
 
 return;
 
 }


 if (!newBar()) return;  //only trade on new bar
 
 
 datetime openbar= Time[1];
 
 int openhour= TimeHour (openbar);
 int openminute= TimeMinute(openbar);
 
 int sessionhour= inHourtoTrade;
 int sessionminute= 0;


if (openhour==sessionhour && openminute==sessionminute)
// then bar [1] is the first bar  

   {
   
   SignalBarHigh= iHigh(Symbol(),PERIOD_M15,1);
   SignalBarLow=iLow(Symbol(),PERIOD_M15,1);
   Notrade=false;
     
  ObjectCreate(1,"trigger",OBJ_ARROW,0,Time[1],SignalBarHigh);
  
   }


int ADX =iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN,1 );
double  b4plusdi = iADX(Symbol(),Period (), 14, PRICE_CLOSE, MODE_PLUSDI, 2);
double  nowplusdi = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_PLUSDI, 1);
double  b4minusdi = iADX(Symbol(), Period (), 14, PRICE_CLOSE, MODE_MINUSDI, 2);
double  nowminusdi = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MINUSDI, 1); 
   

if (nowplusdi>nowminusdi) longsignal=true; else longsignal=false;


if (nowplusdi<nowminusdi) shortsignal=true; else shortsignal=false;

if (longsignal==true && ticket==0&& ADX>30&& Ask>SignalBarHigh && Notrade==false) 

   {ticket=orderOpen(ORDER_TYPE_BUY,0,0,inpOrderSize,inpTradeComments,inpMagicNumber);tradelong=true;

}

if (shortsignal==true && ticket==0&& ADX>30&& Bid< SignalBarLow && Notrade==false )

 {ticket= orderOpen(ORDER_TYPE_SELL,0,0,inpOrderSize,inpTradeComments,inpMagicNumber);tradelong=false;

}
return;
     
    


   
  }
  
  
  
  
void SetTPandTP(double SL,double TP)

{

OrderModify(ticket,OrderOpenPrice(),NormalizeDouble (SL,Digits),NormalizeDouble (TP,Digits),0,0);
Print (" ___________________________________ SL = "+SL+"   TP=   "+ TP);
SetTPSL= false;
return;

}
//+------------------------------------------------------------------+


 
   
   