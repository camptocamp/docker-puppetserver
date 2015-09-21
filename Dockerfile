FROM camptocamp/puppet:3.8.2-1

MAINTAINER mickael.canevet@camptocamp.com

ENV PUPPETSERVER_VERSION 1.1.1-1puppetlabs1

RUN apt-get update \
  && apt-get install -y puppetserver=$PUPPETSERVER_VERSION \
  && apt-get clean

ENTRYPOINT ["/usr/bin/puppetserver", "foreground"]
