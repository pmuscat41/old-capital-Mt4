///+------------------------------------------------------------------+
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



// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit


///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.01;  //Order size
input string   inpTradeComments  =  "Rubber band";  //Trade comment
input double   inpMagicNumber    =  000001; //Magic number

double inpStopLoss;
double inpTakeProfit;
double inpRSIPeriods=2;
static int  ticket =0;

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


double maClose= iMA (Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,0);  
double maNow= iMA (Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1);
double maB4= iMA (Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,2);
double price = iClose(Symbol(),Period(),1);


double direction= maNow-maB4;
bool static golong= false;

if (direction>=0) golong=true;
if (direction<0) golong=false;



if ((Bid < iMA (NULL,0,50,0,MODE_SMA,PRICE_CLOSE,1)) && (golong==false)&& (ticket>0))

{

Alert ("_____close signal______");
RefreshRates();
double bidprice= MarketInfo(Symbol(),MODE_BID);
bool check =OrderClose(ticket,inpOrderSize,bidprice,20,Red);
 
if (check==false) {

for (int i=1; i<80;i++)
{
RefreshRates();
double bidprice= MarketInfo(Symbol(),MODE_BID);
check = OrderClose(ticket,inpOrderSize,bidprice,20+i,Red);

if (check==true){
bool initial=tradeDelay();
 return;}}}}


if ((Ask > iMA (NULL,0,50,0,MODE_SMA,PRICE_CLOSE,1)) && (golong==true)&& (ticket>0))

{

Alert ("_____close signal______");
RefreshRates();
double askprice= MarketInfo(Symbol(),MODE_ASK);
bool check2 = OrderClose(ticket,inpOrderSize,askprice,20,Red);

if (check2==false){
for (int i=1; i<80;i++)
{
RefreshRates();
double askprice= MarketInfo(Symbol(),MODE_ASK);
bool check2 = OrderClose(ticket,inpOrderSize,askprice,20+i,Red);

if (check2==true){
bool initial=tradeDelay();
return;}}}}






   if (!newBar()) return;  //only trade on new bar
   

   if (!tradeDelay()) return;  //only trade if not traded on this bar
   
 
 // code below to trade continuous
   //if (ticket>0)
//{

///OrderSelect (ticket,SELECT_BY_TICKET);
///if (OrderCloseTime()!=0){
///ticket=0;}}

   
   
      
   
   
 
 

   
      if ((  price <maNow ) && (golong==true  )&& (ticket==0) && (LongMomentum()==true))  {
      inpStopLoss=iLow(Symbol(),Period(),1);
      
      
      inpTakeProfit= maNow;
                ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
                if (ticket=-1) ticket=0;
      
      
      }else
      if (( price >maNow  ) &&( golong==false  )&&(ticket==0)&& (LongMomentum()==false)) {
      inpStopLoss=iHigh(Symbol(),Period(),1);
      inpTakeProfit= maNow;
      ticket  =  orderOpen (ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
      if (ticket=-1) ticket=0;
      }
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
   
bool tradeDelay()

{

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
      
         stopLossPrice =  NormalizeDouble(stopLoss,Digits());
         takeProfitPrice =  NormalizeDouble(takeProfit,Digits());
      }else if (orderType==ORDER_TYPE_SELL){
         openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice =  NormalizeDouble(stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(takeProfit,Digits());
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}

bool LongMomentum (){
      bool longMom;
      int currentTf = Period ();
      int confirmTf = currentTf*3;
      double momNow= iMACD (Symbol(),confirmTf,5,20,30,PRICE_CLOSE,MODE_MAIN,0);
      double momB4= iMACD (Symbol(),confirmTf,5,20,30,PRICE_CLOSE,MODE_MAIN,1);
      if (momNow>momB4) longMom= true;
      else longMom=false;
      return (longMom);
      }
            