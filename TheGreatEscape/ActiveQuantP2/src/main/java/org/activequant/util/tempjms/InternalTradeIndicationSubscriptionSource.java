package org.activequant.util.tempjms;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import org.activequant.core.domainmodel.InstrumentSpecification;
import org.activequant.core.domainmodel.data.TradeIndication;
import org.activequant.core.types.TimeFrame;
import org.activequant.data.retrieval.ITradeIndicationSubscriptionSource;
import org.activequant.data.retrieval.ISubscription;
import org.activequant.util.exceptions.SubscriptionException;
import org.activequant.util.pattern.events.IEventListener;
import org.activequant.util.tools.UniqueDateGenerator;

/**
 * internal class for quote subscriptions ...
 * ActiveQuant conformity requires to have a class for quote subscription sources ... 
 *
 * @author GhostRider
 * 
 */
public class InternalTradeIndicationSubscriptionSource implements ITradeIndicationSubscriptionSource {
	
	/**
	 * not 100% conform implementation ... but should work.
	 * 
	 * @author GhostRider
	 * 
	 */
	class Subscription implements ISubscription<TradeIndication> {

		@Override
		public void activate() throws SubscriptionException {
			// resend the current quote.
			isActive = true;

			// hardcode delaying by five milliseconds as the broker assigned id is needed for the paper broker .. 
			Timer myTimer = new Timer();
			TimerTask myTimerTask = new TimerTask() {
				public void run() {
					if (theQuoteSheet.containsKey(theSpec)) {
						TradeIndication myCurrentQuote = theQuoteSheet.get(theSpec);
						// rewrite the current quote time .. 
						myCurrentQuote.setTimeStamp(dateGenerator.generate(myCurrentQuote.getTimeStamp().getDate()));
						synchronized(theListeners) {
							for (IEventListener<TradeIndication> myListener : theListeners)
								myListener.eventFired(myCurrentQuote);
						}
					}
				}
			};
			myTimer.schedule(myTimerTask, 5);

		}

		@Override
		public void addEventListener(IEventListener<TradeIndication> arg0) {
			theListeners.add(arg0);
		}

		@Override
		public void cancel() throws SubscriptionException {
			theSubscriptions.remove(this);
		}

		@Override
		public InstrumentSpecification getInstrument() {
			return theSpec;
		}

		@Override
		public TimeFrame getTimeFrame() {
			return TimeFrame.TIMEFRAME_1_TICK;
		}

		@Override
		public boolean isActive() {
			return isActive;
		}

		@Override
		public void removeEventListener(IEventListener<TradeIndication> arg0) {
			theListeners.remove(arg0);
		}

		List<IEventListener<TradeIndication>> theListeners = Collections.synchronizedList(new ArrayList<IEventListener<TradeIndication>>());
		InstrumentSpecification theSpec;
		boolean isActive = false;
	}

	@Override
	@SuppressWarnings("unchecked")
	public ISubscription<TradeIndication>[] getSubscriptions() {
		ISubscription<TradeIndication>[] myRet = new ISubscription[theSubscriptions.size()];
		Iterator<ISubscription<TradeIndication>> myIt = theSubscriptions.values().iterator();
		for (int i = 0; i < theSubscriptions.size(); i++) {
			myRet[i] = (ISubscription<TradeIndication>) myIt.next();
		}
		return myRet;
	}

	public void distributeTradeIndication(TradeIndication aQuote) {
		// update the local quote sheet
		theQuoteSheet.put(aQuote.getInstrumentSpecification(), aQuote);

		// get the subscription ...
		Subscription mySubscription = (Subscription) theSubscriptions.get(aQuote.getInstrumentSpecification());
		if (mySubscription != null) {		
			synchronized(mySubscription.theListeners) {
				for (IEventListener<TradeIndication> myListener : mySubscription.theListeners)
					myListener.eventFired(aQuote);
			}
		}
	}

	@Override
	public ISubscription<TradeIndication> subscribe(InstrumentSpecification arg0) {
		if (theSubscriptions.containsKey(arg0))
			return theSubscriptions.get(arg0);
		Subscription mySub = new Subscription();
		mySub.theSpec = arg0;
		theSubscriptions.put(arg0, mySub);
		return mySub;
	}

	private HashMap<InstrumentSpecification, ISubscription<TradeIndication>> theSubscriptions = new HashMap<InstrumentSpecification, ISubscription<TradeIndication>>();
	private HashMap<InstrumentSpecification, TradeIndication> theQuoteSheet = new HashMap<InstrumentSpecification, TradeIndication>();
	private UniqueDateGenerator dateGenerator = new UniqueDateGenerator();
}
