//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//| UPDATED WITH MOVING AVERAGE EXIT

//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//The Levels

input double               inpadxVal            =  40;  // input ADX value to enter trade

input int               inpMAperiod    =  200;  // Long moving average
input double            inpStopSteps = 100;// Steps for stoploss (value in points for each of 5 steps)

input   bool            longOnly = false; // only long trades?
input   bool            shortOnly= false; // only short trades?
input   int             inpK           = 14; // Stochastic K value (14 default)
input   int             inpD           = 3;  //  Stochastic D value (3 default)
input   int             inpSlow       = 3;  // Stochastic K smoothing (1 default)
input double             inpStochasticUpperBand = 80;  /// stochastic trending upper band
input double             inpStochasticLowerBand =  20; //   stochastic trending lower band
double             inpStochasticHighQuad = 55;  /// stochastic upper quadrant
double             inpStochasticLowQuad =  45; ///  stochastic lower quadrant


input   int              inplookback =     2; // lookback period for Stochastic exit

int                    inpRSIPeriods  =  14;               //RSI Periods

input int                    inpMAshort        = 125;  // Short MA (for alignment of MA direction)
input int                  inpMedMA          =     100;//   Med Ma (for alignment of MA direction)




ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit

input double               inpTakeProfit  =  0.0;     //Take Profit in currency value
input double               inpStopLoss   =  0.0;     //Stop Loss in currecny value

 double            inpStopPoints = inpTakeProfit;

///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.5;  //Order size
input int inptrendstrength  = 5 ; // Enter strength of trend 5 and above
input string   inpTradeComments  =  "Stocastic cross over";  //Trade comment
double   inpMagicNumber    =  Ask; //Magic 

input double         lotsWinning = 0.3;// Enter lots after a win trade
input double         lotsLosses = 0.01;// Ebter lots after a losing trade


static int lastTicket = -1;
static double previousDirection =0;
static bool closeLong=false;
static bool closeShort=false;
static bool tradeLongOpen=false;
static bool tradeShortOpen=false;      

double volume;
double static LongLots =lotsLosses ;
double static ShortLots= lotsLosses;
double Docket=0;

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
   
   //// define variables for long ma, short ma, adx and direction  
     double LongMA = iMA(Symbol(),Period(),inpMAperiod,0,MODE_EMA, PRICE_MEDIAN,0);
     double ShortMA= iMA(Symbol(),Period(),inpMAshort,0,MODE_EMA, PRICE_MEDIAN,0);
     double MedMA= iMA(Symbol(),Period(),inpMedMA,0,MODE_EMA, PRICE_MEDIAN,0);
     
     double ADX=iADX(Symbol(),Period(),5,PRICE_MEDIAN,0,0);
     
     ///double direction= iMA(Symbol(),Period(),inpMAperiod,0,MODE_SMMA, PRICE_MEDIAN,0)-iMA (Symbol(),Period(),inpMAperiod,0,MODE_SMMA, PRICE_MEDIAN,1);
     
     
     /// positive= uptrend, negative = down trend
   
   ////// open   trades -----------------------------------------
   
   static bool longCross=false;
   static bool shortCross=false;
    
     double open= iOpen (Symbol(),Period(),0);
     double close = iClose (Symbol(),Period(),1);
     
     static int direction =0;  
     static int  ticket =0;
   
    if (!newBar()) return;  //only trade on new bar
    
  //   closeLong=false;
   //  closeShort=false;
   
if ((lastTicket!=-1) && (ticket==lastTicket))  {
 
OrderSelect (ticket,SELECT_BY_TICKET);
if (OrderCloseTime()!=0) 
{
   Comment ("trade is closed -");
   Comment ("reset all values");


   lastTicket=-1;
   ticket=0;
   tradeLongOpen=false;
   tradeShortOpen= false;
   closeLong=false;
   closeShort=false;   
   LongLots = GetLongLotSize (Docket);
   ShortLots= GetShortLotSize(Docket);
   
  } }
      
 ////
      
double LongMABF = iMA(Symbol(),Period(),200,0,MODE_EMA, PRICE_MEDIAN,1);   
  
      
direction=0;
      
 if (Ask>LongMABF) direction =1;
 if ((Bid<LongMABF)) direction =-1;

