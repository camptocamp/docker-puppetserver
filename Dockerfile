FROM camptocamp/puppet-agent:1.2.4-1

MAINTAINER mickael.canevet@camptocamp.com

ENV PUPPETSERVER_VERSION 2.1.1-1puppetlabs1
ENV PATH="/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH"

RUN apt-get update \
  && apt-get install -y puppetserver=$PUPPETSERVER_VERSION \
  && apt-get clean

RUN gem install hiera-eyaml --no-ri --no-rdoc

ENTRYPOINT ["puppetserver", "foreground"]
