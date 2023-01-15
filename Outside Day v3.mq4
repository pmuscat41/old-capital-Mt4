//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//|
//  Code is from http://www.orchardforex.com 
//  title of You tube video is "Biginners guide : Write your own RSI expert advisor for MT4
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int     inpRSIPeriods  =  14;               //RSI Periods
         ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
input       double factor= 2.1;// enter ATR factor for stoploss


input double  inpOrderSize      =  0.1;  //Order size
input string  inpTradeComments  =  "Outside Day v3";  //Trade comment
input double  inpMagicNumber    =  212121; //Magic number
input int      inputDaystoExit =  4; // input days to exit as a stop
double stoplossPrice;

int  static ticket =0;
 
int static daysPast=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  ENUM_INIT_RETCODE result =  INIT_SUCCEEDED ;
  
  result =  checkInput();
  if (result!=INIT_SUCCEEDED) return(result);  //exit if inputs are bad 

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
void OnTick()  {


   if (!newBar()) return;  //only trade on new bar
     


// reset after stoploss

if (ticket>0) 
   {  OrderSelect (ticket, SELECT_BY_TICKET);
      if (OrderCloseTime()!=0) 
      {ticket=0;
      daysPast=0;}}


if (ticket>0) daysPast++;

// Trade Exit


if (ticket>0)

   {
      OrderSelect (ticket,SELECT_BY_TICKET);
     
          
       if ((OrderType()== ORDER_TYPE_BUY)&& (OrderProfit()>0) || (daysPast=inputDaystoExit))
            {
             RefreshRates();
            OrderClose(ticket,OrderLots(),Bid,10);
            if (GetLastError()==-1)
            {
               while (GetLastError()!=-1)
               {RefreshRates();
                OrderClose(ticket,OrderLots(),Bid,10);}}
                       
                  ticket=0;
            }
            
            
        if ((OrderType()==ORDER_TYPE_SELL) && (OrderProfit()>0) || (daysPast==inputDaystoExit))
            
            {
              RefreshRates();
              OrderClose(ticket,OrderLots(),Ask,10);
               if (GetLastError()==-1)
            {
               while (GetLastError()!=-1)
               {RefreshRates();
                OrderClose(ticket,OrderLots(),Ask,10);}}  
              
              
             ticket=0;  
            }
     }       
                     
                        
   double KeltnerMovingAverage = iMA(Symbol(),Period(),20,0,MODE_EMA,PRICE_TYPICAL,1);
         double ATR                  = iATR(Symbol(),Period(),20,1);
         double KeltnerBandShift     = ATR*factor;
         double Stop     = KeltnerBandShift;




//  Trade entry
      
      if ((ticket==0) && (High[2]>High[3])   &&  (Low[2]<Low[3])  &&  (Close[2]<Low[3])&& Open[1]<Close[2])  {
      ticket   =  orderOpen(ORDER_TYPE_BUY, Stop,0);
      
      }else
      if ( (ticket==0)  &&(Low[2]<Low[3])  &&  (High[2]>High[3])  &&  (Close[2]>High[3]) && Open[1]>Close[2] ) {
      ticket  =  orderOpen (ORDER_TYPE_SELL, Stop,0);
      
      }
      
 
   
   
  }   
//+------------------------------------------------------------------+

ENUM_INIT_RETCODE checkInput(){

   if (inpRSIPeriods<=0)   return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

}

// true or false has bar changed

bool newBar(){

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result =      (currentTime!=priorTime); //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
   }
   
   //simple function to open a new order 
   
   int orderOpen (ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit){
      
      int   ticket;
      double openPrice;
      double stopLossPrice;
      double takeProfitPrice;
      
      // caclulate the open price, take profit and stoploss price based on the order type
      //
      if (orderType==ORDER_TYPE_BUY){
         openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
      
         //Ternary operator, because it makes things look neat
         //   if stopLoss==0.0){
     
         //stopLosssPrice = 0.0} 
         //   else {
         //    stopLossPrice = NormalizedDouble (openPrice - stopLoss, Digist());
         //
      
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
      }else if (orderType==ORDER_TYPE_SELL){
         openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      