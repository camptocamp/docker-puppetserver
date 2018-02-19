FROM ubuntu:xenial

EXPOSE 8140

ENV RELEASE xenial

ENV \
  JAVA_ARGS="-Xms2g -Xmx2g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger" \
  LANGUAGE=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  PUPPET_AGENT_VERSION=5.4.0-1${RELEASE} \
  PUPPETSERVER_VERSION=5.2.0-1${RELEASE} \
  PUPPETDB_VERSION=5.2.0-1${RELEASE} \
  RUBY_GPG_VERSION=0.3.2 \
  HIERA_EYAML_GPG_VERSION=0.5.0 \
  PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppet5-release-${RELEASE}.deb \
  && dpkg -i puppet5-release-${RELEASE}.deb \
  && rm puppet5-release-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN echo $PUPPETDB_VERSION | \
  grep -q SNAPSHOT \
    && curl https://nightlies.puppetlabs.com/puppetdb/$(echo ${PUPPETDB_VERSION} | \
      sed -E 's/([^-]*)-.*SNAPSHOT(.*)puppetlabs1/\1.SNAPSHOT\2/')/repo_configs/deb/pl-puppetdb-$(echo ${PUPPETDB_VERSION} | \
      sed -E 's/([^-]*)-.*SNAPSHOT(.*)puppetlabs1/\1.SNAPSHOT\2/')-${RELEASE}.list > /etc/apt/sources.list.d/pl-puppetdb-$(echo ${PUPPETDB_VERSION} | \
      sed -E 's/([^-]*)-.*SNAPSHOT(.*)puppetlabs1/\1.SNAPSHOT\2/')-${RELEASE}.list \
    || true

RUN apt-get update \
  && apt-get install -y --force-yes git \
    puppet-agent=$PUPPET_AGENT_VERSION \
    puppetserver=$PUPPETSERVER_VERSION \
    puppetdb-termini=$PUPPETDB_VERSION \
  && rm -rf /var/lib/apt/lists/*

COPY trapperkeeper.aug /opt/puppetlabs/puppet/share/augeas/lenses/trapperkeeper.aug

COPY auth.conf /etc/puppetlabs/puppetserver/conf.d/auth.conf

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc

RUN puppet config set strict_variables true --section master \
  && puppet config set hiera_config /etc/puppetlabs/code/environments/production/hiera.yaml --section master

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetserver

VOLUME ["/etc/puppetlabs/code/environments"]

# Configure cert autosign
COPY check_csr.rb /
RUN puppet config set autosign /check_csr.rb --section master

COPY puppetdb.conf /etc/puppetlabs/puppet/

# Allow running as arbitrary user
RUN \
  chgrp 0 -R /etc/puppetlabs/puppet/ssl && chmod 0771 /etc/puppetlabs/puppet/ssl && \
  chgrp 0 -R /etc/puppetlabs/puppetserver && \
  chgrp 0 -R /opt/puppetlabs/server/data && \
  chgrp 0 -R /var/log/puppetlabs/puppetserver && chmod 0750 /var/log/puppetlabs/puppetserver && \
  touch /var/log/puppetlabs/puppetserver/masterhttp.log && chgrp 0 /var/log/puppetlabs/puppetserver/masterhttp.log && chmod 0660 /var/log/puppetlabs/puppetserver/masterhttp.log && \
  mkdir -p /.puppetlabs/etc/puppet && chgrp 0 -R /.puppetlabs && chmod g=u -R /.puppetlabs

# Configure entrypoint
COPY /docker-entrypoint.sh /
COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]
