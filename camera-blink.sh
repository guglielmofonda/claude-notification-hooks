#!/bin/bash
for _ in 1 2 3 4 5; do
  imagesnap -w 0.5 /tmp/claude-snap.jpg &>/dev/null
  rm -f /tmp/claude-snap.jpg
  sleep 0.5
done
