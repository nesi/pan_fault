# ========================================================================================
# Brocade Fibre Channel Hardware Status
# 
# OID Source          	: Steve Bosek (steve.bosek@ephris.net)
#                         Status Results: SNMPv2-SMI::enterprises.1588.2.1.1.1.1.22.1.3.X
#                           1 unknown
#                           2 faulty
#                           3 below-min
#                           4 nominal
#                           5 above-max
#                           6 absent
#                         For Temperature, valid values include 3 (below-min), 4 (nominal), and 5 (above-max).
#                         For Fan, valid values include 3 (below-min), 4 (nominal), and 6 (absent).
#                         For Power Supply, valid values include 2 (faulty), 4 (nominal), and 6 (absent).
#						
# -----------------------------------------------------------------------------------------

require 'snmp'
require_relative 'snmp_override.rb'
require_relative 'status.rb'

class Brocade_SNMP_Hardware_Status_Result 
  attr_accessor :index, :type,  :status, :value, :info

  def to_s
    s = "#{info}:  #{value_to_s} #{status_to_s}"
  end
  
  def type_to_s
    case @type
    when '1'; 'Temperature'
    when '2'; 'Fan'
    when '3'; 'Power Supply'
    else "Unknown-type:#{@type}"
    end
  end
  
  def value_to_s
    case @type
    when '1'; @value.to_s + ' C'
    when '2'; @value.to_s + ' RPM'
    when '3'; @value == '1' ? 'On' : 'Off'
    else "Unknown-type:#{@type}"
    end
  end
  
  def status_to_s
    case @status
    when '1' ; 'Unkown'
    when '2' ; 'Faulty'
    when '3' ; 'Below-min'
    when '4' ; 'Nominal'
    when '5' ; 'Above-max'
    when '6' ; 'Absent'
    else "Unknown-status:#{@status}"
    end
  end
  
  def faulty?
    @status == '2'
  end
  
  def worse_state(than_this = 'false') # ;)
    than_this = 'false' if than_this == nil #Need this, as passing nil is different to having no argument passed.
    case @status
    when '1' ; than_this
    when '2' ; 'true'  #There is a fault, so always true
    when '3' ; than_this == 'true' ?  'true' : 'degraded' #Fault, which is worse than this
    when '4' ; than_this == 'Nominal'  ? 'Nominal' : than_this  #Anything worse wins
    when '5' ; than_this == 'true' ?  'true' : 'degraded'  #Fault, which is worse than this
    when '6' ; than_this
    else than_this
    end
  end
end

#Container for snmp queries retrieving brocade fc switch hardware status
class Gather_Brocade_FC_Hardware_Status < Status
  OID='1.3.6.1.4.1.1588.2.1.1.1.1.22.1'  #Base OID. See above
  
  attr_reader :hostname, :txt_result
  
  #Create a Gather_fault instance
  # @return [Gather_fault]
  # @param racks [Pan_racks] collection of Pan_rack records, each holding an array of pan_host records
  # @param snmp_community [String] SNMP read community for the rack node's IMMs.
  def initialize(hostname, snmp_community)
    @results = []
    @snmp_community = snmp_community
    @fault = true
    @hostname = hostname
    @txt_result = ""
    query
  end
    
  #To_s for this class for diagnositic purposes.
  def to_s
    to_json_element
  end

  #Snmpwalk is run to retrieve multiple OIDs from ths switch, and set switch and port attributes.
  def query
    process_switch([OID]) do |k,v| #Port numbers
      if @results[k[-1]] == nil
        @results[k[-1]] = Brocade_SNMP_Hardware_Status_Result.new
      end
      case k[-2]
      when 1; @results[k[-1]].index = v  #v should be same as k[-1]
      when 2; @results[k[-1]].type = v   #What it is, by category 1 is temperature, 2 Fan, 3 Power Supply
      when 3; @results[k[-1]].status = v # 1 - 6, See above.
      when 4; @results[k[-1]].value = v  # degrees C, fan speed, power supply working or not (see above)
      when 5; @results[k[-1]].info = v   #What it is, as a string and identifies which temperature, fan or power supply
      else STDERR.puts "Unknown OID #{k.join('.')} #{v}"
      end
    end
  end

  #Process switch is called by snmpwalk to run a single SNMP query to retrieve the OID or OIDS passed in.
  # @param ifTable_columns [String, Array<String>] The OIDS we want to retrieve from this switch.
  def process_switch(ifTable_columns)
    begin
      SNMP::Manager.open(:Host => @hostname, :Community => "#{@snmp_community}", :Version => :SNMPv2c) do |manager|
        manager.walk(ifTable_columns) do |row|
          row.each do |vb| 
              oid = vb.name.to_s.split('.')
              oid.collect! { |o| o.to_i }
              yield [oid, vb.value.to_s]
          end
        end
      end
    rescue Exception => message
      STDERR.puts "#{@name}: #{message}"
      @txt_result += "#{@name}: #{message}"
    end
  end
  
  # @return [Boolean] True if there are any faults. False if we can't tell, or everything is fine.
  def fault
    @fault ? "true": "false"
  end

  def to_json_element
    "\"#{@hostname}\": { #{h_to_j} }"
  end

  private
  def h_to_j
    fault = 'false'
    @results.each do |r| 
      if r != nil
        fault = r.worse_state(fault)
        @txt_result += r.to_s + "\\n\\\n"
      end
    end

    "\"fault\": \"#{fault}\", \"response\": \"#{@txt_result} \" "
  end
end

