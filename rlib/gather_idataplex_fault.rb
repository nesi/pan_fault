require 'snmp'
require_relative 'snmp_override.rb'

#Container for snmp queries retrieving Fault status readings from TDC rack nodes IMM's
#IMM SNMP is not very stable. Nodes fail to respond and/or the OID goes missing at times.
class Gather_SNMP_fault
  FAULT='SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.1' #Fault light is on if not 0
=begin
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.1 = STRING: "Fault"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.2 = STRING: "Identify"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.3 = STRING: "Check Log"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.4 = STRING: "CPU 1"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.5 = STRING: "CPU 2"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.6 = STRING: "DIMM 1"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.7 = STRING: "DIMM 2"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.8 = STRING: "DIMM 3"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.9 = STRING: "DIMM 4"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.10 = STRING: "DIMM 5"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.11 = STRING: "DIMM 6"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.12 = STRING: "DIMM 7"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.13 = STRING: "DIMM 8"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.14 = STRING: "DIMM 9"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.15 = STRING: "DIMM 10"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.16 = STRING: "DIMM 11"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.17 = STRING: "DIMM 12"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.18 = STRING: "DIMM 13"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.19 = STRING: "DIMM 14"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.20 = STRING: "DIMM 15"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.21 = STRING: "DIMM 16"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.22 = STRING: "Battery"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.23 = STRING: "PCIE 1"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.24 = STRING: "PCIE 2"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.25 = STRING: "Power"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.26 = STRING: "IMM2 Heartbeat"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.27 = STRING: "Mezz Card"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.4.28 = STRING: "Planar"
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.1 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.2 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.3 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.4 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.5 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.6 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.7 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.8 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.9 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.10 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.11 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.12 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.13 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.14 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.15 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.16 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.17 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.18 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.19 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.20 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.21 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.22 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.23 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.24 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.25 = INTEGER: 1 #Power is on
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.26 = INTEGER: 2 #IMM2 working
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.27 = INTEGER: 0
  SNMPv2-SMI::enterprises.2.3.51.3.1.8.2.1.5.28 = INTEGER: 0
=end  

  #Create a Gather_fault instance
  # @return [Gather_fault]
  # @param racks [Pan_racks] collection of Pan_rack records, each holding an array of pan_host records
  # @param snmp_community [String] SNMP read community for the rack node's IMMs.
  def initialize(racks, snmp_community)
    @results = {}
    @racks = racks.rack #racks in TDC Pan Pod, Hashed indexed by TDC rack designation
    @snmp_community = snmp_community
    walk
  end
  
  #Process each rack's hosts, fetching the fault status
  def walk
    @racks.each do |rack_name, rack| #for each rack in the Pan Pod
      rack['nodes'].each do |rack_u, host| #For each U in the rack, we should have a Pan_host record
        if host == nil #Shouldn't be the case, as we filled in all U during the setup.
          $stderr.puts "Rack #{rack_name}/#{rack_u} has nil entry in nodes list?"
        elsif host.class != Hash #Shouldn't ever happen, except by a typo in the conf file.
          $stderr.puts "Rack #{rack_name}/#{rack_u} not a Hash?"
        else 
          case host['model'] #Using a case statement, as will later add different model
          when 'DX360_M3', 'DX360_M3_GPU', 'DX360_M4', 'DX360_M4_GPU'
            if (host_name = host['management_net']) != nil && host_name != ''
              @results[host_name] = process_host(host_name) #Fill in host fault status of this host
            end
          end
        end
      end
    end
  end
  
  #SNMP query handler
  # @return [String, 0] Value from the SNMP query, or 0 if this fails
  # @param manager [SNMP::Manager] From an SNMP::Manager.open (or new)
  def get(manager, ifTable_columns)
    response = manager.get(ifTable_columns)
    response.each_varbind { |vb|  return vb.value } #Fault
    return -1 #No fault OID.
  end

  #SNMP query wrapper to fetch Fault status
  # @return [Fixnum,String] the fault status we fetched from the host (or 0, if we can't contact it)
  # @param hostname [String] Host name of the target node in the rack
  def process_host(host_name)
    begin
      ifTable_columns = [ FAULT ] #should have a trailing .1, but returns nothing if we do?
      SNMP::Manager.open(:Host => host_name, :Community => "#{@snmp_community}", :Version => :SNMPv2c) do |manager|
        return get(manager, ifTable_columns) #The fault OID value
      end
    rescue SignalException => message
      $stderr.print "#{Signal} #{message}\n"
      exit -1
    rescue Exception => message
      $stderr.print "#{host_name} #{message}\n"
      return -1 #No fault OID.
    end
  end
  
  #Generate json from the resulting SNMP queries
  # @param file [String] File name to write json output to
  def to_json(file)
    File.open(file,"w") do |fd|
      fd.puts '{'
      fd.puts "  \"datetime\": \"#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\","
      fd.puts "  \"state\": { "
      @results.each do |host, value|
        fd.puts "    \"#{host}\": #{value},"
      end
      fd.puts "    \"end\": \"\""
      fd.puts "  }"
      fd.puts '}'
    end
  end
  
end

