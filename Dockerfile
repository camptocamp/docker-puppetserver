FROM camptocamp/puppet-agent:1.2.4-2

MAINTAINER mickael.canevet@camptocamp.com

ENV PUPPETSERVER_VERSION 2.1.1-1puppetlabs1
ENV RUBY_GPG_VERSION 0.3.2
ENV HIERA_EYAML_GPG_VERSION 0.5.0
ENV PATH="/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:$PATH"

RUN apt-get update \
  && apt-get install -y puppetserver=$PUPPETSERVER_VERSION git \
  && apt-get clean

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
  && puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc

ENTRYPOINT ["puppetserver", "foreground"]
