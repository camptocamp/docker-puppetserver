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

  describe command('/opt/puppetlabs/bin/puppet -V') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match(/^4\.\d+.\d+\n$/) }
  end

  describe command('/opt/puppetlabs/bin/puppetserver gem list') do
    its(:exit_status) { is_expected.to eq 0 }
    its(:stdout) { is_expected.to match(/\bruby_gpg\b/) }
  end

  describe file('/check_csr.rb') do
	it { is_expected.to be_file }
  end

  describe command('/opt/puppetlabs/bin/puppet master --configprint autosign') do
	its(:exit_status) { is_expected.to eq 0 }
	its(:stdout) { is_expected.to eq("/check_csr.rb\n") }
  end
end
