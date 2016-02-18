#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'openssl'

request = STDIN.read
csr = OpenSSL::X509::Request.new(request)

challenge = nil
manual_sign = false
csr.attributes.each do |a|
  challenge = a.first.value.value.first.value if a.oid == "challengePassword"
  manual_sign = true if a.oid == "ExtReq"
end

exit 1 if challenge.nil?

services = JSON.parse(open('http://rancher-metadata/latest/self/stack/services', 'Accept' => 'application/json').read)
services.each do |s|
  if challenge == "#{s['name']}:#{s['uuid']}"
    if csr.attributes[1].value.value.first.value.first.value[0].value
      if manual_sign
        # https://tickets.puppetlabs.com/browse/SERVER-1005
        `puppet cert --allow-dns-alt-names --ssldir /etc/puppetlabs/puppet/ssl sign #{ARGV[0]}`
      end
    end
    exit 0
  end
end

exit 1
