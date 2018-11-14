FROM ubuntu:bionic

EXPOSE 8140

ENV RELEASE bionic

ENV \
  LANGUAGE=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  PUPPET_AGENT_VERSION=5.5.8-1${RELEASE} \
  PUPPETSERVER_VERSION=5.3.5-1${RELEASE} \
  PUPPETDB_VERSION=5.2.6-1${RELEASE} \
  RUBY_GPG_VERSION=0.3.2 \
  HIERA_EYAML_GPG_VERSION=0.5.0 \
  PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppet.com/puppet5-release-${RELEASE}.deb \
  && dpkg -i puppet5-release-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y --force-yes git gpg \
    puppet-agent=$PUPPET_AGENT_VERSION \
    puppetserver=$PUPPETSERVER_VERSION \
    puppetdb-termini=$PUPPETDB_VERSION \
	libreadline7 \
  && rm -rf /var/lib/apt/lists/*

COPY trapperkeeper.aug /opt/puppetlabs/puppet/share/augeas/lenses/trapperkeeper.aug

COPY auth.conf /etc/puppetlabs/puppetserver/conf.d/auth.conf

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc

RUN puppet config set strict_variables true --section master

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetserver

VOLUME ["/etc/puppetlabs/code"]

# Configure cert autosign
COPY check_csr.rb /
RUN puppet config set autosign /check_csr.rb --section master

COPY puppetdb.conf /etc/puppetlabs/puppet/
COPY hiera.yaml /etc/puppetlabs/puppet/

# Configure entrypoint
COPY /docker-entrypoint.sh /
COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh", "puppetserver"]
CMD ["foreground"]
