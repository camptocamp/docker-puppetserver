#!/bin/bash

while test -f /etc/puppetlabs/code/environments/r10k-initializing.lock; do
  echo "R10k is currently deploying. Waiting..."
  sleep 5
done
