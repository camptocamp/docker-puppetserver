#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'openssl'

request = STDIN.read
csr = OpenSSL::X509::Request.new(request)

challenge = csr.attributes.select { |a| a.oid == "challengePassword" }.first.value.value.first.value

exit 1 if challenge.nil?

challenge_method, challenge_value = challenge.match(/(?:([^;]+);)?(.+)/).captures()

if challenge_method == 'rancher' or challenge_method.nil?
  sign_rancher(csr, ARGV[0], challenge_value)
end

exit 1


def sign_rancher(csr, certname, value)
  services = JSON.parse(open('http://rancher-metadata/latest/services', 'Accept' => 'application/json').read)
  services.each do |s|
    if values == "#{s['name']}:#{s['uuid']}"
      sign_csr(csr, certname)
    end
  end
end

def sign_csr(csr, certname)
  if ! csr.attributes.select { |a| a.oid == "ExtReq" }.nil?
    # https://tickets.puppetlabs.com/browse/SERVER-1005
    `puppet cert --allow-dns-alt-names --ssldir /etc/puppetlabs/puppet/ssl sign #{certname}`
    exit 0
  end
end
