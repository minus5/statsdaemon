#!/bin/bash
set -e

# Integertion test for nsqd.
# Starting nsqd, statsdeamon and nsq_tail.
# Sending some counters to statsdeamon and expecting to read them with nsq_tail.

echo starting nsqd
mkdir -p ./tmp/nsqd
nsqd -broadcast-address=127.0.0.1 -data-path=./tmp/nsqd -max-msg-size=10485760 > /dev/null 2>&1 &
PID1=$!

echo starting statsdeamon
go build
./statsdaemon -graphite="-" -nsqd-tcp-address=localhost:4150 -debug &
PID2=$!

echo starting nsq_tail
nsq_tail -topic=stats -nsqd-tcp-address=localhost:4150 &
PID3=$!

sleep 2
echo "sending some counters"
echo -n "gaugor:312|g"           >/dev/udp/localhost/8125
echo -n "gaugor:-10|g"           >/dev/udp/localhost/8125
echo -n "gaugor:+4|g"            >/dev/udp/localhost/8125
echo -n "glork:320|ms"           >/dev/udp/localhost/8125
echo -n "glork:310|ms"           >/dev/udp/localhost/8125
echo -n "glork:300|ms"           >/dev/udp/localhost/8125
echo -n "glork:320|ms|@0.1"      >/dev/udp/localhost/8125
echo -n "uniques:765|s"          >/dev/udp/localhost/8125

sleep 12
echo clean up, killing $PID1 $PID2 $PID3
kill $PID1 $PID2 $PID3
rm -rf ./tmp/nsqd

sleep 1
echo finished
