#!/bin/bash

if test -n "${CERTNAME}"; then
  echo "Configure certname"
  puppet config set certname $CERTNAME --section main
fi
