require_relative 'ipmi_ibm_status.rb'
require_relative 'smcli_san_status.rb'
require_relative 'brocade_FC_hw_status.rb'
require_relative 'voltaire_4036E_status.rb'
require_relative 'bnt_G8000_status.rb'
require_relative 'mellanox_is5x00_status.rb'
require_relative 'mellanox_sx_status.rb'
require_relative 'pdu_43V6145_status.rb'
require_relative 'pdu_39M2816_status.rb'

class Gather_fault

  def initialize(racks, auth)
    @auth = auth
    @results = {}
    @racks = racks.rack #racks in TDC Pan Pod, Hashed indexed by TDC rack designation
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
        elsif (host_name = host['management_net']) != nil && host_name != ''
          case host['model'] #Using a case statement, as will later add different model
          when 'DX360_M3', 'DX360_M3_GPU', 'DX360_M4', 'DX360_M4_GPU', 'DX360_M4_PHI', 'X3650_M3', 'X3650_M4', 'X3690_X5', 'X3850_X5'
             @results[host_name] = Ipmi_IBM_status.new(host_name) #Fill in host fault status of this host
          when "DS3512", "DS3524"; @results[host_name] = SMcli_san_status.new(host_name) #Fill in host fault status of this host
          when 'SAN40B_4'; @results[host_name] = Gather_Brocade_FC_Hardware_Status.new(host_name, @auth.fc_switch_snmp_r_community)
          when 'V4036E' ;  @results[host_name] = Voltaire_4036E_Status.new(host_name, @auth.voltaire_password)
          when 'G8000';   @results[host_name] = Gather_BNT_G8000_Hardware_Status.new(host_name, @auth.switch_snmp_r_community)
          when 'G8052' ;  @results[host_name] = Gather_BNT_G8052_Hardware_Status.new(host_name, @auth.switch_snmp_r_community)
          when 'G8124' ;  @results[host_name] = Gather_BNT_10G_Hardware_Status.new(host_name, @auth.switch_snmp_r_community)
	        when 'IS5200', 'IS5300'; @results[host_name] = Mellanox_IS5X00_status.new(host_name, @auth.switch_snmp_r_community)
	        when 'SX6036'; @results[host_name] = Mellanox_SX_Status.new(host_name, @auth.mellanox_sx_password)
	        when 'PDU_43V6145'; @results[host_name] = PDU_43V6145_Status.new(host_name, @auth.ibm_43V6145_PDU_community)
	        when 'PDU_39M2816'; @results[host_name] = PDU_39M2816_Status.new(host_name, @auth.ibm_39m2816_PDU_community)
          end
        end
      end
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
        if value.kind_of? Status
          fd.print value.to_json_element, ",\n"
        else
          fd.puts "    \"#{host}\": #{value},"
        end
      end
      fd.puts "    \"end\": \"\""
      fd.puts "  }"
      fd.puts '}'
    end
  end

end