#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
        "MASTER") pihole restartdns
                  exit 0
                  ;;
        "BACKUP") pihole restartdns
                  exit 0
                  ;;
        "FAULT")  pihole restartdns
                  exit 0
                  ;;
        *)        echo "unknown state"
                  exit 1
                  ;;
esac
