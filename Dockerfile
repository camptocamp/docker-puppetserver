FROM puppet/puppetserver:6.5.0

ENV \
	RUBY_GPG_VERSION=0.3.2 \
	HIERA_EYAML_GPG_VERSION=0.5.0

RUN puppetserver gem install ruby_gpg --version $RUBY_GPG_VERSION --no-ri --no-rdoc \
	&& puppetserver gem install hiera-eyaml-gpg --version $HIERA_EYAML_GPG_VERSION --no-ri --no-rdoc
