#!/bin/bash

if getent hosts puppetdb > /dev/null 2>&1 ; then
  echo "Configure report to puppetdb"
  puppet config set reports puppetdb --section master
fi
