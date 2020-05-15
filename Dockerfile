FROM puppet/puppetserver:6.10.0

ENV \
	RUBY_GPG_VERSION=0.3.2 \
	HIERA_EYAML_GPG_VERSION=0.5.0

RUN apt-get update && apt-get -y install gpg && apt-get clean

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-document \
	&& puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-document
