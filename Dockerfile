FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

EXPOSE 8080 8140

ENV RELEASE=jessie

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PUPPET_AGENT_VERSION 1.5.0-1${RELEASE}
ENV PUPPETSERVER_VERSION 2.4.0-1puppetlabs1
ENV PUPPETDB_VERSION 4.1.0-1puppetlabs1

ENV RUBY_GPG_VERSION 0.3.2
ENV HIERA_EYAML_GPG_VERSION 0.5.0
ENV RIEMANN_CLIENT_VERSION 0.2.5

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN echo $PUPPETDB_VERSION | grep -q SNAPSHOT && curl https://nightlies.puppetlabs.com/puppetdb/$(echo ${PUPPETDB_VERSION}|sed -E 's/([^-]*)-.*SNAPSHOT(.*)puppetlabs1/\1.SNAPSHOT\2/')/repo_configs/deb/pl-puppetdb-$(echo ${PUPPETDB_VERSION}|sed -E 's/([^-]*)-.*SNAPSHOT(.*)puppetlabs1/\1.SNAPSHOT\2/')-${RELEASE}.list > /etc/apt/sources.list.d/pl-puppetdb-$(echo ${PUPPETDB_VERSION}|sed -E 's/([^-]*)-.*SNAPSHOT(.*)puppetlabs1/\1.SNAPSHOT\2/')-${RELEASE}.list || true

RUN apt-get update \
  && apt-get install -y --force-yes git \
    puppet-agent=$PUPPET_AGENT_VERSION \
    puppetserver=$PUPPETSERVER_VERSION \
    puppetdb-termini=$PUPPETDB_VERSION \
  && rm -rf /var/lib/apt/lists/*

COPY trapperkeeper.aug /opt/puppetlabs/puppet/share/augeas/lenses/trapperkeeper.aug

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install riemann-client --version $RIEMANN_CLIENT_VERSION --no-ri --no-rdoc

RUN puppet config set strict_variables true --section master \
  && puppet config set hiera_config /etc/puppetlabs/code/environments/production/hiera.yaml --section master

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetserver

# Get riemann reporter
ADD https://raw.githubusercontent.com/jamtur01/puppet-riemann/master/lib/puppet/reports/riemann.rb /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/

# Get graphite reporter
ADD https://raw.githubusercontent.com/evenup/evenup-graphite_reporter/master/lib/puppet/reports/graphite.rb /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/

VOLUME ["/etc/puppetlabs/code/environments","/etc/puppetlabs/puppet/ssl"]

# Configure cert autosign
COPY check_csr.rb /
RUN puppet config set autosign /check_csr.rb --section master

# Configure entrypoint
COPY /docker-entrypoint.sh /
COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["puppetserver", "foreground"]
