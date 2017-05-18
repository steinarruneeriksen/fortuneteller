package org.activequant.tradesystems.oneminutebased;

import java.util.ArrayList;
import java.util.List;

import org.activequant.core.types.Tuple;
import org.activequant.optimization.domainmodel.AlgoConfig;
import org.activequant.optimization.domainmodel.AlgoEnvConfig;
import org.activequant.util.tools.ArrayUtils;

public class AlgoEnvConfigSample extends AlgoEnvConfig {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public AlgoEnvConfigSample()
	{
		List<Tuple<Integer, Integer>> startStopTimes = new ArrayList<Tuple<Integer, Integer>>();
		// UTC !!!
		startStopTimes.add(new Tuple<Integer, Integer>(0, 235959));
		this.setStartStopTimes(startStopTimes);
		
		// set, to which instrument to subscribe to. 
		// local instrument id, can differ across machines. 
		setInstruments(ArrayUtils.asList(new Integer[] { 84 }));
		
		// create algo config and set it. 
		AlgoConfig ac = new AlgoConfig();
		ac.setAlgorithm("org.activequant.tradesystems.oneminutebased.OneMinute1");
		ac.put("period1", 30);
		ac.put("period2", 100);
		
		setAlgoConfig(ac);
	}
	
}
