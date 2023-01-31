#!/usr/bin/env bash

server="$1"
shift 1
zookeeper="$1"
shift 1
properties_file="$1"
shift 1
topic="$1"
shift 1
new_rf="$@"


if [[ -z "$server" ]] | [[ -z "$zookeeper" ]] | [[ -z "$properties_file" ]] | [[ -z "$topic" ]] | [[ -z "$new_rf" ]]; then
	echo "Usage $0 <broker:port> <zookeeper:port> <absolute path to properties file> <topic> <replica broker ID list>"
	exit 1
fi

RES=$(kafka-topics --bootstrap-server ${server} --command-config ${properties_file} --describe --topic ${topic} | grep Replicas:)

partitions=$(echo "$RES"| wc -l)

echo "RES is $RES"


DOCUMENT='
{"version":1,
 "partitions":[
'

PARTITIONS=""

for p in $(seq 0 $(( $partitions - 1 ))); do

	if [ -n "$PARTITIONS" ]; then
		PARTITIONS="${PARTITIONS}, "
	fi
	PARTITIONS="${PARTITIONS}{\"topic\":\"$topic\",\"partition\": $p,"
	current_leader=$(echo "$RES" | grep -E "Partition: $p\s+" | awk '{ print $6 }')
	replicas="[$current_leader"
	for r in $new_rf; do
		if [ $current_leader != $r ]; then
			replicas="${replicas},$r"
		fi
	done
	replicas="${replicas}]"

	PARTITIONS="${PARTITIONS} \"replicas\": $replicas }"
done

FINAL_DOC="${DOCUMENT}${PARTITIONS}]}"

echo "$FINAL_DOC" > "${topic}_reassign.$$.json"

echo "Will make the following reassignment choices:"
echo "$FINAL_DOC"
echo ""

read -p "Press enter to execute the increase in replication factor..." REPLY
kafka-reassign-partitions --zookeeper $zookeeper --reassignment-json-file  "${topic}_reassign.$$.json" --execute


sleep 2
echo "Verifying that reassignment has completed...."
CMD="kafka-reassign-partitions --zookeeper $zookeeper --reassignment-json-file  ${topic}_reassign.$$.json --verify"


while true
do
	RES=$($CMD)
	if [ $(echo $RES | grep 'still in progress'| echo $?) -ne 0 ]; then
		echo "Reassignment of $topic is still in progress. Waiting..."
		sleep 5
	else
		echo "Reassignment completed."
		break
	fi
done

printf "\n\n\n\n\n"
