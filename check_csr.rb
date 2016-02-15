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
  exit 0 if challenge == "#{s['name']}:#{s['uuid']}"
end

exit 1
