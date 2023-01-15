//+------------------------------------------------------------------+
//|                                              
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com
//|
///// Connors TPS system

//DEVELOPMENTS-

//still need to add error handling- check close and open trades for errors 
// add a section to enter a trade on init- but add a flag so it only enters the first time!!!! that 
/// way you can enter trades on the close and benefit from gap- up.
///
/// do some scanning for stock also as well as commodities
///
/// remember order is reverses so rank securites worst to best (at the end)

// corrected opening error

//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MasterFile.mqh>
#include <MasterFile 2.mqh>

/// RSI levels are from 0 -100, select levels for overbought and oversold
//  and the inputs to RSI

int                  inpRSIPeriods  =  2;               //RSI Periods

input ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price

input double inpPercentToRisk_=2;// enter percentage to risk per trade
input double inpMinCash= 200;//enter minimum cash to keep when trading

//The Levels

int               inpOversoldLevel  =  25.0;          // Oversold Level
int               inpOverboughtLevel=  75.0;          // Overbought Level

// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit

double               inpTakeProfit  =  0.00;     //Take Profit in currency value
double               inpStopLoss   =  0.00;     //Stop Loss in currecny value

///Standard inputs - you should have this in every EA

input int   inpTotalOrders    =  4; //Set total orders to open BETWEEN 2-5 NO MORE!!!!
input string   inpTradeComments  =  "Connors TPS  RSI 2 ver 6";  //Trade comment
input int   inpMagicNumber    = 0; //Magic number

double rsi,rsiYest;

   static int  ticket =0;



 static bool PreviousPriceshort=true;
   static bool PreviousPricelong=true;
   static bool oversold =  false;
   static bool overbought= false;
   static double direction= 1;
   static int lastTicket = -1;
   static int previousDirection =0;
   static int totalTicket=0;
   static bool OrderOk =true;
   static int closeLots=0;
   static bool twoDaysDown = false;
   int ticket2;
   
   
   
double inpOrderSize_;
double inpOrderSize;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


Print ("            ");
Print ("   ---------------------------------------------------------------------------------         ");
Print ("            ");




   ENUM_INIT_RETCODE result =  INIT_SUCCEEDED ;

   result =  checkInput();
   if(result!=INIT_SUCCEEDED)
      return(result);  //exit if inputs are bad

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
 


  

   if(!newBar())
      return;  //only trade on new bar


if (totalTicket==0) 
{
 inpOrderSize_= GetLotSize();
 inpOrderSize = inpOrderSize_;
 Alert ("CALCULATED ORDER SIZE FOR FIRST ORDER=  "+inpOrderSize); 
}

   double TwoHunMa = iMA(Symbol(),Period(),200,0,MODE_SMA, PRICE_CLOSE,0);

   if(iClose (Symbol(),PERIOD_D1,0)> TwoHunMa)
     {direction = 1;}
   else
     { direction = -1;}



    rsi     =  iRSI(Symbol(),Period(),inpRSIPeriods, inpRSIPrice,1);
    rsiYest     =  iRSI(Symbol(),Period(),inpRSIPeriods, inpRSIPrice,2);
overbought=false;
oversold=false;

Comment ("Rsi today "+ rsi+"  "+ "Rsi yest"+rsiYest);
Comment (inpOversoldLevel);
 
  if ((rsi>inpOverboughtLevel) && (rsiYest>inpOverboughtLevel))
     
         {overbought  = true;
         Print ("");
         Print ("overbought = true");
         Print ("overbought = true");
         Print ("");}       


      if ((rsi<inpOversoldLevel) && (rsiYest<inpOversoldLevel))
     
         {oversold  = true;
         Print ("");
         Print ("oversold = true");
         Print ("oversold = true");
         Print ("");}       




      
   Print ("total ticket= "+ totalTicket+ "inpTotal orders=  "+ inpTotalOrders+"       oversold = "+ oversold + "    overbought  = "+ overbought+  "   direction= " + direction + "    lastticket= " +lastTicket +" ticket="+ ticket+ " orderok?= "+ OrderOk);
      
  
  
  //// first order to open
  
  
     
      if( (totalTicket==0) && (oversold==true) && (direction>0) && (totalTicket<inpTotalOrders)  && (OrderOk==true))
       {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      oversold =  false; //Reset
      lastTicket = ticket;
      previousDirection= direction;
      totalTicket ++;
      inpOrderSize =inpOrderSize+inpOrderSize;
      return;
     }
   else
      if((totalTicket==0) && (overbought==true) &&(direction<0) && (totalTicket<inpTotalOrders) && (OrderOk==true))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         overbought = false;
         lastTicket= ticket;
         previousDirection=direction;
         totalTicket ++;
         inpOrderSize =inpOrderSize+inpOrderSize;
         return;
        }
   
   
  
  
  
  
  
  
  
  
   
  
  
  if (ticket>0) subsequentOrders();
  
  
   
    if((rsi >70) && (previousDirection >0) && (lastTicket>0))
     
     {
     
     Print("");
     Print("close order");
       
       
     for (int i=(OrdersTotal()-1);i>=0;i--)
     
    {
    
     if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
       Print ("false result in the loop - loop=" + i + "    total Ticket= " + totalTicket + "Order lots=  " + OrderLots());
      
      return;}
   
      else {
      double bidprice= MarketInfo(OrderSymbol(),MODE_BID);
      if (OrderMagicNumber()== inpMagicNumber)
     
      {ticket2= OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
      
         int count = 0;
            while ((ticket2 == -1) && (count < 10))
         {
            RefreshRates();
             ticket2= OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
             count++;
        
          }
         
      
      
      if (ticket2>0)
      
     { PreviousPricelong=false;
      PreviousPriceshort=false;
      ticket=0;
      lastTicket=-1;
      OrderOk=true;
      totalTicket=0;
      inpOrderSize = inpOrderSize_;}
     }}}}

 if((rsi <30) && (previousDirection <0) && (lastTicket>0))
      
   {
   Print("");
    Print("close order");
    Print("close order");
    Print("close order");
    Print("close order");
    
   for (int i=(OrdersTotal()-1);i>=0;i--)
   
  { if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
     
       
{
   Print ("false result in the loop - loop=" + i + "    total Ticket= " + totalTicket + "Order lots=  " + OrderLots());
      
    return;}
   
     else {
    double askprice= MarketInfo(OrderSymbol(),MODE_ASK);
    if (OrderMagicNumber()== inpMagicNumber)
     
     {ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
     
     
       int count = 0;
            while ((ticket2 == -1) && (count < 10))
         {
            RefreshRates();
             ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
             count++;
        
          }}
     
     if (ticket2>0)
     
     
     
     
     
     
      {PreviousPricelong=false;
      PreviousPriceshort=false;
      ticket=0;
    lastTicket=-1;
     OrderOk=true;
     totalTicket=0;
     inpOrderSize = inpOrderSize_;
    }}}}
   
   
   return ;


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE checkInput()
  {

   if(inpRSIPeriods<=0)
      return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

  }

