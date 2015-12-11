#!/usr/local/bin/ruby
require 'snmp'
require_relative 'snmp_override.rb'
require_relative 'status.rb'

class Mellanox_Fans 
  attr_accessor :index, :identification, :speed,  :status, :status_string
  def initialize(index)
    @index = index
    @status = "unknown"
  end
  def set_state(v)
    @status_string = v
    if ( v == "Fan is in normal state" ) 
    	@status = "ok" 
    else
	    @status = "Critical"
	  end
  end
  def to_s
    "#{@identification}: #{@status_string} Speed #{@speed} RPM"
  end
end

class Mellanox_Temperature 
  attr_accessor :index, :identification, :temperature,  :status, :status_string
  def initialize(index)
    @index = index
    @status = "unknown"
  end
  def set_state(v)
    @status_string = v
    if ( v =~ /.*temperature is in range/ ) #simple true of false. Not sure how to check for warning.
    	@status = "ok" 
    else
	    @status = "Critical"
	  end
  end
  def to_s
    "#{@identification}: #{@status_string} Temperature #{@temperature} C"
  end
end

class Mellanox_Health
  attr_accessor :index, :identification, :module_type,  :status, :status_string
  def initialize(index)
    @index = index
    @status = "unknown"
  end
  def set_state(v)
    @status_string = v
    if ( v == 'Module health status is normal' || v == 'N/A')
    	@status = "ok" 
    else
	    @status = "Critical"
	  end
  end
  def to_s
    "#{@identification} Type: #{@module_type} : #{@status_string} "
  end
end


class Mellanox_IS5X00_status < Status
  attr_reader :hostname, :txt_result
  
  #Create a Gather_fault instance
  # @return [Gather_fault]
  # @param racks [Pan_racks] collection of Pan_rack records, each holding an array of pan_host records
  # @param snmp_community [String] SNMP read community for the rack node's IMMs.
  def initialize(hostname, snmp_community)
	  @txt_result = ''
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
    fan_state
    temperature_state
    module_health
  end

=begin
  #Fan state 1.3.6.1.4.1.33049.2.1.1.5.1.1.[2,3,4].y
  MELLANOX-MIB::gmVariables.5.1.1.2.1 = STRING: "/FAN1/FAN/f1"
  ...
  MELLANOX-MIB::gmVariables.5.1.1.2.4 = STRING: "/FAN4/FAN/f1"
  MELLANOX-MIB::gmVariables.5.1.1.2.5 = STRING: "/S01/FAN/f1"
  MELLANOX-MIB::gmVariables.5.1.1.2.6 = STRING: "/S01/FAN/f2"
  ...
  MELLANOX-MIB::gmVariables.5.1.1.2.21 = STRING: "/S09/FAN/f1"
  MELLANOX-MIB::gmVariables.5.1.1.2.22 = STRING: "/S09/FAN/f2"
  MELLANOX-MIB::gmVariables.5.1.1.3.1 = STRING: "Fan is in normal state"
  ...
  MELLANOX-MIB::gmVariables.5.1.1.3.22 = STRING: "Fan is in normal state"
  MELLANOX-MIB::gmVariables.5.1.1.4.1 = Gauge32: 5000
  ...
  MELLANOX-MIB::gmVariables.5.1.1.4.22 = Gauge32: 9407
=end
  def fan_state
    @fans = []
    process_switch(['1.3.6.1.4.1.33049.2.1.1.5.1.1']) do |k,v|
      if @fans[k[-1]] == nil
        @fans[k[-1]] = Mellanox_Fans.new(k[-1])
      end
      case k[-2]
      when 2; @fans[k[-1]].identification = v
      when 3; @fans[k[-1]].set_state(v)
      when 4; @fans[k[-1]].speed = v
      end
    end
  end

