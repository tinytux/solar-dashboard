#!/bin/bash
#
# Parse the syslog file, fix the system name and timestamp
#

if ! [ -x "$(command -v nc)" ]; then
  echo "netcat (nc) required. Run 'sudo apt-get install netcat'"
  exit 1
fi

if [[ "$#" -eq 0 ]]; then
    echo "feed script"
    echo "~^~~~~~~~^~"
    echo " Usage:"
    echo "      Feed all syslog files from \"./data/\":"
    echo "        ./feed.sh ./data/*syslog.txt | nc -q 5 localhost 5000"
    echo
    echo "      Feed a specific file:"
    echo "        ./feed.sh ./data/2015-06-14_10-15-27_syslog.txt | nc -q 5 localhost 5000"
    echo
    echo "      Feed a file with test entries:"
    echo "        ./feed.sh ./data/2015-06-01_00-00-00_testlog.txt | nc -q 5 localhost 5000"
    exit 1
fi

LOGFILES="$@"

for LOGFILE in ${LOGFILES}
do
    # All log files start with the system name and a syslog restart message:
    # "Jun  7 06:00:25 rx10025878 syslogd: restart"
    # Extract the system name from the first log line
    SYSTEMNAME="$(head -n1 ${LOGFILE} | cut -c17-26)"
    # Extract the year to build the timestamp from the file name: "../data/2015-06-07_06-15-24_syslog.txt"
    LOGYEAR="$(basename ${LOGFILE} | cut -c1-4)"
	# Skip the first log line and replace the "nto" default with the system name
	sed -re "1d; s#(.*) (nto|${SYSTEMNAME}) #${LOGYEAR} \1 ${SYSTEMNAME} #g" ${LOGFILE}
done

