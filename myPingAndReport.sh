#!/bin/bash

# TODO: fill in value for the REST_API_URL
# It is identified as the PUSH URL in the Power BI portal for the appropriate dataset
REST_API_URL=''

if [ -z "$REST_API_URL" ]; then
	echo "Please create your POWER BI dataset in the POWER BI service, then include the proper URL above to reference the dataset."
	exit 1
fi

send_to_powerBI () {
  # the curl command line utility is used to post data to the Power BI dataset
  # info on the command line args:
  # -s == silient
  # -S == echo any ERRORS to the terminal
  curl -s -S \
    --request POST \
    --header "Content-Type: application/json" \
    --data-binary "[
    {
    \"timestamp\" :\"$1\",
    \"latency\" : $2 \
    }
    ]" \
    $REST_API_URL
}

# Ping Google DNS 
ping 8.8.8.8 | while read line; do
  # Get the local system time
  timestamp=`date --utc +%FT%T.%3NZ`
  case "$line" in
  timeout)
    # if timeout occurs, set a datapoint to some higher arbritary number
    latency=500
    ;;
  "Reply from"* | *"bytes from"*)
    # Tee the output to the screen
    echo $line
    # Parse out the latency value, find the value after the param "time="
    # Example 1: Reply from 8.8.8.8: bytes=32 time=35ms TTL=59
    # Example 2: 64 bytes from 8.8.8.8: icmp_seq=50 ttl=59 time=34.1 ms
    latency=`echo $line | awk 'BEGIN {FS="[=]|ms"} {for(i=1;i<=NF;i++){ if($i ~ "time"){print $(i+1);break} } }'`
    send_to_powerBI $timestamp $latency
    ;;
  esac
done