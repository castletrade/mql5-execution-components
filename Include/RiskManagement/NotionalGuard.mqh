//+------------------------------------------------------------------+
//|                                                NotionalGuard.mqh |
//|                                                 Castle Trade LLC |
//|                                       https://www.castletrade.co |
//+------------------------------------------------------------------+
#property copyright "Castle Trade LLC"
#property link      "https://www.castletrade.co"
#property strict

/**
 * @class CNotionalGuard
 * @brief Institutional risk management class for exposure and margin monitoring.
 */
class CNotionalGuard
{
private:
   double            m_max_notional_exposure;
   double            m_min_margin_level;
   string            m_symbol;

public:
                     CNotionalGuard(const string symbol, const double max_notional, const double min_margin);
                    ~CNotionalGuard();

   bool              CheckRiskThresholds();
   double            GetCurrentNotional();
   double            GetMarginLevel();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CNotionalGuard::CNotionalGuard(const string symbol, const double max_notional, const double min_margin)
   : m_symbol(symbol),
     m_max_notional_exposure(max_notional),
     m_min_margin_level(min_margin)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CNotionalGuard::~CNotionalGuard()
{
}

//+------------------------------------------------------------------+
//| Verifies if trading is permissible under current risk params     |
//+------------------------------------------------------------------+
bool CNotionalGuard::CheckRiskThresholds(void)
{
   double current_notional = GetCurrentNotional();
   double current_margin   = GetMarginLevel();

   if(current_notional > m_max_notional_exposure)
   {
      PrintFormat("[RISK]: Notional exposure (%.2f) exceeds maximum allowed (%.2f)", current_notional, m_max_notional_exposure);
      return false;
   }

   if(current_margin < m_min_margin_level && current_margin > 0)
   {
      PrintFormat("[RISK]: Margin level (%.2f) below safety threshold (%.2f)", current_margin, m_min_margin_level);
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Calculates current total notional exposure in base currency      |
//+------------------------------------------------------------------+
double CNotionalGuard::GetCurrentNotional(void)
{
   double total_volume = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            total_volume += PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   
   double contract_size = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double market_price  = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   return total_volume * contract_size * market_price;
}

//+------------------------------------------------------------------+
//| Retrieves account margin level                                   |
//+------------------------------------------------------------------+
double CNotionalGuard::GetMarginLevel(void)
{
   return AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
}
