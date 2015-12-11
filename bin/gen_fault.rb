#!/usr/local/bin/ruby
require_relative '../rlib/configuration.rb'
require_relative '../rlib/upload.rb'
require_relative '../rlib/gather_idataplex_fault.rb'
require 'pp'

#Get the Rack temperatures by querying the hosts in the racks.

@config = Configuration.new
@auth = Configuration.new((@config.auth[0] == '/') ? @config.auth : File.expand_path(File.dirname(__FILE__)) + '/../' + @config.auth)
@tdc_racks = Configuration.new(File.expand_path(File.dirname(__FILE__)) + '/../' + @config.rack_master)

x = Gather_fault.new(@tdc_racks, @auth.node_snmp_r_community)

#Local copy
x.to_json("#{@config.html_directory}/#{@config.remote_html_fault_directory}/rack_fault.json")

=begin
#Copy to external web server
Upload::upload_file( "#{@config.html_directory}/#{@config.html_temperature_directory}/rack_temperature.json", 
             "#{@config.remote_html_directory}/#{@config.remote_html_power_directory}/rack_temperature.json", 
             @config.remote_www_server, @auth.transfer_ssh_keyfile
           )
=end