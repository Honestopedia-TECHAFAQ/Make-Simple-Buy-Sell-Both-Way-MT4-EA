//+------------------------------------------------------------------+
//|                                                  SimpleMartingale|
//|                    Copyright 2024, MetaQuotes Software Corp.     |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input double LotSize = 0.01;          // Initial lot size
input double TP = 50;                 // Take Profit in pips
input double Multiplier = 2;          // Martingale multiplier

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static bool buyOrderOpened = false;
   static bool sellOrderOpened = false;
   static double initialPrice = 0;
   double lotSizeToUse = LotSize;
   
   // Check if new candle formed
   if (Time[0] != Time[1])
   {
      // Close any open orders
      CloseOpenOrders();
      
      // Reset flags
      buyOrderOpened = false;
      sellOrderOpened = false;
      
      // Reset initial price
      initialPrice = 0;
   }
   
   // Check if initial price is not set
   if (initialPrice == 0)
      initialPrice = Ask;
   
   // Check if no buy order opened and no sell order opened
   if (!buyOrderOpened && !sellOrderOpened)
   {
      // Open buy order
      if (OrderSend(Symbol(), OP_BUY, lotSizeToUse, Ask, 3, 0, 0, "", 0, 0, clrGreen))
         buyOrderOpened = true;
   }
   // Check if buy order opened and take profit reached
   else if (buyOrderOpened && (Ask - initialPrice) >= TP * Point)
   {
      // Close buy order
      if (OrderSelect(0, SELECT_BY_POS) && OrderType() == OP_BUY)
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
      
      // Open sell order with martingale
      if (OrderSend(Symbol(), OP_SELL, lotSizeToUse, Bid, 3, 0, 0, "", 0, 0, clrRed))
         sellOrderOpened = true;
   }
   // Check if no sell order opened and no buy order opened
   else if (!sellOrderOpened && !buyOrderOpened)
   {
      // Open sell order
      if (OrderSend(Symbol(), OP_SELL, lotSizeToUse, Bid, 3, 0, 0, "", 0, 0, clrRed))
         sellOrderOpened = true;
   }
   // Check if sell order opened and take profit reached
   else if (sellOrderOpened && (initialPrice - Bid) >= TP * Point)
   {
      // Close sell order
      if (OrderSelect(0, SELECT_BY_POS) && OrderType() == OP_SELL)
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrGreen);
      
      // Open buy order with martingale
      if (OrderSend(Symbol(), OP_BUY, lotSizeToUse * Multiplier, Ask, 3, 0, 0, "", 0, 0, clrGreen))
         buyOrderOpened = true;
   }
  }

//+------------------------------------------------------------------+
//| Close all open orders                                            |
//+------------------------------------------------------------------+
void CloseOpenOrders()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
      {
         if (OrderType() <= OP_SELL)
            OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
         else
            OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrGreen);
      }
   }
}
//+------------------------------------------------------------------+
