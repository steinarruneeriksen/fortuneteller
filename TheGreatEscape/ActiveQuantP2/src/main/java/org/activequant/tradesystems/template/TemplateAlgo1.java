package org.activequant.tradesystems.template;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.activequant.container.report.SimpleReport;
import org.activequant.core.domainmodel.data.Quote;
import org.activequant.optimization.domainmodel.AlgoConfig;
import org.activequant.tradesystems.AlgoEnvironment;
import org.activequant.tradesystems.BasicTradeSystem;
import org.activequant.util.FinancialLibrary2;
import org.activequant.util.tools.ArrayUtils;

public class TemplateAlgo1 extends BasicTradeSystem {

	private List<Quote> quoteList = new ArrayList<Quote>();
	private Quote formerQuote;
	private int period1, period2; 
	private double mpOld, p1Old, p2Old; 
	

	private List<Double> lows = new ArrayList<Double>();
	private List<Double> highs = new ArrayList<Double>();
	private List<Double> opens = new ArrayList<Double>();
	private List<Double> closes = new ArrayList<Double>();

	private double open, high, low, close;

	int formerPosition = 0;

	int quoteUpdateCount = 0;
	boolean shortStopped = false;
	boolean longStopped = false;

	@Override
	public boolean initialize(AlgoEnvironment algoEnv, AlgoConfig algoConfig) {
		super.initialize(algoEnv, algoConfig);
		period1 = (Integer) algoConfig.get("period1");
		period2 = (Integer) algoConfig.get("period2");
		System.out.printf("Initialized with %d, %d\n", period1, period2);
		return true;
	}

	@Override
	public void onQuote(Quote quote) {
		double currentPosition = 0.000;
		if (getAlgoEnv().getBrokerAccount().getPortfolio().hasPosition(
				quote.getInstrumentSpecification())) {
			currentPosition = getAlgoEnv().getBrokerAccount().getPortfolio()
					.getPosition(quote.getInstrumentSpecification())
					.getQuantity();
		}

		System.out.print(".");
	

		if (formerQuote != null) {
			if ((quote.getBidPrice() == formerQuote.getBidPrice() && quote
					.getAskPrice() == formerQuote.getAskPrice())
					|| (quote.getBidPrice() == Quote.NOT_SET || quote
							.getAskPrice() == Quote.NOT_SET))
				return;
		}
		System.out.print("+");
		formerQuote = quote; 

		// only 100% sane quotes ...
		if (quote.getBidPrice() == Quote.NOT_SET
				|| quote.getAskPrice() == Quote.NOT_SET)
			return;

		quoteUpdateCount++;

		// aggregating five quotes into one candle (non-time discrete)
		if (quoteUpdateCount == 5) {
			System.out.println("New OHLC dataset");
			quoteUpdateCount = 0;
			if (open != 0) {
				lows.add(low);
				opens.add(open);
				highs.add(high);
				closes.add(close);
			}
			open = quote.getMidpoint();
			close = quote.getMidpoint();
			high = 0;
			low = Double.MAX_VALUE;
		}

		if (quote.getMidpoint() > high)
			high = quote.getMidpoint();
		if (quote.getMidpoint() < low)
			low = quote.getMidpoint();
		close = quote.getMidpoint();

		if(quoteUpdateCount!=5) 
			return;

		// slice ..
		if (opens.size() > (Math.max(period1, period2) + 2)) {
			opens.remove(0);
			highs.remove(0);
			lows.remove(0);
			closes.remove(0);
		}

		Collections.reverse(opens);
		Collections.reverse(highs);
		Collections.reverse(lows);
		Collections.reverse(closes);

		double[] opensArray = ArrayUtils.convert(opens);
		double[] highsArray = ArrayUtils.convert(highs);
		double[] lowsArray = ArrayUtils.convert(lows);
		double[] closesArray = ArrayUtils.convert(closes);

		Collections.reverse(opens);
		Collections.reverse(highs);
		Collections.reverse(lows);
		Collections.reverse(closes);
		// log.info("Opens: " + opens.size());
		if (opens.size() < (Math.max(period1, period2) + 1))
		{
			System.out.println("Need "+ (Math.max(period1, period2)+1 - opens.size())+ " additional OHLCs.");
			return;
		}

		double p1 = FinancialLibrary2.WMA(period1, closesArray, 0);
		double p2 = FinancialLibrary2.WMA(period2, closesArray, 0);

		double mp = quote.getMidpoint();
		String crossing1 = ""; 
		String crossing2 = ""; 
		if(p1>0.0)
		{
			if(p1>p2 && p1Old < p2Old)
			{
				crossing1 = "LONG";
			}
			else if(p1<p2 && p1Old>p2Old)
			{
				crossing1 = "SHORT";
			}
		}	

		System.out.printf("\n(%s) \tBid/Ask: %f/%f \tMP: %f \tWMA1: %f \tWMA2: %f\tC1: %s\n", new Date().toString(), quote.getBidPrice(), quote.getAskPrice(), mp, p1, p2, crossing1);
		mpOld = mp; 
		p1Old = p1; 
		p2Old = p2; 	

	}

	public void populateReport(SimpleReport report) {
	}

	@Override
	public void forcedTradingStop() {

		// // log.info("Forced liquidation");
		quoteList.clear();
		if (formerQuote != null)
			setTargetPosition(formerQuote.getTimeStamp(), formerQuote
					.getInstrumentSpecification(), 0, 0.0);
		formerQuote = null;

		lows.clear();
		opens.clear();
		highs.clear();
		closes.clear();

	}

}
