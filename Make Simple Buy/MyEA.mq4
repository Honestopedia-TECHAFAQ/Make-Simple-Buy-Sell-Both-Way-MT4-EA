//+------------------------------------------------------------------+
//|                                                     MyEA.mq4     |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input double lotSize = 0.01; // Initial lot size
input int takeProfit = 50; // Take profit in pips
input int stopLoss = 0; // Stop loss in pips (0 for no stop loss)
input double martingaleMultiplier = 2; // Martingale multiplier
input int slippage = 3; // Maximum allowed slippage

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization code goes here
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Deinitialization code goes here
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Check if a new candle has formed
   if (Time[0] != Time[1])
     {
      // Close any existing orders
      CloseOrders();

      // Open new orders
      OpenOrders();
     }
  }

// Function to close all open orders
void CloseOrders()
  {
   for (int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), slippage, clrNONE) == false)
           {
            Print("Error closing order: ", GetLastError());
           }
        }
     }
  }

// Function to open new orders
void OpenOrders()
  {
   // Open buy order
   double buyPrice = Ask;
   int buyTicket = OrderSend(OrderType(), lotSize, buyPrice, slippage, 0, 0, 0, "Buy Order", 0, 0, clrNONE);
   if (buyTicket > 0)
     {
      // Set take profit and stop loss
      if (OrderModify(buyTicket, buyPrice + takeProfit * Point, 0, 0, 0) == false)
        {
         Print("Error modifying buy order: ", GetLastError());
        }
      if (stopLoss > 0)
        {
         if (OrderModify(buyTicket, 0, buyPrice - stopLoss * Point, 0, 0) == false)
           {
            Print("Error modifying buy order stop loss: ", GetLastError());
           }
        }
     }

   // Open sell order
   double sellPrice = Bid;
   int sellTicket = OrderSend(OP_SELL, lotSize, sellPrice, slippage, 0, 0, 0, "Sell Order", 0, 0, clrNONE);
   if (sellTicket > 0)
     {
      // Set take profit and stop loss
      if (OrderModify(sellTicket, sellPrice - takeProfit * Point, 0, 0, 0) == false)
        {
         Print("Error modifying sell order: ", GetLastError());
        }
      if (stopLoss > 0)
        {
         if (OrderModify(sellTicket, 0, sellPrice + stopLoss * Point, 0, 0) == false)
           {
            Print("Error modifying sell order stop loss: ", GetLastError());
           }
        }
     }
  }
