#!/usr/bin/env bash
#
# Functions in this file returns the command string instead of executing the command. This is in
# purpose to be used as the arguments of another funtion.
#
# Below are the typical usage:
#
#   SESSION=$(eval $(tmux_new_session my_session))
#   WINDOW=$(eval $(tmux_new_window $SESSION))
#   $(eval $(tmux_start_cmd $SESSION $WINDOW ls -l /tmp))
#
set -e

tmux_random() {
  echo $RANDOM | md5sum | head -c 8
}

tmux_new_session() {
  local SESSION="$1"

  if [ -z "$SESSION" ]; then
    SESSION="$(tmux_random)"
  fi

  echo "tmux new-session -d -s $SESSION ; echo $SESSION"
}

tmux_new_window() {
  local SESSION="$1"
  local WINDOW="$2"

  if [ -z "$SESSION" ]; then
    echo "false"
    return
  fi

  if [ -z "$WINDOW" ]; then
    WINDOW="$(tmux_random)"
  fi

  echo "tmux new-window -t $SESSION -n $WINDOW ; echo $WINDOW"
}

tmux_start_cmd() {
  local ARGS=("$@")
  local SESSION="$1"
  local WINDOW="$2"
  local CMD="$3"
  local REMAINS="${@:4}"

  if [ -z "$SESSION" -o -z "$WINDOW" ]; then
    echo "false"
    return
  fi

  echo "tmux send-keys -t $SESSION:$WINDOW '$CMD $REMAINS' Enter"
}
