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

input double               pips=  0.0005;// pips to add to swing high/low stop
input double            inpMultiplier = 2;// input multiplier for take profit
input   bool            longOnly = false; // only long trades?
input   bool            shortOnly= false; // only short trades?



ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price



///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.5;  //Order size
input string   inpTradeComments  =  "Ichimuko 1D 3bar ";  //Trade comment
input double   inpMagicNumber    =  01; //Magic number

double inpRSIPeriods=2;



bool static longSignal1=false;
bool static shortSignal1=false;

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

int static ticket=0;
int static lastTicket=-1;
double stop;
//-------------------------------------------------------------------------------

  
// reset after trade closes

    if ((lastTicket!=-1) && (ticket==lastTicket)) 
    
     {
 
      OrderSelect (ticket,SELECT_BY_TICKET);
      if (OrderCloseTime()!=0) 
         {
            lastTicket=-1;
            ticket=0;
       }
               
       }


// get long and short signals


longSignal1=false;
shortSignal1=false;
if (
      (iHigh (Symbol(),PERIOD_D1,1)>iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1))  &&
      (iClose(Symbol(),PERIOD_D1,1)<iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1)) &&
      (iOpen(Symbol(),PERIOD_D1,1)>iClose(Symbol(),PERIOD_D1,1)) &&
      ( iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1) < iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_SENKOUSPANB,1)) &&
       ( iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1) < iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_SENKOUSPANA,1)) && 
         ( iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1) < iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_KIJUNSEN,1))
   ) shortSignal1=true; else shortSignal1=false;
   
if (
     (iLow(Symbol(),PERIOD_D1,1)<iIchimoku(Symbol(),PERIOD_D1,9,26,53,MODE_TENKANSEN,1)) &&
     (iClose(Symbol(), PERIOD_D1,1)>iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1)) &&
      (iOpen(Symbol(),PERIOD_D1,1)<iClose(Symbol(),PERIOD_D1,1)) &&
      ( iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1) > iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_SENKOUSPANB,1)) &&
       ( iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1) > iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_SENKOUSPANA,1)) && 
          ( iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_TENKANSEN,1) > iIchimoku(Symbol(),PERIOD_D1,9,26,52,MODE_KIJUNSEN,1))    

   )  longSignal1=true; else longSignal1=false;
         
/// enter trade
      
if (longSignal1==true)
   if (lastTicket!=ticket)
                {
              
              stop= iClose(Symbol(),PERIOD_D1,1)- iLow(Symbol(),PERIOD_D1,1);
              ticket   =  orderOpen(ORDER_TYPE_BUY,stop,stop*inpMultiplier);          
              lastTicket=ticket;
                
               }
               
if (shortSignal1==true)
   if (lastTicket!=ticket)
   
            {
            
           stop= iHigh(Symbol(),PERIOD_D1,1)- iClose(Symbol(),PERIOD_D1,1);
            ticket   =  orderOpen(ORDER_TYPE_SELL,stop,stop*inpMultiplier); 
            lastTicket=ticket;
             
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
      
      int digits = Digits();
   double spread= MarketInfo(Symbol(),MODE_SPREAD);
   if (digits==4)spread=spread/100;
   if (digits==5) spread=spread/100;
   if (digits==2) spread=spread/10;
       
      
/////debugging loop ------------------------------------------------------------------------------------------------------

      
       
       Alert ("\n\r ----- Stoploss = "+stopLoss+ " take profit=  "+takeProfit);
       
       
      
      // caclulate the open price, take profit and stoploss price based on the order type
      //
      if (orderType==ORDER_TYPE_BUY){
         Alert ("Stoplpss = "+ stopLoss+ "   Take profit=  " + takeProfit);
         openPrice    = NormalizeDouble(Ask, Digits());      
         stopLossPrice = NormalizeDouble(openPrice-stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(openPrice+takeProfit,Digits());
    

        
      } else if (orderType==ORDER_TYPE_SELL){
         Alert ("Stoplpss = "+ stopLoss+ "   Take profit=  " + takeProfit);
         openPrice = NormalizeDouble (Bid, Digits());
         stopLossPrice =  NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(openPrice-takeProfit,Digits());
         
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      double volume=NormalizeDouble(inpOrderSize,Digits());
      ticket = OrderSend (Symbol(), orderType,volume, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      
      if (orderType==ORDER_TYPE_BUY)
      {
            Alert (  "\r\nError="+GetLastError());
                    
/////debugging loop ------------------------------------------------------------------------------------------------------
                    
                
      }
      if (orderType== ORDER_TYPE_SELL)
      {
    
         Alert ( "\r\n Error=  "+GetLastError());
             

    
      }  
      
      
      
      return (ticket);
}
      