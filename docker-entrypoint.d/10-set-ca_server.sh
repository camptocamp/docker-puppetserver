#!/bin/bash

if test -n "${CA}" && ! $CA; then
  puppet config set ca_server puppetca --section master
  puppet config set ca false --section master
fi