=begin
#Board Temperatures
  #1.3.6.1.4.1.33049.2.1.1.6.1.1.[2,3,4].y
  MELLANOX-MIB::gmVariables.6.1.1.2.1 = STRING: "/L01/BOARD_MONITOR"
  MELLANOX-MIB::gmVariables.6.1.1.2.2 = STRING: "/L01/IS4"
  MELLANOX-MIB::gmVariables.6.1.1.2.3 = STRING: "/L01/IS4_AMBIENT_TEMP"
  ...
  MELLANOX-MIB::gmVariables.6.1.1.2.37 = STRING: "/L13/BOARD_MONITOR"
  MELLANOX-MIB::gmVariables.6.1.1.2.38 = STRING: "/L13/IS4"
  MELLANOX-MIB::gmVariables.6.1.1.2.39 = STRING: "/L13/IS4_AMBIENT_TEMP"
  MELLANOX-MIB::gmVariables.6.1.1.2.40 = STRING: "/PS1/PS_MONITOR"
  ...
  MELLANOX-MIB::gmVariables.6.1.1.2.45 = STRING: "/PS6/PS_MONITOR"
  MELLANOX-MIB::gmVariables.6.1.1.2.46 = STRING: "/S01/BOARD_MONITOR"
  MELLANOX-MIB::gmVariables.6.1.1.2.47 = STRING: "/S01/IS4"
  MELLANOX-MIB::gmVariables.6.1.1.2.48 = STRING: "/S01/IS4_AMBIENT_TEMP"
  ...
  MELLANOX-MIB::gmVariables.6.1.1.2.70 = STRING: "/S09/BOARD_MONITOR"
  MELLANOX-MIB::gmVariables.6.1.1.2.71 = STRING: "/S09/IS4"
  MELLANOX-MIB::gmVariables.6.1.1.2.72 = STRING: "/S09/IS4_AMBIENT_TEMP"

  MELLANOX-MIB::gmVariables.6.1.1.3.1 = STRING: "Leaf temperature is in range"
  ...
  MELLANOX-MIB::gmVariables.6.1.1.3.39 = STRING: "Leaf temperature is in range"
  MELLANOX-MIB::gmVariables.6.1.1.3.40 = STRING: "Power Supply temperature is in range"
  ...
  MELLANOX-MIB::gmVariables.6.1.1.3.45 = STRING: "Power Supply temperature is in range"
  MELLANOX-MIB::gmVariables.6.1.1.3.46 = STRING: "Spine temperature is in range"
  ...
  MELLANOX-MIB::gmVariables.6.1.1.3.72 = STRING: "Spine temperature is in range"
  MELLANOX-MIB::gmVariables.6.1.1.4.1 = Gauge32: 35
  ...
  MELLANOX-MIB::gmVariables.6.1.1.4.72 = Gauge32: 41
=end
  def temperature_state
    @temperature = []
    process_switch(['1.3.6.1.4.1.33049.2.1.1.6.1.1']) do |k,v| 
      if @temperature[k[-1]] == nil
        @temperature[k[-1]] = Mellanox_Temperature.new(k[-1])
      end
      case k[-2]
      when 2; @temperature[k[-1]].identification = v
      when 3; @temperature[k[-1]].set_state(v)
      when 4; @temperature[k[-1]].temperature = v
      end
    end
  end

=begin
#Module states 1.3.6.1.4.1.33049.2.2.1.1.1.1.2.X
MELLANOX-MIB::invName.1 = STRING: "PS1"
MELLANOX-MIB::invName.2 = STRING: "PS2"
MELLANOX-MIB::invName.3 = STRING: "PS3"
MELLANOX-MIB::invName.4 = STRING: "S06"
MELLANOX-MIB::invName.5 = STRING: "L08"
MELLANOX-MIB::invName.6 = STRING: "L10"
MELLANOX-MIB::invName.7 = STRING: "L09"
MELLANOX-MIB::invName.8 = STRING: "CHASSIS"
MELLANOX-MIB::invName.9 = STRING: "CPU"
MELLANOX-MIB::invName.10 = STRING: "FAN1"
MELLANOX-MIB::invName.11 = STRING: "FAN2"
MELLANOX-MIB::invName.12 = STRING: "FAN3"
MELLANOX-MIB::invName.13 = STRING: "FAN4"
MELLANOX-MIB::invName.14 = STRING: "L01"
MELLANOX-MIB::invName.15 = STRING: "L02"
MELLANOX-MIB::invName.16 = STRING: "L03"
MELLANOX-MIB::invName.17 = STRING: "L04"
MELLANOX-MIB::invName.18 = STRING: "L05"
MELLANOX-MIB::invName.19 = STRING: "L06"
MELLANOX-MIB::invName.20 = STRING: "L07"
MELLANOX-MIB::invName.21 = STRING: "L11"
MELLANOX-MIB::invName.22 = STRING: "L12"
MELLANOX-MIB::invName.23 = STRING: "L13"
MELLANOX-MIB::invName.24 = STRING: "MGMT1"
MELLANOX-MIB::invName.25 = STRING: "MGMT2"
MELLANOX-MIB::invName.26 = STRING: "PS4"
MELLANOX-MIB::invName.27 = STRING: "PS5"
MELLANOX-MIB::invName.28 = STRING: "PS6"
MELLANOX-MIB::invName.29 = STRING: "S01"
MELLANOX-MIB::invName.30 = STRING: "S02"
MELLANOX-MIB::invName.31 = STRING: "S03"
MELLANOX-MIB::invName.32 = STRING: "S04"
MELLANOX-MIB::invName.33 = STRING: "S05"
MELLANOX-MIB::invName.34 = STRING: "S07"
MELLANOX-MIB::invName.35 = STRING: "S08"
MELLANOX-MIB::invName.36 = STRING: "S09"

