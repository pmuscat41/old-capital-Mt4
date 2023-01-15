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
input double inpTakeProfit= 500;// Enter take profit in points for order opening
input int inpStopPoints= 1000;// Enter trailing stop in points for order opening;
input double            inpAdx= 40; // ADX trigger- only trade above
input double               pips=  0.0005;// pips to add to swing high/low stop
input double            inpMultiplier = 2;// input multiplier for take profit

input int BuyCandleCounter=30;// Number of candles before Buy and Sell opened 
input string  inpbreak1 = "------------ stop management ---------------------";//
input bool   inpBreakEvenStop = True;//  Apply break even stop? (true/false)
input bool   inpDynamicTrailing = True;// Apply dynamic trailing stop? (true/false)
input double inpStopSteps = 100;//Enter steps for trailing stop in points
input int     inpMaxOrders=40;//maxinum orders


input   bool            longOnly = false; // only long trades?
input   bool            shortOnly= false; // only short trades?
input   int             inpK           = 14; // Stochastic K value (14 default)
input   int             inpD           = 3;  //  Stochastic D value (3 default)
input   int             inpSlow       = 3;  // Stochastic K smoothing (1 default)
input double             inpStochasticUpperBand = 80;  /// stochastic trending upper band
input double             inpStochasticLowerBand =  20; //   stochastic trending lower band



ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price



///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.5;  //Order size
input string   inpTradeComments  =  "Best Stochastic strategy 15m v4 (dynamic stops";  //Trade comment
input double   inpMagicNumber    =  01; //Magic number

static int lastTicket = -1;
double inpRSIPeriods=2;



bool static longSignal1=false;
bool static shortSignal1=false;
bool static longSignal2=false;
bool static shortSignal2=false;
bool static longSignal3=false;
bool static shortSignal3=false;
bool static longtrigger=false;
bool static shorttrigger=false;

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

   
double stoMain15=iStochastic(Symbol(), Period(), 14,3,1,0,1,MODE_MAIN,0);
double stoSignal15= iStochastic(Symbol(), Period(), 14,3,1,0,1,MODE_SIGNAL,0);

double stoMainDay=iStochastic(Symbol(),PERIOD_D1, 14,3,1,0,1,MODE_MAIN,0);
double stoSignalDay= iStochastic(Symbol(), PERIOD_D1, 14,3,1,0,1,MODE_SIGNAL,0);

double ADX= iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_MAIN,1);

int static counter=0;
int static ticket=0;
int static lastTicket=-1;
static double high;
static double low;
double stop;
static double entrylong=0;
static double entryshort=0;

 ApplyTrailingStop (Symbol(),inpMagicNumber);


  
    
  
  
  
/////debugging loop ------------------------------------------------------------------------------------------------------

  
// reset after trade closes

    if ((lastTicket!=-1) && (ticket==lastTicket)) 
    
     {
 
      OrderSelect (ticket,SELECT_BY_TICKET);
      if (OrderCloseTime()!=0) 
         {
            lastTicket=-1;
            ticket=0;
            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;
            longtrigger=false;
            shorttrigger=false;
            counter=0;}
               
        if (OrderType()== OP_BUYSTOP || OP_SELLSTOP) counter++;
        if (counter==5) OrderDelete(ticket,Yellow);   
            }


// clear signals


if ((stoMain15 > 30) && (stoMain15<70))

          { 
            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;
            longtrigger=false;
            shorttrigger=false;}



// get long and short signals


if (stoMainDay>stoSignalDay && stoMainDay<30) longSignal1=true;
   else longSignal1=false;
       
if  (stoMainDay<stoSignalDay&& stoMainDay>70) shortSignal1=true;
   else shortSignal1=false;
         
if (stoMain15<20)
   if (stoMain15>stoSignal15)        
      longSignal2=true;
        
if (stoMain15>80)
   if (stoMain15>stoSignal15)        
      shortSignal2=true;
         
if ((longSignal2==true) &&(stoMain15>20)) longSignal3=true;

if ((shortSignal2==true) && (stoMain15<80)) shortSignal3=true;
   
/// find swinglow pattern
if (
    (iLow(Symbol(),Period(),2)<iLow(Symbol(),Period(),3)) &&
    (iLow(Symbol(),Period(),2)<iLow(Symbol(),Period(),1))
   )
      {
      longtrigger=true;
      low=iLow(Symbol(),Period(),2);
      entrylong=iHigh(Symbol(),Period(),1);
      }

//find swing high patten
if (
   (iHigh(Symbol(),Period(),2)>iHigh(Symbol(),Period(),3)) &&
   (iHigh(Symbol(),Period(),2)>iHigh(Symbol(),Period(),1))
   )
      {
      shorttrigger=true;
      high=iHigh(Symbol(),Period(),2);
      entryshort=iLow(Symbol(),Period(),1);
      }

Comment ( "\r\n Long trades- 1 Day long? " + longSignal1 + "  Main<20 and cross? "+  longSignal2 + " crosses up 20? "+ longSignal3 + "   turningpoint? " + longtrigger + "order price=  "+entrylong+
            "\r\n Short trades - 1Day short?  " + shortSignal1 + "   Main>80 and cross?" + shortSignal2+ "  crosses down 80?" + shortSignal3+ "  turningpoint? " + shorttrigger+"Order price=  "+entryshort);
             

