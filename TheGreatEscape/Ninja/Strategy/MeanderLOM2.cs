#region Using declarations
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Data;
using NinjaTrader.Indicator;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Strategy;
using System.Collections;
#endregion

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    /// <summary>
    /// Enter the description of your strategy here
    /// </summary>
    [Description("Enter the description of your strategy here")]
    public class MeanderLOM2 : Strategy
    {
        #region Variables
		
		
		private int		target1			= 5;

		private int lots=1;
        // Wizard generated variables
		private LocalOrderManager m_OrderManager;
        private int maLen = 75; // Default setting for RSI_Period
		private int ticksDiff=1;
		private bool useAtrEntry=true;
		private bool useHighLowEntry=false;
		private int entryTrendSignal=2;
		private int SL = 30; // Default setting for RSI_Period
		private int maxprofit = 1000; // Max profit before halt strategy
		private int maxloss = 1500; // Max loss before halt strategy
		private double priorTradesCumProfit=0;
		//private int PT = 25; // Default setting for RSI_Period

        // User defined variables (add any user defined variables below)
        #endregion
		
		protected override void OnStartUp()
        {



		}
		protected override void OnOrderUpdate(IOrder order)
		{
				m_OrderManager.OnOrderUpdate(order);
		}
		
		protected override void OnExecution(IExecution execution)
		{
		m_OrderManager.OnExecution(execution);
		}
		
		protected override void OnMarketData(MarketDataEventArgs e)
		{    
				m_OrderManager.OnMarketData( e);
		}
        /// <summary>
        /// This method is used to configure the strategy and is called once before any strategy method is called.
        /// </summary>
        protected override void Initialize()
        {
            CalculateOnBarClose = false;
			Unmanaged = true;
			ExitOnClose=false;
			Enabled=true;
			
			//SetStopLoss(CalculationMode.Ticks,SL);
 			m_OrderManager=new LocalOrderManager(this,0);              
			m_OrderManager.SetDebugLevels(10,1,false,0);     // Optional      
			m_OrderManager.SetStatsBoxVisable(true) ;           // Optional     (Default is true)
			for (int i=0;i<lots;i++)
				m_OrderManager.SetAutoSLPTTicks(SL,target1,i);         // Optional			
			

			
        }
        public   double TicksProfit(double price) {
            double ppoints = Position.GetProfitLoss(price, PerformanceUnit.Points);
            double tickProfit = ppoints / TickSize;
			return tickProfit;
        }
		
        /// <summary>
        /// Called on each bar update event (incoming tick)
        /// </summary>
		/// 
		/// 

		/// '
		///
		double stdDevHigh=0;
		double stdDevLow=0;
        protected override void OnBarUpdate()
        {
			
				// At the start of a new session
			if (Bars.FirstBarOfSession && FirstTickOfBar)
			{
				priorTradesCumProfit = Performance.AllTrades.TradesPerformance.Currency.CumProfit;
			}

			if ((Performance.AllTrades.TradesPerformance.Currency.CumProfit - priorTradesCumProfit) <= -maxloss)
			{			
				for(int i=0;i<lots;i++){
				if (MarketPosition.Flat!=m_OrderManager.GetMarketPosition(i))
					m_OrderManager.ExitMarket(i);		
				}
				return;
			}
			if (CurrentBar < 20)
				return;

			double v1=SMA(Close, maLen)[0];
			double v2=SMA(Close, maLen)[1];
			if (EntryTrendSignal==2){
				v1=Close[0];
				v2=Open[0];
			}
			if (EntryTrendSignal==3){
				v2=Close[0];
				v1=Open[0];
			}
			
			int direction=0;
			if (v1>v2){
				direction=1;
			}	
			if (v1<=v2){
				direction=-1;
			}
			for (int position=0;position<lots;position++){
				if (direction!=0 && MarketPosition.Flat==m_OrderManager.GetMarketPosition(position)){
					if (direction==1){
						EnterLongLim(position);
					}	
					if (direction==-1){
						EnterShortLim(position);
					}	
				}	
				
				if (MarketPosition.Long==m_OrderManager.GetMarketPosition(position)){
					EnterShortLim(position);
		
				}	
				if (MarketPosition.Short==m_OrderManager.GetMarketPosition(position)){				
					EnterLongLim(position);
				}		
			}
        }
		//double trigglim=(Close[0]+LimitOrderOffset*TickSize);
		private void EnterShortLim(int position){
			double price=High[1] + ticksDiff*TickSize;//this.GetCurrentBid();
			if (UseHighLowEntry==false)price=Close[1] + ticksDiff*TickSize;//this.GetCurrentBid();
			if (this.GetCurrentBid()>0 && price<this.GetCurrentBid())
				price=this.GetCurrentAsk();

		     m_OrderManager.GoShortLimit((int)1,(double)price,(int)position) ; 
			
		}
		private void EnterLongLim(int position){
			//double price=this.GetCurrentAsk();'
			double price=Low[1] - ticksDiff*TickSize;
			if (UseHighLowEntry==false)price=Close[1] - ticksDiff*TickSize;
			if (this.GetCurrentAsk()>0 && price>this.GetCurrentAsk())
				price=this.GetCurrentBid();

			m_OrderManager.GoLongLimit((int)1,(double)price,(int)position) ; // Place Limit Order at "m_Limit"

		}			
		
        #region Properties
        [Description("")]
        [GridCategory("Parameters")]
        public int StopLoss
        {
            get { return SL; }
            set { SL = Math.Max(1, value); }
        }	
		 [Description("lots")]
        [GridCategory("Parameters")]
        public bool UseAtrEntry
        {
            get { return useAtrEntry; }
            set { useAtrEntry = value; }
        }	
		 [Description("UseHighLowEntry")]
        [GridCategory("Parameters")]
        public bool UseHighLowEntry
        {
            get { return useHighLowEntry; }
            set { useHighLowEntry = value; }
        }
		
		 [Description("lots")]
        [GridCategory("Parameters")]
        public int Lots
        {
            get { return lots; }
            set { lots = Math.Max(1, value); }
        }		
        [Description("")]
        [GridCategory("Parameters")]
        public int MaLength
        {
            get { return maLen; }
            set { maLen = Math.Max(1, value); }
        }
        [Description("")]
        [GridCategory("Parameters")]
        public int EntryTrendSignal
        {
            get { return entryTrendSignal; }
            set { entryTrendSignal = Math.Max(1, value); }
        }
		
        [Description("")]
        [GridCategory("Parameters")]
        public int TicksDiff
        {
            get { return ticksDiff; }
            set { ticksDiff = value; }
        }		
		
		
		[Description("target1")]
        [Category("Parameters")]
        public int PT
        {
            get { return target1; }
            set { target1 = Math.Max(1, value); }
        }

		[Description("Maximum profit.")]
		[Category("Parameters")]
		[Gui.Design.DisplayName("\t\t\tMax Profit")]
		public int MaxProfit
		{
		get { return maxprofit; }
		set { maxprofit = Math.Max(1, value); }
		}

		[Description("Maximum loss (enter positive value!).")]
		[Category("Parameters")]
		[Gui.Design.DisplayName("\t\t\tMax Loss")]
		public int MaxLoss
		{
		get { return maxloss; }
		set { maxloss = Math.Max(1, value); }
		}		
		
		
        #endregion
    }
}
