#!/bin/bash

if test -n "${GPG_KEY}"; then
  echo "${GPG_KEY}" | gpg --import
fi