/// enter trade
      
if (longSignal1==true)
   if (longSignal2==true)
      if (longSignal3==true)
         if (longtrigger==true)
            if (lastTicket==-1)
                 if (ADX>inpAdx)
              {
              
              stop= entrylong-low-pips;
              ticket   =  orderOpen(OP_BUYSTOP,entrylong,stop,stop*inpMultiplier);          
               lastTicket=ticket;
                
               }
               
if (shortSignal1==true)
   if (shortSignal2==true)
      if (shortSignal3==true)
         if (shorttrigger==true)
            if (lastTicket==-1)
               if (ADX>inpAdx)
            {
            Alert("short entrty");
           stop= high-entryshort+pips;
            ticket   =  orderOpen(OP_SELLSTOP,entryshort,stop,stop*inpMultiplier); 
            lastTicket=ticket;
             
            }
         
  }   
//+------------------------------------------------------------------+



ENUM_INIT_RETCODE checkInput(){

   if (inpRSIPeriods<=0)   return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

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
                  
                  if (Ask > Buyband50)
                      if (Ask < Buyband60)
                     
                        {                       
                        Buy50Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step50, digits);
                       
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask > Buyband60)
                     if (Ask< Buyband70)
                        {
                        Buy60Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step60, digits);
                       
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask > Buyband70)
                    if (Ask< Buyband80)
                        {
                        Buy70Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step70, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask > Buyband80)
                    if (Ask<Buyband90)  
                        {                       
                        Buy80Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step80, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask >  Buyband90)                       
                        {
                        Buy90Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-StopSteps, digits);
                       
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
              
                  }            
                  
                  
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                  if (Bid < Sellband50)
                     if (Bid> Sellband60)
                        
                        {
                        Sell50Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step50, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }
                  if (Bid < Sellband60)
                     if (Bid> Sellband70)
                        {
                        Sell60Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step60, digits);
                       
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid < Sellband70)
                    if (Bid> Sellband80)
                        {
                        Sell70Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step70, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid < Sellband80)
                    if (Bid> Sellband90)
                        {
                        Sell80Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step80, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid <Sellband90)
                        {
                        Sell90Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+StopSteps, digits);
                       
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  }            
             
                    
                    
                    
                    
 ////////////////////FOLLOWING STOPS==========================================
 
 if (inpBreakEvenStop==true)
 
 {
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                        buyStopLoss = NormalizeDouble(Ask-trailingStop, digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                                   
                    
                    
                
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                        sellStopLoss = NormalizeDouble(Bid+trailingStop, digits);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }                
                    
                    
                    
                    
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
   
   int orderOpen (ENUM_ORDER_TYPE orderType, double orderPrice, double stopLoss, double takeProfit){
      
      int   ticket;
      double openPrice;
      double stopLossPrice;
      double takeProfitPrice;
      
      int digits = Digits();
   double spread= MarketInfo(Symbol(),MODE_SPREAD);
   if (digits==4)spread=spread/100;
   if (digits==5) spread=spread/100;
   if (digits==2) spread=spread/10;
       
      
/////debugging loop ------------------------------------------------------------------------------------------------------

      
       
       Comment ("\n\r order price passed to function = "+orderPrice+  " Stoploss = "+stopLoss+ " take profit=  "+takeProfit);
       
       
      
      // caclulate the open price, take profit and stoploss price based on the order type
      //
      if (orderType==OP_BUYSTOP){
         openPrice    = NormalizeDouble(orderPrice, Digits());      
         stopLossPrice = NormalizeDouble(openPrice-stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(openPrice+takeProfit,Digits());
    

        
      } else if (orderType==OP_SELLSTOP){
         openPrice = NormalizeDouble (orderPrice, Digits());
         stopLossPrice =  NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(openPrice-takeProfit,Digits());
         
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      double volume=NormalizeDouble(inpOrderSize,Digits());
      ticket = OrderSend (Symbol(), orderType,volume, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber,0);
      
      if (orderType==OP_BUYSTOP)
      {
            Comment (  "\r\n Long trades- 1 Day long? " + longSignal1 + "  Main<20 and cross? "+  longSignal2 + " crosses up 20? "+ longSignal3 + "   turningpoint? " + longtrigger +
                    "\r\n\r\n\r\n\r\n long entry - entry pice= "+openPrice+ " stop = " + stopLossPrice+ "  take profit = " + takeProfitPrice+
                    "\r\n\ Error="+GetLastError());
                    
/////debugging loop ------------------------------------------------------------------------------------------------------
                    
                
      }
      if (orderType== OP_SELLSTOP)
      {
    
         Comment ( "\r\n Short trades - 1Day short?  " + shortSignal1 + "   Main>80 and cross?" + shortSignal2+ "  crosses down 80?" + shortSignal3+ "  turningpoint? " + shorttrigger+
              "\r\n\r\n\r\n\r\n short entry - entry pice= "+openPrice+ " stop = " + stopLossPrice+ "  take profit = " + takeProfitPrice+
              "\r\n Error=  "+GetLastError());
             

    
      }  
      
      
      
      return (ticket);
}
      