double StoMain= iStochastic(Symbol(),Period(),inpK,inpD,inpSlow,MODE_SMA,0, MODE_MAIN,1); 
double StoMainB4= iStochastic(Symbol(),Period(),inpK,inpD,inpSlow,MODE_SMA,0, MODE_MAIN,2); 
     
   
Comment ("direction=" ,direction, "\n",
"Stochastics= ", StoMain ,"\n",
 "Stochasstics before= ",StoMainB4,"\n", 
 "Short cross=", shortCross,"\n",
 "long corss= ", longCross,"\n",
 "minimum stop = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));
 
 
 /////
ApplyTrailingStop(Symbol(),inpMagicNumber);
 //////
 
///// clear overbought and oversold flags if in middle of range

if ((StoMain>inpStochasticLowerBand) && (StoMain<inpStochasticUpperBand)) {
longCross=false;
shortCross=false;}

// trade enter conditions  -

 if ((direction==-1) && (StoMain<inpStochasticLowerBand) )
 {shortCross= true;
 
 Comment ("\n","\n","\n","\n","\n","\n","\n","+++++++++++++++++++ long trade possible, waiting cross MA ");}
 
 if ((direction==1) &&  (StoMain>inpStochasticUpperBand))
 
 {longCross=true;
 Comment ("------------ short trade possible, waiting cross MA");
  } 
 
   
   
    //closing open trades
   
 // if ((tradeShortOpen==true) && (close>ShortMA)&&  (ticket==lastTicket)&&(longOnly==false))
   //  closeShort=true;
    
//   if ((tradeLongOpen==true)&& (close<ShortMA) &&(ticket==lastTicket)&&(shortOnly==false)) 
 //  closeLong=true;
   
        
   if ( (longCross==true) && (direction==1) &&(ticket!=lastTicket) && (ADX >inpadxVal) && (shortOnly==false))
     {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      lastTicket = ticket;
      previousDirection= direction;
      tradeLongOpen=true;
      tradeShortOpen=false;
      
     }
   else
      if ( (shortCross==true) && (direction==-1)&& (ticket!=lastTicket)&&(ADX>inpadxVal)&& (longOnly==false))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         lastTicket= ticket;
         previousDirection=direction;
         tradeLongOpen=false;
         tradeShortOpen=true;
         
        }
    
       
   double  closeBuyPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
   double closeSellPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
    
         
  if ((closeLong==true) && (ticket==lastTicket)&&(tradeLongOpen==true))
     {  OrderClose (lastTicket,inpOrderSize,closeBuyPrice,30,Red);
      lastTicket=-1;
      ticket=0;
   tradeLongOpen=false;
   tradeShortOpen= false;
   closeLong=false;
   closeShort=false; 
      }

   if ((closeShort==true) &&  (ticket==lastTicket)&& (tradeLongOpen==false))
      {OrderClose (lastTicket,inpOrderSize,closeSellPrice,30,Blue);
   lastTicket=-1;
   ticket=0;
   tradeLongOpen=false;
   tradeShortOpen= false;
   closeLong=false;
   closeShort=false; 
     }
          
   return ;

     
     
     
   
   
  }   
//+------------------------------------------------------------------+



ENUM_INIT_RETCODE checkInput(){

   if (inpRSIPeriods<=0)   return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

}



 double GetLongLotSize (int ticket)
 
 {
 
double Lots;
OrderSelect (ticket,SELECT_BY_TICKET);
 if (OrderProfit()>0) Lots = lotsWinning;
 if (OrderProfit()<0) Lots = lotsLosses;
return(Lots);
 }
 
 double GetShortLotSize (int ticket)
 
 {
 
 double Lots;
OrderSelect (ticket,SELECT_BY_TICKET);
 if (OrderProfit()>0) Lots = lotsWinning;
 if (OrderProfit()<0) Lots = lotsLosses;
return(Lots);
 
 }




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
      
      double StopSteps=SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopSteps;
      double trailingStop=SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopPoints;
      
      double step90=StopSteps;
      double step80=StopSteps*2;
      double step70=StopSteps*3;
      double step60=StopSteps*4;
      double step50=StopSteps*5;
      
      double BuyProfitRange= OrderTakeProfit()-OrderOpenPrice();
      double SellProfitRange= OrderOpenPrice()- OrderTakeProfit();
      
      double Buyband50= OrderOpenPrice()+(BuyProfitRange*0.5);
      double Buyband60=OrderOpenPrice()+(BuyProfitRange*0.6);
      double Buyband70=OrderOpenPrice()+(BuyProfitRange*0.7);
      double Buyband80=OrderOpenPrice()+(BuyProfitRange*0.8);
      double Buyband90=OrderOpenPrice()+(BuyProfitRange*0.9);
      
      
      double Sellband50= OrderOpenPrice()-(SellProfitRange*.5);
      double Sellband60=OrderOpenPrice()-(SellProfitRange*.6);
      double Sellband70=OrderOpenPrice()-(SellProfitRange*.7);
      double Sellband80=OrderOpenPrice()-(SellProfitRange*.8);
      double Sellband90= OrderOpenPrice()-(SellProfitRange*.9);    
      
      
      ///  DYNAMIC STOPS =====================================================
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                  if (Bid > Buyband50)
                      if (Bid < Buyband60)
                     
                        {                       
                        Buy50Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step50, digits);
                     
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid > Buyband60)
                     if (Bid< Buyband70)
                        {
                        Buy60Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step60, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid > Buyband70)
                    if (Bid< Buyband80)
                        {
                        Buy70Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step70, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid > Buyband80)
                    if (Bid<Buyband90)  
                        {                       
                        Buy80Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step80, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid >  Buyband90)                       
                        {
                        Buy90Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-StopSteps, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
              
                  }            
                  
                  
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                  if (Ask < Sellband50)
                     if (Ask> Sellband60)
                        
                        {
                        Sell50Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step50, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }
                  if (Ask < Sellband60)
                     if (Ask> Sellband70)
                        {
                        Sell60Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step60, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask < Sellband70)
                    if (Ask> Sellband80)
                        {
                        Sell70Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step70, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask < Sellband80)
                    if (Ask> Sellband90)
                        {
                        Sell80Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step80, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask <Sellband90)
                        {
                        Sell90Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+StopSteps, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  }            
             
                    
                    
                    
                    
 ////////////////////FOLLOWING STOPS==========================================
 
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                        buyStopLoss = NormalizeDouble(Bid-trailingStop, digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                                   
                    
                    
                
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                        sellStopLoss = NormalizeDouble(trailingStop, digits);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }                
                    
                    
                    
                    
                    
                    
                    
                          
      }
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
      
      int digits = Digits();
   double spread= MarketInfo(Symbol(),MODE_SPREAD);
   if (digits==4)spread=spread/100;
   if (digits==5) spread=spread/100;
   if (digits==2) spread=spread/10;
       
      
      
      
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
         volume= NormalizeDouble(LongLots,Digits()); 
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss-spread,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
      }else if (orderType==ORDER_TYPE_SELL){
         openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss+spread,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
         volume= NormalizeDouble(ShortLots,Digits()); 
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (Symbol(), orderType,volume, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      