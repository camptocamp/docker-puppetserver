#!/bin/bash

if test -n "${CA}" && ! $CA; then
  puppet config set ca_server puppetca --section master
fi
