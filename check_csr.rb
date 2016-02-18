#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'openssl'

request = STDIN.read
csr = OpenSSL::X509::Request.new(request)

challenge = csr.attributes.select { |a| a.oid == "challengePassword" }.first.value.value.first.value

exit 1 if challenge.nil?

services = JSON.parse(open('http://rancher-metadata/latest/self/stack/services', 'Accept' => 'application/json').read)
services.each do |s|
  if challenge == "#{s['name']}:#{s['uuid']}"
    if csr.attributes[1].value.value.first.value.first.value[0].value
      if ! csr.attributes.select { |a| a.oid == "ExtReq" }.nil?
        # https://tickets.puppetlabs.com/browse/SERVER-1005
        `puppet cert --allow-dns-alt-names --ssldir /etc/puppetlabs/puppet/ssl sign #{ARGV[0]}`
      end
    end
    exit 0
  end
end

exit 1
