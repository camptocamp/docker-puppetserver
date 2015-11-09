FROM camptocamp/puppet-agent:1.2.7-1wheezy

MAINTAINER mickael.canevet@camptocamp.com

ENV PUPPETSERVER_VERSION 2.1.2-1puppetlabs1
ENV PUPPETDB_VERSION 3.1.0-1puppetlabs1

ENV RUBY_GPG_VERSION 0.3.2
ENV HIERA_EYAML_GPG_VERSION 0.5.0
ENV RIEMANN_CLIENT_VERSION 0.2.5

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:$PATH

RUN apt-get update \
  && apt-get install -y puppetserver=$PUPPETSERVER_VERSION puppetdb-termini=$PUPPETDB_VERSION git \
  && rm -rf /var/lib/apt/lists/*

ADD trapperkeeper.aug /opt/puppetlabs/puppet/share/augeas/lenses/trapperkeeper.aug
ADD puppetserver.sh /usr/local/sbin/puppetserver.sh

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install riemann-client --version $RIEMANN_CLIENT_VERSION --no-ri --no-rdoc

RUN puppet config set strict_variables true --section master

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetserver

# Get riemann reporter
RUN curl https://raw.githubusercontent.com/jamtur01/puppet-riemann/master/lib/puppet/reports/riemann.rb -o /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/riemann.rb

# Get graphite reporter
RUN curl https://raw.githubusercontent.com/evenup/evenup-graphite_reporter/master/lib/puppet/reports/graphite.rb -o /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/graphite.rb

# Configure Syslog appenders
RUN echo 'defnode syslog /files/etc/puppetlabs/puppetserver/logback.xml/configuration/appender[#attribute/name="SYSLOG"]\n\
set $syslog/#attribute/name "SYSLOG"\n\
set $syslog/#attribute/class "ch.qos.logback.core.SyslogAppender"\n\
set $syslog/syslogHost/#text "syslog"\n\
set $syslog/facility/#text "local0"\n\
set $syslog/suffixPattern/#text "${logpattern}"'\
| augtool -Ast "Xml.lns incl /etc/puppetlabs/puppetserver/logback.xml"

RUN echo 'defnode syslog /files/etc/puppetlabs/puppetserver/request-logging.xml/configuration/appender[#attribute/name="SYSLOG"]\n\
set $syslog/#attribute/name "SYSLOG"\n\
set $syslog/#attribute/class "ch.qos.logback.core.SyslogAppender"\n\
set $syslog/syslogHost/#text "syslog"\n\
set $syslog/facility/#text "local0"\n\
set $syslog/suffixPattern/#text "${logpattern}"'\
| augtool -Ast "Xml.lns incl /etc/puppetlabs/puppetserver/request-logging.xml"

RUN echo 'defnode appref /files/etc/puppetlabs/puppetserver/request-logging.xml/configuration/appender-ref[#attribute/ref="${logappender}"]\n\
set $appref/#attribute/ref "${logappender}"'\
| augtool -Ast "Xml.lns incl /etc/puppetlabs/puppetserver/request-logging.xml"

VOLUME ["/etc/puppetlabs/code/environments"]

ENTRYPOINT ["puppetserver.sh"]
