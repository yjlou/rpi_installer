#!/bin/bash
set -e

. rpi_installer/utils.sh

msg_warn 'You might be prompted to enter the "sudo" password in order to test.'
echo

keep_sudo

echo 'sleep 20 mins (the default privileges is 15-min) ...'
sleep $((20 * 60))
echo 'Now try sudo ... If you see password prompt below, the test is failed.'
timeout 3 sudo ls . && msg_pass || (msg_fail; exit 2)
