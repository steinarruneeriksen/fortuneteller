#!/bin/sh
java -cp target/activequant-p2-1.3-SNAPSHOT:target/ -DJMS_HOST=localhost -DJMS_PORT=7676 -DARCHIVE_BASE_FOLDER=/var/www/archive2 org.activequant.util.QuoteRecorder &
#java -classpath target/activequant-p2-1.3-SNAPSHOT-jar-with-dependencies.jar:target/ -DJMS_HOST=localhost -DJMS_PORT=7676 -DARCHIVE_BASE_FOLDER=/var/www/archive2 org.activequant.util.DataRelay &
#java -classpath target/activequant-p2-1.3-SNAPSHOT-jar-with-dependencies.jar:target/ -DJMS_HOST=localhost -DJMS_PORT=7676 -DARCHIVE_BASE_FOLDER=/var/www/archive2 org.activequant.util.RudeCandleRecorder &


