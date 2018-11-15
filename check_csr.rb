#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'openssl'
require 'puppet'

def sign_rancher(csr, certname, value)
  services = JSON.parse(open('http://rancher-metadata/latest/services', 'Accept' => 'application/json').read)
  services.each do |s|
    if value == "#{s['name']}:#{s['uuid']}"
      sign_csr(csr, certname)
    end
  end
  exit 1
end

def autosign_psk
  File.open('/run/secrets/autosign_psk', 'r').read.chomp
end

def sign_psk(csr, certname, value)
  if value == autosign_psk
    sign_csr(csr, certname)
  else
    exit 2
  end
end

def get_ext(csr, name)
  Puppet::SSL::Oids.register_puppet_oids
  exts = csr.attributes.select{ |a| a.oid == "extReq" }[0].value.value[0].value
  val = exts.select { |e| e.value[0].short_name == name }[0].value[1].value
  OpenSSL::ASN1.decode(val).value
end

def sign_hashed(csr, certname, value)
  pp_role = get_ext(csr, 'pp_role')
  pp_environment = get_ext(csr, 'pp_environment')
  hash = Digest::SHA256.base64digest("#{autosign_psk}/#{certname}/#{pp_role}/#{pp_environment}")
  if value == hash
    sign_csr(csr, certname)
  else
    exit 2
  end
end

def sign_csr(csr, certname)
  if ! csr.attributes.select { |a| a.oid == "ExtReq" }.nil?
    # https://tickets.puppetlabs.com/browse/SERVER-1005
    `puppet cert --allow-dns-alt-names --ssldir /etc/puppetlabs/puppet/ssl sign #{certname}`
  end
  exit 0
end

request = STDIN.read
csr = OpenSSL::X509::Request.new(request)

challenge = csr.attributes.select { |a| a.oid == "challengePassword" }.first.value.value.first.value

exit 3 if challenge.nil?

# The old format (rancher only) takes only a value in the form "<service_name>:<service_uuid>"
# The new format takes a name space in the form "<method>;<value>"
# For this reason, the part before (and including) the ";" is optional:
#   - with the old format, challenge_method=nil, challenge_value=<service_name>:<service_uuid>
#   - with the new format, challenge_method=<method>, challenge_value=<value>
challenge_method, challenge_value = challenge.match(/(?:([^;]+);)?(.+)/).captures()

# We plan to add a "rancher" method to containers and get rid of the old format eventually
if challenge_method == 'rancher' or challenge_method.nil?
  sign_rancher(csr, ARGV[0], challenge_value)
# The "psk" method is used by Terraform
elsif challenge_method == 'psk'
  sign_psk(csr, ARGV[0], challenge_value)
elsif challenge_method == 'hashed'
  sign_hashed(csr, ARGV[0], challenge_value)
end
# In the future, add more methods (using e.g. AWS and OpenStack metadata)

exit 4
