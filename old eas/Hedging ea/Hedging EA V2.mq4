//+------------------------------------------------------------------+
//|                                                 Hedging EA.mq4 |
//|                                                Copyright 2021PJM |
//|            
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/// RSI levels are from 0 -100, select levels for overbought and oversold
//  and the inputs to RSI

int                  inpRSIPeriods  =  2;               //RSI Periods

input ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
input int inpTrailStopPoints= 1000;// Enter trailing stop in points;
input double   inpOrderSize_      =  0.05;  //Order size for first buy - increases each time
input string   inpTradeComments  =  "Hedging EA";  //Trade comment
input double   inpMagicNumber    =  212125; //Magic number
double  inpOrderSize = inpOrderSize_;
input double inpTakeProfit= 500;// Enter take profit in points 
input ENUM_TIMEFRAMES  inpStopTrailTimeframe=PERIOD_M15;// Timeframe to update trailing stop

double stploss;
double takeProfit;
int ticket;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {



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

   /// manage trade
   
  
   if(!StopAdjust())
      return;  //only adjust trailing stop on trailing stop timeframe
      
      // only apply trailing stop if better than opening price
      // only apply trailing stop if better than current trailing stop
      
      /// get trailing stop in points (int)
      // need stoploss = double
      
      stploss= SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpTrailStopPoints;
      takeProfit=SymbolInfoDouble(Symbol(),SYMBOL_POINT)*inpTakeProfit;
      
      ApplyTrailingStop (Symbol(),inpMagicNumber,stploss);
        
             
   
   //New Order on newbar
  

   if(!newBar())
      return;  //only trade on new bar


      ticket   =  orderOpen(ORDER_TYPE_BUY, stploss,takeProfit);
      ticket  =  orderOpen(ORDER_TYPE_SELL, stploss,takeProfit);
       
       
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
//+------------------------------------------------------------------+


void ApplyTrailingStop(string symbol, int magicNumber, double stoploss)

   {
   Alert (symbol+"     "+magicNumber+"   "+stoploss);
      static int digits= (int) SymbolInfoInteger (symbol,SYMBOL_DIGITS);
      /// Trailing from close price
      
      double buyStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-stoploss, digits);
      double sellStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+stoploss, digits);
      
      
      double buyStopLossLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-(stoploss/6), digits);
      double sellStopLossLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+(stoploss/6), digits);
     
      int count=OrdersTotal();
      
      for (int i=count-1;i>=0;i--)
      
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (OrderProfit()>0)
                  if (buyStopLoss>OrderOpenPrice())
                   if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                            if (OrderProfit()>0)
                            if  (sellStopLoss<OrderOpenPrice())
                             if (sellStopLoss<OrderStopLoss())
                                 OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                          
                          
                          
                          
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (OrderProfit()<0)
                  
                   if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLossLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                            if (OrderProfit()<0)
                            
                             if (sellStopLoss<OrderStopLoss())
                                 OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLossLoss,OrderTakeProfit(),OrderExpiration());
                          
                          
      }
      }


bool newBar()
  {

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result = (currentTime!=priorTime);      //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
  }

bool StopAdjust()
  {

   datetime          currentTime2 =  iTime(Symbol(),inpStopTrailTimeframe,0);// get openong time of bar
   static datetime   priorTime2 =   currentTime2; // initialized to prevent trading on first bar
   bool              result = (currentTime2!=priorTime2);      //Time has changed
   priorTime2               =        currentTime2; //reset for next time
   return(result);
  }



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
  
  
  
  
//+------------------------------------------------------------------+
