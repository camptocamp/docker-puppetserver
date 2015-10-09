FROM camptocamp/puppet-agent:1.2.5-1

MAINTAINER mickael.canevet@camptocamp.com

ENV PUPPETSERVER_VERSION 2.1.1-1puppetlabs1
ENV RUBY_GPG_VERSION 0.3.2
ENV HIERA_EYAML_GPG_VERSION 0.5.0
ENV PATH="/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:$PATH"

RUN apt-get update \
  && apt-get install -y puppetserver=$PUPPETSERVER_VERSION git \
  && rm -rf /var/lib/apt/lists/*

ADD puppetserver.sh /usr/local/sbin/puppetserver.sh

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetserver

ENTRYPOINT ["puppetserver.sh"]
