#!/usr/bin/env bash
#
#  Running on the host. SSH to the RPi, tune the antenna, start tcpdump and launch local Wireshark.
#
set -e
set -x

if [ -z "$1" ]; then
        echo "Please specify ssh URI, e.g. root@sniffer ."
        exit
fi
if [ -z "$2" ]; then
        echo "Please specify channel."
        exit
fi
SSH_URI=$1
CHAN=$2
PHY=wlan1

echo "- Setting channel to $CHAN on $PHY ..."
ssh $SSH_URI " \
    ifconfig $PHY down && \
    ifconfig $PHY promisc && \
    iwconfig $PHY mode monitor && \
    iwconfig $PHY channel $CHAN && \
    ifconfig $PHY up && \
    true "

echo "- Connecting to $SSH_URI and tcpdump $PHY."
ssh -C $SSH_URI tcpdump -i $PHY -U -s0 -w - 'not port 22' | wireshark -k -i -
