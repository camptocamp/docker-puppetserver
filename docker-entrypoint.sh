#!/bin/bash

DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
  /bin/run-parts --verbose --regex '\.(sh|rb)$' "$DIR"
fi

JAVA_BIN="/usr/bin/java"
LOG_APPENDER="-Dlogappender=STDOUT"
CLASSPATH="/opt/puppetlabs/server/apps/puppetserver/puppet-server-release.jar:/opt/puppetlabs/server/apps/puppetserver/jruby-1_7.jar:/opt/puppetlabs/server/data/puppetserver/jars/*"
CONFIG="/etc/puppetlabs/puppetserver/conf.d"
BOOTSTRAP_CONFIG="/etc/puppetlabs/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"
restartfile="/opt/puppetlabs/server/data/puppetserver/restartcounter"

COMMAND="${JAVA_BIN} ${JAVA_ARGS} ${LOG_APPENDER} \
         -Djava.security.egd=/dev/urandom \
         -cp "$CLASSPATH" \
         clojure.main -m puppetlabs.trapperkeeper.main \
         --config ${CONFIG} --bootstrap-config ${BOOTSTRAP_CONFIG} \
         --restart-file "${restartfile}" \
         ${@}"

exec $COMMAND
