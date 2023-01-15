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
input double inpTakeProfit= 500;// Enter take profit in points for order opening
input int inpStopPoints= 1000;// Enter trailing stop in points for order opening;
input double   inpOrderSize_      =  0.05;  //Order size for order opening

double  inpOrderSize = inpOrderSize_;
 
input ENUM_TIMEFRAMES  inpStopTrailTimeframe=PERIOD_M15;// Timeframe to update trailing stop
input string  inpbreak1 = "------------ stop management ---------------------";//
input bool   inpBreakEvenStop = True;//  Apply break even stop? (true/false)
input bool   inpDynamicTrailing = True;// Apply dynamic trailing stop? (true/false)
input double inpStopSteps = 100;//Enter steps for trailing stop in points
input string inpbreak2=" _____________________________________________________";//
input string   inpTradeComments  =  "Hedging EA";  //Trade comment
input double   inpMagicNumber    =  21212577837352; //Magic number 



double stploss;
double takeProfit;
int ticket;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {



      
      stploss= SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopPoints;
      takeProfit=SymbolInfoDouble(Symbol(),SYMBOL_POINT)*inpTakeProfit;
      

      ticket   =  orderOpen(ORDER_TYPE_BUY, stploss,takeProfit);
      ticket  =  orderOpen(ORDER_TYPE_SELL, stploss,takeProfit);
       
       


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
      ApplyTrailingStop (Symbol(),inpMagicNumber);
        
             
   
   //New Order on newbar
  

   if(!newBar())
      return;  //only trade on new bar



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


void ApplyTrailingStop(string symbol, int magicNumber)

   {
   
      static int digits= (int) SymbolInfoInteger (symbol,SYMBOL_DIGITS);
      /// Trailing from close price
      
      
      double buyStopLoss;
      double sellStopLoss;
      
       
      
     
     double BuyProfitRange;
     double SellProfitRange;
     double progress;
     bool Buy50Stop, Buy60Stop, Buy70Stop,Buy80Stop, Buy90Stop;
     bool Sell50Stop, Sell60Stop,Sell70Stop,Sell80Stop,Sell90Stop;
     
        int count=OrdersTotal();
      
      for (int i=count-1;i>=0;i--)
      
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      
      static bool Buy50Stop=false;
      static bool Buy60Stop=false;
      static bool Buy70Stop=false;
      static bool Buy80Stop=false;
      static bool Buy90Stop=false;
      
      static bool Sell50Stop=false;
      static bool Sell60Stop=false;
      static bool Sell70Stop=false;
      static bool Sell80Stop=false;
      static bool Sell90Stop=false;     
      
      double StopStep=SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopSteps;
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { BuyProfitRange= OrderTakeProfit()-OrderOpenPrice();
                  if (Bid > (OrderOpenPrice()+(BuyProfitRange*0.5))&&
                     (Bid< (OrderOpenPrice()+(BuyProfitRange*0.6))))
                        {
                        Buy50Stop=true;
                        buyStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-(StopStep*5), digits);
                        }
                  if (Bid > OrderOpenPrice()+(BuyProfitRange*.6)&&
                     (Bid< OrderOpenPrice()+(BuyProfitRange*.7)))
                        {
                        Buy60Stop=true;
                        buyStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-(StopStep*4), digits);
                        }
                  if (Bid > OrderOpenPrice()+(BuyProfitRange*.7)&&
                     (Bid< OrderOpenPrice()+(BuyProfitRange*.8)))
                        {
                        Buy70Stop=true;
                        buyStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-(StopStep*3), digits);
                        }
                  if (Bid > OrderOpenPrice()+(BuyProfitRange*.8)&&
                     (Bid< OrderOpenPrice()+(BuyProfitRange*.9)))
                        {                       
                        Buy80Stop=true;
                        buyStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-(StopStep*2), digits);
                        }
                  if (Bid > OrderOpenPrice()+(BuyProfitRange*.9)&&
                     (Bid< OrderOpenPrice()+(BuyProfitRange)))
                        {
                        Buy90Stop=true;
                        buyStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-(StopStep*1), digits);
                        }
              
                  }            
                  
                  
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
                { SellProfitRange= OrderOpenPrice()- OrderTakeProfit();
                  if (Ask > OrderOpenPrice()-(SellProfitRange*.5)&&
                     (Ask< OrderOpenPrice()-(SellProfitRange*.6)))
                        {
                        Sell50Stop=true;
                        sellStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+(StopStep*5), digits);
                        }
                  if (Ask > OrderOpenPrice()-(SellProfitRange*.6)&&
                     (Ask< OrderOpenPrice()-(SellProfitRange*.7)))
                        {
                        Sell60Stop=true;
                        sellStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+(StopStep*4), digits);
                        }
                  if (Ask > OrderOpenPrice()-(SellProfitRange*.7)&&
                     (Ask< OrderOpenPrice()-(SellProfitRange*.8)))
                        {
                        Sell70Stop=true;
                        sellStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+(StopStep*3), digits);
                        }
                  if (Ask > OrderOpenPrice()-(SellProfitRange*.8)&&
                     (Ask< OrderOpenPrice()-(SellProfitRange*.9)))
                        {
                        Sell80Stop=true;
                        sellStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+(StopStep*2), digits);
                        }
                  if (Ask > OrderOpenPrice()-(SellProfitRange*.9)&&
                     (Ask< OrderOpenPrice()-(SellProfitRange)))
                        {
                        Sell90Stop=true;
                        sellStopLoss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+(StopStep*1), digits);
                        }
                  }            
                  
                     
       //adjust trades in proffit +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       
       // Break Even
       
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (Buy50Stop==true)  
                     if (buyStopLoss>OrderOpenPrice())
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                            if (Sell50Stop==true)
                              if (OrderProfit()>0)
                                 if  (sellStopLoss<OrderOpenPrice())
                                    if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                          
        
        // 60 % gain
        
        
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (Buy60Stop==true)
                     if (buyStopLoss>OrderOpenPrice())
                       if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                           if (Sell60Stop==true)
                            if  (sellStopLoss<OrderOpenPrice())
                             if (sellStopLoss<OrderStopLoss())
                                 OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
        
        // 70% gain
        
        
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (Buy70Stop==true)
                  if (buyStopLoss>OrderOpenPrice())
                   if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                            if (Sell70Stop==true)
                            if  (sellStopLoss<OrderOpenPrice())
                             if (sellStopLoss<OrderStopLoss())
                                 OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
        
        // 80% gain
        
        
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (Buy80Stop==true)
                  if (buyStopLoss>OrderOpenPrice())
                   if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                            if (Sell80Stop==true)
                            if  (sellStopLoss<OrderOpenPrice())
                             if (sellStopLoss<OrderStopLoss())
                                 OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
        // 90% gain
        
        
        
        
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (Buy90Stop==true)
                  if (buyStopLoss>OrderOpenPrice())
                   if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                    
                     if (OrderSymbol()==symbol)
                        if (OrderMagicNumber()==magicNumber)
                          if (OrderType()==ORDER_TYPE_SELL)
                            if (Sell90Stop==true)
                            if  (sellStopLoss<OrderOpenPrice())
                             if (sellStopLoss<OrderStopLoss())
                                 OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
        
        
        
        
        Alert ("\n"+Buy50Stop+Buy60Stop+Buy70Stop+Buy80Stop+Buy90Stop+BuyProfitRange);
        Alert ("\n"+Sell50Stop+Sell60Stop+Sell70Stop+Sell80Stop+Sell90Stop+SellProfitRange);
        
        
        
        
        
        
        
                    
                          
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
