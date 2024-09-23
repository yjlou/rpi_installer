#!/usr/bin/env bash
#
# Run all programs listed in the argument.  # Rename the filename after it
# executes successfully.
#
# If error, stop the process and pray a reboot can continue the jobs.
#
set -e

for arg in "$@"; do
  new_name="$(dirname $arg)/.deleted-$(basename $arg)"

  $arg && mv -f "$arg" "$new_name"
done
exit 0
