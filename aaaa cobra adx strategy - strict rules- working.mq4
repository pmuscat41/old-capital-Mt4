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


//The Levels


input int                  inpRSIPeriods  =  14;               //RSI Periods

input ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit

input double               inpTakeProfit  =  0.0;     //Take Profit in currency value
input double               inpStopLoss   =  0.0;     //Stop Loss in currecny value

///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.5;  //Order size
input string   inpTradeComments  =  "Cobra ADX";  //Trade comment
input double   inpMagicNumber    =  212121; //Magic number

static int lastTicket = -1;
static double previousDirection =0;
static bool closeLong=false;
static bool closeShort=false;
static bool tradeLongOpen=false;

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
   


  
     
     double TwoHunMaHLC = iMA(Symbol(),Period(),200,0,MODE_SMMA, PRICE_MEDIAN,0);
     double TwoHunMaHI= iMA(Symbol(),Period(),200,0,MODE_SMMA, PRICE_HIGH,0);;
     double TwoHunMaLO = iMA(Symbol(),Period(),200,0,MODE_SMMA, PRICE_LOW,0);
     
     double tenEMAHLC= iMA(Symbol(),Period(),10,0,MODE_EMA, PRICE_MEDIAN,0);
     double tenEMAHI= iMA(Symbol(),Period(),10,0,MODE_EMA, PRICE_HIGH,0);
     double tenEMALO= iMA(Symbol(),Period(),10,0,MODE_EMA, PRICE_LOW,0);
     
     double ADX=iADX(Symbol(),Period(),5,PRICE_MEDIAN,0,0);
     
     double direction= iMA(Symbol(),Period(),200,0,MODE_SMMA, PRICE_MEDIAN,0)-iMA (Symbol(),Period(),200,0,MODE_SMMA, PRICE_MEDIAN,1);
     
     /// positive= uptrend, negative = down trend
   
   ////// open   trades -----------------------------------------
   
   
     double open= iOpen (Symbol(),Period(),0);
     double close = iClose (Symbol(),Period(),1);
       
      
    if (!newBar()) return;  //only trade on new bar
    
    closeLong=false;
     closeShort=false;
    
   static int  ticket =0;
   
   if ((open > tenEMAHI ) && (open> TwoHunMaHI) && (direction>0) && (ticket!=lastTicket) && (ADX >40))
     {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      lastTicket = ticket;
      previousDirection= direction;
      tradeLongOpen=true;
     }
   else
      if ((open<tenEMALO) && (open < TwoHunMaLO) && (direction<0) && (ticket!=lastTicket)&&(ADX>40))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         lastTicket= ticket;
         previousDirection=direction;
         tradeLongOpen=false;
        }
    
    
 /////// order close criteria check to see if we should close an order
 ///// 
 
 double SellClosePoint = iMA(Symbol(),Period(),10,0,MODE_EMA, PRICE_HIGH,1);
 double BuyClosePoint = iMA(Symbol(),Period(),10,0,MODE_EMA, PRICE_LOW,1);
 double lastCloseAsk = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
 double lastCloseBid=  NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
  
    if (lastCloseBid>SellClosePoint)
       closeShort=true;
    
    if (lastCloseAsk<BuyClosePoint) 
     closeLong=true;
    
   Alert ("Long Close signal  "+closeLong+ "direction= "+direction+ "  previous direction   "+previousDirection+ "ticket ="+ticket+" Lastticket = "+ lastTicket);
   Alert ("Short Close signal  "+closeShort+" direction=" + direction+ " previous direction   "+previousDirection+ "ticket ="+ticket+" Lastticket = "+ lastTicket);
 
   double  closeBuyPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
   double closeSellPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
    
         
  if ((closeLong==true) && (ticket==lastTicket)&&(tradeLongOpen==true))
     {  OrderClose (lastTicket,inpOrderSize,closeBuyPrice,10,Red);
      lastTicket=-1;}

   if ((closeShort==true) && (ticket==lastTicket)&& (tradeLongOpen==false))
      {OrderClose (lastTicket,inpOrderSize,closeSellPrice,10,Blue);
     lastTicket=-1;}
          
    
   return ;

     
     
     
   
   
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
      