#1.3.6.1.4.1.33049.2.2.1.1.1.1.3.X
MELLANOX-MIB::invType.1 = STRING: "FPS1000"
MELLANOX-MIB::invType.2 = STRING: "FPS1000"
MELLANOX-MIB::invType.3 = STRING: "FPS1000"
MELLANOX-MIB::invType.4 = STRING: "IS5002"
MELLANOX-MIB::invType.5 = STRING: "IS5001"
MELLANOX-MIB::invType.6 = STRING: "IS5001"
MELLANOX-MIB::invType.7 = STRING: "IS5001"
MELLANOX-MIB::invType.8 = STRING: "IS5300"
MELLANOX-MIB::invType.9 = STRING: "CPU"
MELLANOX-MIB::invType.10 = STRING: "IS5600_FAN"
MELLANOX-MIB::invType.11 = STRING: "IS5600_FAN"
MELLANOX-MIB::invType.12 = STRING: "IS5600_FAN"
MELLANOX-MIB::invType.13 = STRING: "IS5600_FAN"
MELLANOX-MIB::invType.14 = STRING: "IS5001"
MELLANOX-MIB::invType.15 = STRING: "IS5001"
MELLANOX-MIB::invType.16 = STRING: "IS5001"
MELLANOX-MIB::invType.17 = STRING: "IS5001"
MELLANOX-MIB::invType.18 = STRING: "IS5001"
MELLANOX-MIB::invType.19 = STRING: "IS5001"
MELLANOX-MIB::invType.20 = STRING: "IS5001"
MELLANOX-MIB::invType.21 = STRING: "IS5001"
MELLANOX-MIB::invType.22 = STRING: "IS5001"
MELLANOX-MIB::invType.23 = STRING: "IS5001"
MELLANOX-MIB::invType.24 = STRING: "IS5600MDC"
MELLANOX-MIB::invType.25 = STRING: "IS5600MDC"
MELLANOX-MIB::invType.26 = STRING: "FPS1000"
MELLANOX-MIB::invType.27 = STRING: "FPS1000"
MELLANOX-MIB::invType.28 = STRING: "FPS1000"
MELLANOX-MIB::invType.29 = STRING: "IS5002"
MELLANOX-MIB::invType.30 = STRING: "IS5002"
MELLANOX-MIB::invType.31 = STRING: "IS5002"
MELLANOX-MIB::invType.32 = STRING: "IS5002"
MELLANOX-MIB::invType.33 = STRING: "IS5002"
MELLANOX-MIB::invType.34 = STRING: "IS5002"
MELLANOX-MIB::invType.35 = STRING: "IS5002"
MELLANOX-MIB::invType.36 = STRING: "IS5002"

#Module states 1.3.6.1.4.1.33049.2.2.1.1.1.1.7.X
MELLANOX-MIB::invHealthStatus.1 = STRING: "Module health status is normal"
...
MELLANOX-MIB::invHealthStatus.9 = STRING: "N/A"
...
MELLANOX-MIB::invHealthStatus.36 = STRING: "Module health status is normal"
=end
  def module_health
    @health = []
    process_switch(['1.3.6.1.4.1.33049.2.2.1.1.1.1']) do |k,v|
      if @health[k[-1]] == nil
        @health[k[-1]] = Mellanox_Health.new(k[-1])
      end
      case k[-2]
      when 2; @health[k[-1]].identification = v
      when 7; @health[k[-1]].set_state(v)
      when 3; @health[k[-1]].module_type = v
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

  def to_json_element
    "\"#{@hostname}\": { #{h_to_j} }"
  end

  private
  def worse_state(new_state = 'ok', than_this = 'ok') # ;)
		return new_state if than_this == 'unknown' #At least we have a state
		case new_state
		when 'ok'; return than_this; #Can only be the same or worse
		when 'Un-critical'; return than_this if than_this != 'ok' #Can only be the same or worse
		when 'Critical'; return 'Critical' #Nothing trumps this
		else return 'unknown'
		end
	end

  def h_to_j
    fault = 'false'
		@health.each do |h|
		  if h != nil
        @txt_result += h.to_s + "\\n\\\n"
        fault = worse_state(h.status, fault)
      end
		end
	  @temperature.each do |t|
	    if t != nil
        @txt_result += t.to_s + "\\n\\\n"
        fault = worse_state(t.status, fault)
      end
		end
    @fans.each do |f|
      if f != nil
        @txt_result += f.to_s + "\\n\\\n"
        fault = worse_state(f.status, fault)
      end
	  end

    return "\"fault\": \"#{fault}\", \"response\": \"#{@txt_result} \" "
  end
end

