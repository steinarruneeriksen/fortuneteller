/****

 activequant - activestocks.eu

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


 contact  : contact@activestocks.eu
 homepage : http://www.activestocks.eu

 ****/
package org.activequant.util;

import java.util.ArrayList;
import java.util.List;

import org.activequant.core.domainmodel.InstrumentSpecification;
import org.activequant.core.domainmodel.data.Quote;
import org.activequant.dao.ISpecificationDao;
import org.activequant.data.retrieval.IQuoteSubscriptionSource;
import org.activequant.data.retrieval.ISubscription;
import org.activequant.util.spring.ServiceLocator;

/**
 * Simple class that subscribes for a live feed and puts the incoming events
 * (quotes) in the database.
 * <p>
 * Required properties are :<br>
 * - IQuoteSubscriptionSource instance<br>
 * - QuoteDao<br>
 * 
 * 
 * <p>
 * Use {@link #getFlushTimeout() flushTimeout} to determine how often the
 * collected data is flushed out to the database. Default value is 1000 millis.
 * <br>
 * <b>History:</b><br>
 * - [14.08.2007] Created (GhostRider)<br>
 * - [26.10.2007] Added fifo queueing. Some cleanup (Mike Kroutikov)<br>
 * - [01.04.2010] Added vendor identifier, adapted it for P2 (GhostRider)<br>
 * 
 * @author GhostRider
 * @author Mike Kroutikov
 */
public class QuoteRecorder extends MarketDataEntityRecorder<Quote> {

	private IQuoteSubscriptionSource source;
	private ISpecificationDao specDao;
	private String vendorIdentifier; 

	/**
	 * Injecter for the specification dao.
	 * 
	 * @param specDao
	 */
	public void setSpecDao(ISpecificationDao specDao) {
		this.specDao = specDao;
	}

	/**
	 * Quote event source.
	 * 
	 * @return quote event source.
	 */
	public IQuoteSubscriptionSource getSource() {
		return source;
	}

	/**
	 * can be used to drill down on specific vendors ... 
	 * @return
	 */
	public String getVendorIdentifier() {
		return vendorIdentifier;
	}

	public void setVendorIdentifier(String vendorIdentifier) {
		this.vendorIdentifier = vendorIdentifier;
	}
	
	/**
	 * Sets quote event source.
	 * 
	 * @param quoteSource
	 *            quote event source.
	 */
	public void setSource(IQuoteSubscriptionSource source) {
		this.source = source;
	}

	@Override
	protected ISubscription<Quote> subscribe(InstrumentSpecification spec) throws Exception {
		return source.subscribe(spec);
	}

	/**
	 * Method that loads the to-be-recorded instruments from the database and subscribes to them. 
	 * @throws Exception 
	 */
	protected void buildSubscriptions() throws Exception{
		InstrumentSpecification[] specs = specDao.findAll();
		
		List<InstrumentSpecification> specsList = new ArrayList<InstrumentSpecification>();
		for(InstrumentSpecification spec : specs)
		{
			if(vendorIdentifier!=null)
			{
				if(spec.getVendor().equals(vendorIdentifier))
					specsList.add(spec);
			}
			else
				specsList.add(spec);
		}
		
		log.info("Subscribing to "+specsList.size()+" specs.");
		super.setInstrumentsToSubscribeTo(specsList.toArray(new InstrumentSpecification[]{}));		
	}
	
	/**
	 * Overrides record function to build dynamically the list of instruments to which to subscribe to.
	 */
	@Override
	public void record() throws Exception {
		buildSubscriptions();
		super.record();
	}

	/**
	 * Starter. By default uses the following resource for configuration:
	 * 
	 * <pre>
	 * applications / quoterecorder / factory.xml
	 * </pre>
	 * 
	 * You can pass any configuration file by specifying it as this program's
	 * first (and only) parameter.
	 * 
	 * @param args
	 *            parameters.
	 */
	public static void main(String[] args) {
		try {
			if (args.length == 0) {
				ServiceLocator.instance("data/quoterecorder.xml").getContext();
			} else {
				ServiceLocator.instance(args[0]).getContext();
			}
		} catch (Exception x) {
			x.printStackTrace();
			System.exit(0);
		}
	}


}
