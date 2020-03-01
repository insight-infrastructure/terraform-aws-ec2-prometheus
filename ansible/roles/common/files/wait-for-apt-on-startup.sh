#!/usr/bin/env bash
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  sleep 1
done

while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
  sleep 1
done