FROM debian:wheezy

MAINTAINER mickael.canevet@camptocamp.com

EXPOSE 8080 8140

ENV RELEASE=wheezy

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PUPPET_AGENT_VERSION 1.2.7-1${RELEASE}
ENV PUPPETSERVER_VERSION 2.1.2-1puppetlabs1
ENV PUPPETDB_VERSION 3.1.0-1puppetlabs1

ENV RUBY_GPG_VERSION 0.3.2
ENV HIERA_EYAML_GPG_VERSION 0.5.0
ENV RIEMANN_CLIENT_VERSION 0.2.5
ENV JACKSON_VERSION 2.5.4

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y git \
    puppet-agent=$PUPPET_AGENT_VERSION \
    puppetserver=$PUPPETSERVER_VERSION \
    puppetdb-termini=$PUPPETDB_VERSION \
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
ADD https://raw.githubusercontent.com/jamtur01/puppet-riemann/master/lib/puppet/reports/riemann.rb /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/

# Get graphite reporter
ADD https://raw.githubusercontent.com/evenup/evenup-graphite_reporter/master/lib/puppet/reports/graphite.rb /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/

# Configure Log appenders
ADD http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VERSION}/jackson-annotations-${JACKSON_VERSION}.jar /opt/puppetlabs/server/apps/puppetserver/
ADD http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${JACKSON_VERSION}/jackson-core-${JACKSON_VERSION}.jar /opt/puppetlabs/server/apps/puppetserver/
ADD http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/${JACKSON_VERSION}/jackson-databind-${JACKSON_VERSION}.jar /opt/puppetlabs/server/apps/puppetserver/
ADD http://central.maven.org/maven2/net/logstash/logback/logstash-logback-encoder/4.5.1/logstash-logback-encoder-4.5.1.jar /opt/puppetlabs/server/apps/puppetserver/

RUN chmod +r /opt/puppetlabs/server/apps/puppetserver/*.jar

COPY logback.xml /etc/puppetlabs/puppetserver/
COPY request-logging.xml /etc/puppetlabs/puppetserver/

RUN sed -i 's/${JAVA_ARGS} ${LOG_APPENDER}/${LOG_APPENDER} ${JAVA_ARGS}/' /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground
RUN sed -i "s@\(puppet-server-release.jar\)@\1:\$\{INSTALL_DIR\}/logstash-logback-encoder-4.5.1.jar:\$\{INSTALL_DIR\}/jackson-annotations-${JACKSON_VERSION}.jar:\$\{INSTALL_DIR\}/jackson-core-${JACKSON_VERSION}.jar:\$\{INSTALL_DIR\}/jackson-databind-${JACKSON_VERSION}.jar@" /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground

VOLUME ["/etc/puppetlabs/code/environments"]

ENTRYPOINT ["puppetserver.sh"]
