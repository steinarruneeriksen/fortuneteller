#!/bin/sh
# Runs the data relay  

java  -Dlog4j.configuration=file:///home/ustaudinger/work/p2-trunk/p2/src/main/resources/log4jconfigs/quoterecorder/log4j.xml  -classpath target/activequant-p2-1.3-SNAPSHOT-jar-with-dependencies.jar:target/ -DJMS_HOST=192.168.0.103 -DJMS_PORT=7676 -DARCHIVE_BASE_FOLDER=/var/www/archive2 org.activequant.util.TradeIndicationRecorder

