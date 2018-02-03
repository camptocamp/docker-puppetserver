require "serverspec"
require "docker"

describe "Dockerfile" do
  before(:all) do
    # See https://github.com/swipely/docker-api/issues/106
    Excon.defaults[:write_timeout] = 1000
    Excon.defaults[:read_timeout] = 1000
    image = Docker::Image.build_from_dir('.')

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image.id
    set :docker_container_create_options, { "Privileged" => true }
  end

  describe file('/etc/puppetlabs/puppet/puppet.conf') do
    it { is_expected.to be_file }
  end
end
