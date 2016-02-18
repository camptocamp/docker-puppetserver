#!/usr/bin/env ruby

require 'fileutils'
require 'openssl'

if ENV['CA_KEY'] && ENV['CA_CRT']
  ca_dir = '/etc/puppetlabs/puppet/ssl/ca'

  FileUtils.mkdir_p(ca_dir)

  ca_key = File.join(ca_dir,'ca_key.pem')
  File.open(ca_key, 'w') { |f| f.puts ENV['CA_KEY'] }
  FileUtils.chmod(0640, ca_key)

  ca_crt = File.join(ca_dir, 'ca_crt.pem')
  File.open(ca_crt, 'w') { |f| f.puts ENV['CA_CRT'] }
  FileUtils.chmod(0644, ca_crt)

  inventory = File.join(ca_dir, 'inventory.txt')
  crt_str = File.read(ca_crt)
  crt = OpenSSL::X509::Certificate.new(crt_str)
  not_before = crt.not_before.strftime('%Y-%m-%dT%H:%M:%S%Z')
  not_after = crt.not_after.strftime('%Y-%m-%dT%H:%M:%S%Z')
  subject = crt.subject.to_s
  File.open(inventory, 'w') do |f|
    f.puts "# Inventory of signed certificates"
    f.puts "# SERIAL NOT_BEFORE NOT_AFTER SUBJECT"
    f.puts "0x0001 #{not_before} #{not_after} #{subject}"
  end

  serial = File.join(ca_dir, 'serial')
  File.open(serial, 'w') { |f| f.puts('0002') }

  # Force regenerate CRL
  %x{puppet cert generate regen-foobar}
  %x{puppet cert clean regen-foobar}

  FileUtils.chown_R('puppet', 'puppet', ca_dir)
end
