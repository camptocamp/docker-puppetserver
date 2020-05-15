FROM puppet/puppetserver:6.11.1

ENV \
	RUBY_GPG_VERSION=0.3.2 \
	HIERA_EYAML_GPG_VERSION=0.5.0

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-document \
	&& puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc \
	&& apt-get update && apt-get install -y --no-install-recommends gpg && rm -rf /var/lib/apt/lists/*
