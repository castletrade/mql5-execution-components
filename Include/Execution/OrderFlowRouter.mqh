//+------------------------------------------------------------------+
//|                                              OrderFlowRouter.mqh |
//|                                                 Castle Trade LLC |
//|                                       https://www.castletrade.co |
//+------------------------------------------------------------------+
#property copyright "Castle Trade LLC"
#property link      "https://www.castletrade.co"
#property strict

#include <Trade\Trade.mqh>

/**
 * @class COrderFlowRouter
 * @brief High-frequency order routing class utilizing asynchronous execution.
 */
class COrderFlowRouter
{
private:
   CTrade            m_trade;
   string            m_comment;
   ulong             m_magic;

public:
                     COrderFlowRouter(const ulong magic, const string comment);
                    ~COrderFlowRouter();

   bool              DispatchAsync(const ENUM_ORDER_TYPE type, const double volume, const double price, const double sl, const double tp);
   void              HandleRetcode(const uint retcode);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
COrderFlowRouter::COrderFlowRouter(const ulong magic, const string comment)
   : m_magic(magic),
     m_comment(comment)
{
   m_trade.SetExpertMagicNumber(m_magic);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
COrderFlowRouter::~COrderFlowRouter()
{
}

//+------------------------------------------------------------------+
//| Dispatches an order asynchronously to minimize execution latency |
//+------------------------------------------------------------------+
bool COrderFlowRouter::DispatchAsync(const ENUM_ORDER_TYPE type, const double volume, const double price, const double sl, const double tp)
{
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action       = TRADE_ACTION_DEAL;
   request.symbol       = _Symbol;
   request.volume       = volume;
   request.type         = type;
   request.price        = price;
   request.sl           = sl;
   request.tp           = tp;
   request.magic        = m_magic;
   request.comment      = m_comment;
   request.type_filling = SYMBOL_FILLING_FOK;
   request.deviation    = 10;

   if(!OrderSendAsync(request, result))
   {
      PrintFormat("[ROUTER]: Async dispatch failed for %s. Error: %d", EnumToString(type), GetLastError());
      return false;
   }

   HandleRetcode(result.retcode);
   return true;
}

//+------------------------------------------------------------------+
//| Processes trade server return codes with institutional precision |
//+------------------------------------------------------------------+
void COrderFlowRouter::HandleRetcode(const uint retcode)
{
   switch(retcode)
   {
      case TRADE_RETCODE_PLACED:
         Print("[ROUTER]: Order successfully placed in asynchronous queue.");
         break;
      case TRADE_RETCODE_DONE:
         Print("[ROUTER]: Order executed instantly.");
         break;
      case TRADE_RETCODE_REJECT:
         Print("[ROUTER ERR]: Trade server rejected the request.");
         break;
      case TRADE_RETCODE_INVALID:
         Print("[ROUTER ERR]: Invalid request parameters.");
         break;
      default:
         if(retcode != 0)
            PrintFormat("[ROUTER INFO]: Trade operation status code: %d", retcode);
         break;
   }
}
