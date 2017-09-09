//+------------------------------------------------------------------+
//|                                                        Hindi.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Tan Yan Han"
#property version   "1.00"
#property strict

#include <hanlib.mqh>

//External Variables
extern bool DynamicLotSize = false;
extern double EquityPercent = 10;
extern int DurationToHold = 10;

int TicketTrack[10]={0};
datetime DateTrack[10];
int pointer = 0;

datetime CurrentTimeStamp;
int SellTicket;
int BuyTicket;
int SecondsDay = 86400;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  Print("EA Activated and Ongoing");
   CurrentTimeStamp = Time[0];
   for(int i=0; i<OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderMagicNumber()== 0002)
      {
         TicketTrack[pointer]=OrderTicket();
         DateTrack[pointer]=OrderOpenTime()+13*SecondsDay;
         Print(" Open Orders - "+IntegerToString(TicketTrack[pointer])+", "+TimeToStr(DateTrack[pointer])+" ");
         pointer++;
      }
   }
 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print(" EA Deactivated ");
   for(int i=0;i<pointer;i++)
   {
      Print(" Order Ticket remains open "+IntegerToString(TicketTrack[i])+", Close on :"+TimeToStr(DateTrack[i])+" ");
   }
   return;  
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bool NewBar;
   if(CurrentTimeStamp != Time[0])
   {
      CurrentTimeStamp=Time[0];
      NewBar=true;
   }
   else NewBar = false;
   
   if( NewBar==true)
   { 
      //Print("New Bar detected - "+IntegerToString(pointer-1)+" outstanding trades");// only for live trading
      //Close 10 Days Old Orders
      for(int i=0;i<pointer;i++)
      {
         if(iTime(NULL,0,0) > DateTrack[i])  //trade context cannot have any outstanding pending orders
         {
            OrderSelect(TicketTrack[i],SELECT_BY_TICKET);
            if(OrderType() == OP_BUY)
            {
               CloseBuyOrder(Symbol(),TicketTrack[i],5);
            }
            else CloseSellOrder(Symbol(),TicketTrack[i],5);
            
            for(int j=i;j<pointer-1;j++)
            {
               TicketTrack[j]=TicketTrack[j+1];
               DateTrack[j]=DateTrack[j+1];
            }
            pointer--;
            i--;
         }
      }     
      if(CheckNHarami() == true  && OrdersTotal() < 3)
      {
      //Open Sell Order
      double StopLoss = (iHigh(NULL,0,1)-iClose(NULL,0,1))*10000;
      double LotSize = CalcLotSize(DynamicLotSize,EquityPercent, round(StopLoss), 0.1);
      LotSize = VerifyLotSize(LotSize);
      int Slippage = GetSlippage(Symbol(), 5);
      SellTicket = OpenSellOrder(Symbol(),LotSize,Slippage,0002);
      TicketTrack[pointer]=SellTicket;
      DateTrack[pointer]=CurrentTimeStamp + 13*SecondsDay;
      pointer++;
      
      OrderSelect(SellTicket,SELECT_BY_TICKET);
      double OpenPrice = OrderOpenPrice();
      double SellStopLoss = iHigh(NULL,0,1);
      SellStopLoss = AdjustAboveStopLevel(Symbol(),SellStopLoss);
      double SellTakeProfit = CalcSellTakeProfit(Symbol(), 800, OpenPrice );
      bool Modified = AddStopProfit(SellTicket, SellStopLoss, SellTakeProfit); 
      }
      
      if(CheckPHarami() == true && OrdersTotal() < 3)
      {
      //Open Buy Order
      double StopLoss = (iClose(NULL,0,1)-iLow(NULL,0,1))*10000;
      double LotSize = CalcLotSize(DynamicLotSize,EquityPercent, round(StopLoss), 0.1);
      LotSize = VerifyLotSize(LotSize);
      int Slippage = GetSlippage(Symbol(), 5);
      BuyTicket = OpenBuyOrder(Symbol(),LotSize,Slippage,0002);
      TicketTrack[pointer]=BuyTicket;
      DateTrack[pointer]=CurrentTimeStamp+13*SecondsDay;
      pointer++;
      
      OrderSelect(BuyTicket,SELECT_BY_TICKET);
      double OpenPrice = OrderOpenPrice();
      double BuyStopLoss = iLow(NULL,0,1);
      BuyStopLoss = AdjustBelowStopLevel(Symbol(),BuyStopLoss);
      double BuyTakeProfit = CalcBuyTakeProfit(Symbol(), 800, OpenPrice );
      bool Modified = AddStopProfit(BuyTicket, BuyStopLoss, BuyTakeProfit); 
      }
   }
}
//+------------------------------------------------------------------+
bool CheckNHarami()
{
   double Diff1,Diff2,Diff0;
   Diff0=iClose(NULL,0,3)-iOpen(NULL,0,3);
   Diff1=iClose(NULL,0,2)-iOpen(NULL,0,2);
   Diff2=iClose(NULL,0,1)-iOpen(NULL,0,1);
   if(Diff1>0.0010  && Diff2<0.0 && Diff1+Diff2< 0.0 && Diff0>=0.0 && Diff2/Diff1 >= -6)
   {  
       return true;
   }
   else return false;
   
}
bool CheckPHarami()
{
   double Diff1,Diff2,Diff0;
   Diff0=iClose(NULL,0,3)-iOpen(NULL,0,3);
   Diff1=iClose(NULL,0,2)-iOpen(NULL,0,2);
   Diff2=iClose(NULL,0,1)-iOpen(NULL,0,1);
   if(Diff1<-0.0010 && Diff2>0.0  &&  Diff1+Diff2> 0.0 && Diff0<=0.0)
   {  
       return true;
   }
   else return false;
   
}