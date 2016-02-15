#!/bin/bash

DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
  /bin/run-parts --regex '\.(sh|rb)$' "$DIR"
fi

exec "$@"
