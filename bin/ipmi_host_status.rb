#!/usr/local/bin/ruby
require_relative '../rlib/configuration.rb'
require_relative '../rlib/upload.rb'
require_relative '../rlib/gather_fault.rb'
require 'pp'

#Get the Rack temperatures by querying the hosts in the racks.

@config = Configuration.new
@auth = Configuration.new((@config.auth[0] == '/') ? @config.auth : File.expand_path(File.dirname(__FILE__)) + '/../' + @config.auth)
@tdc_racks = Configuration.new(File.expand_path(File.dirname(__FILE__)) + '/../' + @config.rack_master)
file = 'rack_fault.json'

if ARGV.length == 1
  x = Ipmi_IBM_status.new(ARGV[0])
  puts x.to_json_element
else
  x = Gather_fault.new(@tdc_racks, @auth)
  x.to_json("#{@config.html_directory}/#{@config.remote_html_fault_directory}/#{file}")
end

Upload::upload_file("#{@config.html_directory}/#{@config.remote_html_fault_directory}/#{file}", 
                    "#{@config.remote_html_directory}/#{@config.remote_html_fault_directory}/#{file}", 
                    @config.remote_www_server, @auth.transfer_ssh_keyfile)