// true or false has bar changed

//+------------------------------------------------------------------+
//|                                                                  |
//+---------------------------------------
//simple function to open a new order

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int orderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit)
  {
   
   int   ticket;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;

// caclulate the open price, take profit and stoploss price based on the order type
//
   if(orderType==ORDER_TYPE_BUY)
     {
      openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());

      //Ternary operator, because it makes things look neat
      //   if stopLoss==0.0){

      //stopLosssPrice = 0.0}
      //   else {
      //    stopLossPrice = NormalizedDouble (openPrice - stopLoss, Digist());
      //

      stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
      takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
     }
   else
      if(orderType==ORDER_TYPE_SELL)
        {
         openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());

        }
      else
        {
         // this function works with buy or sell
         return (-1);
        }

   ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
   return (ticket);
  }
  
  
 
 void subsequentOrders ()
 
 {
  
  
  {OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
  
   PreviousPricelong = Ask < OrderOpenPrice();
   PreviousPriceshort= Bid > OrderOpenPrice();
   }   
      if((direction>0) && (totalTicket<inpTotalOrders)  && (OrderOk==true) && (PreviousPricelong))
       {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      
      if (ticket>0)
      {
      oversold =  false; //Reset
      lastTicket = ticket;
      previousDirection= direction;
      totalTicket ++;
      inpOrderSize =inpOrderSize+inpOrderSize;
      }
     }
   else
      if((direction<0) && (totalTicket<inpTotalOrders) && (OrderOk==true) &&(PreviousPriceshort))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         
         if (ticket>0)
         {
         overbought = false;
         lastTicket= ticket;
         previousDirection=direction;
         totalTicket ++;
         inpOrderSize =inpOrderSize+inpOrderSize;
        }
        }
   
  
  
  }
  

  
  
  double GetLotSize()
  
  {
  
double vol=GetHVDays(Symbol(),100,100);
double VolEstim= vol/ 5.09902;
double StopEstimate= Ask+(Ask*VolEstim/100);

double riskPercent= inpPercentToRisk_/100;

//double inpOrderSize_= CalculateLotsize(StopEstimate,riskPercent,inpMinCash);


double inpOrderSize=OptimalLotSize (riskPercent,StopEstimate,Ask);

/// divide by number of orders

double retOrderSize;
if (inpTotalOrders==5) retOrderSize=inpOrderSize_/15;

if (inpTotalOrders==4) retOrderSize=inpOrderSize_/10;

if (inpTotalOrders==3) retOrderSize=inpOrderSize_/6;

if (inpTotalOrders==2) retOrderSize=inpOrderSize_/3;

retOrderSize=inpOrderSize_/10;

Alert ("Volatility= "+vol+"     Volestimate over 10 days =  "+ VolEstim+"   StopEstimate= "+StopEstimate);
Alert ("\n    Order size calculated for one position -------- =" + inpOrderSize_+
"        order size divived by number of orders = " + retOrderSize );

return (NormalizeDouble(retOrderSize,2));
  
  }  
  
  
  
  
  
  
  
  
  
  double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
{

  double accEquity = AccountEquity();
  Alert("accEquity: " + accEquity);
  
  double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
  Alert("lotSize: " + lotSize);
  
  double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
  
  if(Digits <= 3)
  {
   tickValue = tickValue /100;
  }
  
  Alert("tickValue: " + tickValue);
  
  double maxLossDollar = accEquity * maxRiskPrc;
  Alert("maxLossDollar: " + maxLossDollar);
  
  double maxLossInQuoteCurr = maxLossDollar / tickValue;
  Alert("maxLossInQuoteCurr: " + maxLossInQuoteCurr);
  
  double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * GetPipValue())/lotSize,2);
  
  return optimalLotSize;
 
}


double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
}

double GetPipValue()

{

if (_Digits>=4)

   {return 0.0001;}
   
   else
   
   {return 0.01;}
   



}
//+------------------------------------------------------------------+
