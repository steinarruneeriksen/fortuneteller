#!/bin/sh
# Runs the data relay  
java  -Dlog4j.configuration=file:///home/ustaudinger/work/p2-trunk/p2/src/main/resources/log4jconfigs/candlerelay/log4j.xml  -classpath target/activequant-p2-1.3-SNAPSHOT-jar-with-dependencies.jar:target/ -DJMS_HOST=localhost -DJMS_PORT=7676 -DSPECIFICATION_ID=85 org.activequant.util.CandleSocketRelay
