=begin
BNT Enterprise MIB 
G8000 IBM-GbTOR-1-10G-RS-MIB::
G8052 IBM-GbTOR-1-10G-RS-MIB::
G8124 IBM-GbTOR-10G-L2L3-MIB::

IBM-GbTOR-1-10G-RS-MIB::hwGlobalHealthStatus.0 = INTEGER: ok(1) Non-critical(2) Critical(3)
On G8124 switch 1.3.6.1.4.1.26543.2.7.4.1.3.1.15.0
On G8052 switch 1.3.6.1.4.1.26543.2.7.7.1.3.1.15.0
eg  SNMPv2-SMI::enterprises.26543.2.7.1.1.3.1.15.0 = INTEGER: 3

Power Supplies
IBM-GbTOR-1-10G-RS-MIB::hwPowerSupply1State.0 = INTEGER: off(0)   #.1.3.6.1.4.1.26543.100.100.14.20.0
On G8124 IBM-GbTOR-10G-L2L3-MIB::hwPowerSupply1State.0            #.1.3.6.1.4.1.26543.102.102.14.20.0
IBM-GbTOR-1-10G-RS-MIB::hwPowerSupply2State.0 = INTEGER: on(1)    #.1.3.6.1.4.1.26543.100.100.14.21.0
On G8124 IBM-GbTOR-10G-L2L3-MIB::hwPowerSupply2State.0            #.1.3.6.1.4.1.26543.102.102.14.21.0

IBM-GbTOR-1-10G-RS-MIB::hwTempSensors.0
eg SNMPv2-SMI::enterprises.26543.2.7.1.1.3.1.14.0 = STRING: "Sensor 1: 30.0 C; Sensor 2: 28.0 C; Sensor 3: 26.0 C; Sensor 4: --.-; "
On G8124       1.3.6.1.4.1.26543.2.7.4.1.3.1.14.0
Or individual values
hwTemperatureSensor1
hwTemperatureSensor2
hwTemperatureSensor3
hwTemperatureSensor4
hwTemperatureSensor5

IBM-GbTOR-1-10G-RS-MIB::hwFanSpeed.0
eg SNMPv2-SMI::enterprises.26543.2.7.1.1.3.1.13.0 = STRING: "Fan 1: 16513 RPM (255 PWM); Fan 2: 16216 RPM (255 PWM); Fan 3: 16071 RPM (255 PWM); Fan 4: 16463 RPM (255 PWM); Fan 5: 16023 RPM (255 PWM); "
On G8124       1.3.6.1.4.1.26543.2.7.4.1.3.1.13.0
On G8052       1.3.6.1.4.1.26543.2.7.7.1.3.1.13.0
OR individual values
hwFan1RPMValue
hwFan2RPMValue
hwFan3RPMValue
hwFan4RPMValue
hwFan5RPMValue
hwFan6RPMValue

IBM-GbTOR-1-10G-RS-MIB::hwFanStatus.0
eg. SNMPv2-SMI::enterprises.26543.2.7.1.1.3.1.12.0 = STRING: "Fans are in Forward AirFlow, Warning at 55 C and Recover at 80 C
On G8124 switch 1.3.6.1.4.1.26543.2.7.4.1.3.1.12.0
On G8052 Switch 1.3.6.1.4.1.26543.2.7.7.1.3.1.12.0
=end

require 'snmp'
require_relative 'snmp_override.rb'
require_relative 'status.rb'
require 'pp'


#Container for snmp queries retrieving brocade fc switch hardware status
class Gather_BNT_G8000_Hardware_Status < Status
  OID=['1.3.6.1.4.1.26543.2.7.1.1.3.1.15.0', #IBM-GbTOR-1-10G-RS-MIB::hwGlobalHealthStatus.0 = INTEGER: ok(1) Non-critical(2) Critical(3)
       '1.3.6.1.4.1.26543.2.7.1.1.3.1.14.0', #IBM-GbTOR-1-10G-RS-MIB::hwTempSensors.0 = STRING: "Sensor 1: 30.0 C; Sensor 2: 28.0 C; Sensor 3: 26.0 C; Sensor 4: --.-; "
       '1.3.6.1.4.1.26543.2.7.1.1.3.1.13.0', #IBM-GbTOR-1-10G-RS-MIB::hwFanSpeed.0 = STRING: "Fan 1: 16513 RPM (255 PWM); Fan 2: 16216 RPM (255 PWM); Fan 3: 16071 RPM (255 PWM); Fan 4: 16463 RPM (255 PWM); Fan 5: 16023 RPM (255 PWM); "
       '1.3.6.1.4.1.26543.2.7.1.1.3.1.12.0',  #IBM-GbTOR-1-10G-RS-MIB::hwFanStatus.0 = STRING: "Fans are in Forward AirFlow, Warning at 55 C and Recover at 80 C"       
       '1.3.6.1.4.1.26543.100.100.14.20.0',  #IBM-GbTOR-1-10G-RS-MIB::hwPowerSupply1State.0 = INTEGER: off(0) on(1) absent(2)'
       '1.3.6.1.4.1.26543.100.100.14.21.0',   #IBM-GbTOR-1-10G-RS-MIB::hwPowerSupply2State.0 = INTEGER: off(0) on(1) absent(2)'
       '1.3.6.1.4.1.26543.2.7.1.1.1.1.104.0'  #IBM-GbTOR-1-10G-RS-MIB::agHavePanicDump.0 = INTEGER: havePanic(1),noHavePanic(2)
      ] 
  
  attr_reader :hostname, :txt_result
  
  #Create a Gather_fault instance
  # @return [Gather_fault]
  # @param racks [Pan_racks] collection of Pan_rack records, each holding an array of pan_host records
  # @param snmp_community [String] SNMP read community for the rack node's IMMs.
  def initialize(hostname,  snmp_community, run_query = true)
    @snmp_community = snmp_community
    @status = 'unknown' #Assume the worse :)
    @txt_result = ""
    @hostname = hostname
    @oid = OID #Need to do this, as a child class can't override constansts seen by the methods in this class
    query if run_query
  end
    
  #To_s for this class for diagnositic purposes.
  def to_s
    to_json_element
  end

  #Snmpwalk is run to retrieve multiple OIDs from ths switch, and set switch and port attributes.
  #Nb the alignment with the OID Array
  def query
    process_switch(@oid) do |oid,value|
      case oid.to_str
      when @oid[0]; @status = (value == '1' ? 'ok' : (value == '3' ? 'Critical' : 'Non-critical'))  
      when @oid[1], @oid[2], @oid[3]; @txt_result += value.gsub(/;/,"\n")
      when @oid[4]; @txt_result += ( value ==  '0' ? "PowerSupply1: Off\n" : (value == '1' ? "PowerSupply1: On\n" : "PowerSupply1: Missing\n") )
      when @oid[5]; @txt_result += ( value ==  '0' ? "PowerSupply2: Off\n" : (value == '1' ? "PowerSupply2: On\n" : "PowerSupply2: Missing\n") )
      when @oid[6]; @txt_result += ( value ==  '1' ? "Have Panic Dump in Flash\n" : "" )
      else STDERR.puts "Unknown OID '#{oid}' '#{value}'"
      end
    end
  end

  #Process switch is called by snmpwalk to run a single SNMP query to retrieve the OID or OIDS passed in.
  # @param ifTable_columns [String, Array<String>] The OIDS we want to retrieve from this switch.
  def process_switch(ifTable_columns)
    begin
      SNMP::Manager.open(:Host => @hostname, :Community => "#{@snmp_community}", :Version => :SNMPv2c) do |manager|
        response = manager.get(ifTable_columns) 
        response.each_varbind do |vb| 
          yield vb.name, vb.value.to_s
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
  def h_to_j
    "\"fault\": \"#{@status}\", \"response\": \"#{@txt_result.gsub(/$/,"\\n\\").gsub(/\r/,' ')} \" "
  end
end

class Gather_BNT_10G_Hardware_Status < Gather_BNT_G8000_Hardware_Status
  OID=['1.3.6.1.4.1.26543.2.7.4.1.3.1.15.0', #IBM-GbTOR-10G-L2L3-MIB::hwGlobalHealthStatus.0 = INTEGER: ok(1) Non-critical(2) Critical(3)
       '1.3.6.1.4.1.26543.2.7.4.1.3.1.14.0', #IBM-GbTOR-10G-L2L3-MIB::hwTempSensors.0 = STRING: "Sensor 1: 30.0 C; Sensor 2: 28.0 C; Sensor 3: 26.0 C; Sensor 4: --.-; "
       '1.3.6.1.4.1.26543.2.7.4.1.3.1.13.0', #IBM-GbTOR-10G-L2L3-MIB::hwFanSpeed.0 = STRING: "Fan 1: 16513 RPM (255 PWM); Fan 2: 16216 RPM (255 PWM); Fan 3: 16071 RPM (255 PWM); Fan 4: 16463 RPM (255 PWM); Fan 5: 16023 RPM (255 PWM); "
       '1.3.6.1.4.1.26543.2.7.4.1.3.1.12.0',  #IBM-GbTOR-10G-L2L3-MIB::hwFanStatus.0 = STRING: "Fans are in Forward AirFlow, Warning at 55 C and Recover at 80 C"       
       '1.3.6.1.4.1.26543.102.102.14.20.0',  #IBM-GbTOR-10G-L2L3-MIB::hwPowerSupply1State.0 = INTEGER: off(0) on(1) absent(2)'
       '1.3.6.1.4.1.26543.102.102.14.21.0',   #IBM-GbTOR-10G-L2L3-MIB::hwPowerSupply2State.0 = INTEGER: off(0) on(1) absent(2)'
       '1.3.6.1.4.1.26543.2.7.4.1.1.1.104.0'  #IBM-GbTOR-10G-L2L3-MIB::agHavePanicDump.0 = INTEGER: havePanic(1),noHavePanic(2)
      ] 
  def initialize(hostname,  snmp_community, run_query = true)
    super(hostname,  snmp_community, false)
    @oid = OID #Need to do this, as a child class can't override constansts seen by the methods in this class
    query if run_query
  end
    
end

class Gather_BNT_G8052_Hardware_Status < Gather_BNT_G8000_Hardware_Status
  OID=['1.3.6.1.4.1.26543.2.7.7.1.3.1.12.0',  #IBM-GbTOR-10G-L2L3-MIB::hwFanStatus.0 = STRING: "Fans are in Forward AirFlow, Warning at 60 C and Recover at 80 C for sensor 1,2; Warning at 100 C and Recover at 120 C for sensor 6-11 "       
      
       '1.3.6.1.4.1.26543.100.100.14.11.0', # IBM-GbTOR-1-10G-RS-MIB::hwTemperatureSensor1.0 = STRING: 30.5 #Top main board
       '1.3.6.1.4.1.26543.100.100.14.12.0', # IBM-GbTOR-1-10G-RS-MIB::hwTemperatureSensor2.0 = STRING: 26.0 #Bottom main Board
       '1.3.6.1.4.1.26543.100.100.14.13.0', # IBM-GbTOR-1-10G-RS-MIB::hwTemperatureSensor3.0 = STRING: 32.25 #Fan CTL sensor
       '1.3.6.1.4.1.26543.100.100.14.32.0', # IBM-GbTOR-1-10G-RS-MIB::hwTemperatureSensor4.0 = STRING: 58.75 #Fan CTL sensor
       '1.3.6.1.4.1.26543.100.100.14.33.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor5.0 = STRING: 58.75    #Fan CTL sensor
       '1.3.6.1.4.1.26543.100.100.14.34.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor6.0 = STRING: 61.0
       '1.3.6.1.4.1.26543.100.100.14.35.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor7.0 = STRING: 62.0
       '1.3.6.1.4.1.26543.100.100.14.36.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor8.0 = STRING: 62.0
       '1.3.6.1.4.1.26543.100.100.14.37.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor9.0 = STRING: 61.0
       '1.3.6.1.4.1.26543.100.100.14.38.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor10.0 = STRING: 45.0
       '1.3.6.1.4.1.26543.100.100.14.39.0', # IBM-GbTOR-G8052-MIB::hwTemperatureSensor11.0 = STRING: 52.0
       
       '1.3.6.1.4.1.26543.100.100.14.14.0', # IBM-GbTOR-1-10G-RS-MIB::hwFan1RPMValue.0 = STRING: 0 #Our switches don't have these fans installed
       '1.3.6.1.4.1.26543.100.100.14.15.0', # IBM-GbTOR-1-10G-RS-MIB::hwFan2RPMValue.0 = STRING: 0 #Our switches don't have these fans installed
       '1.3.6.1.4.1.26543.100.100.14.16.0', # IBM-GbTOR-1-10G-RS-MIB::hwFan3RPMValue.0 = STRING: 8169
       '1.3.6.1.4.1.26543.100.100.14.17.0', # IBM-GbTOR-1-10G-RS-MIB::hwFan4RPMValue.0 = STRING: 3813
       '1.3.6.1.4.1.26543.100.100.14.18.0', # IBM-GbTOR-1-10G-RS-MIB::hwFan5RPMValue.0 = STRING: 7860
       '1.3.6.1.4.1.26543.100.100.14.27.0', # IBM-GbTOR-G8052-MIB::hwFan6RPMValue.0 = STRING: 7860
       '1.3.6.1.4.1.26543.100.100.14.40.0', # IBM-GbTOR-G8052-MIB::hwFan7RPMValue.0 = STRING: 7860
       '1.3.6.1.4.1.26543.100.100.14.41.0', # IBM-GbTOR-G8052-MIB::hwFan8RPMValue.0 = STRING: 7860
       
       '1.3.6.1.4.1.26543.100.100.14.20.0',  #IBM-GbTOR-10G-L2L3-MIB::hwPowerSupply1State.0 = INTEGER: off(0) on(1) absent(2)'
       '1.3.6.1.4.1.26543.100.100.14.21.0',   #IBM-GbTOR-10G-L2L3-MIB::hwPowerSupply2State.0 = INTEGER: off(0) on(1) absent(2)'
       
       '1.3.6.1.4.1.26543.2.7.7.1.1.1.104.0'  #IBM-GbTOR-G8052-MIB::agHavePanicDump.0 = INTEGER: havePanic(1),noHavePanic(2)
      ] 
  def initialize(hostname,  snmp_community, run_query = true)
    super(hostname,  snmp_community, false)
    @oid = OID #Need to do this, as a child class can't override constansts seen by the methods in this class
    @status_as_int = 1 #OK
    @fan_count = 0
    @status = "unknown"
    query if run_query
  end
  
  def set_status(value, warning, maximum)
      if value < warning
        return "ok\n" 
      elsif value >= maximum
        @status_as_int = 3
        return "Critical\n"
      else #Must be above Warning threshold.
        @status_as_int = 2 if @status_as_int != 3
        return "Non-critical\n"
      end     
  end
  
  def set_fan_status(value)
    return "Warning\n" if value < 100
    @fan_count += 1
    return "Ok\n"    
  end
  
  def calc_status
    return "Critical" if @fan_count < 4 || @status_as_int == 3 
    return "Non-critical" if @fan_count < 6 || @status_as_int == 2 #Can safely run with 2 fan modules (4+ fans)
    return "ok"
  end
  
  #G8052 falsely reports critical condition if 2nd redundant fan module is missing (and it ships this way)
  #Checking instead, that at least 2 fan modules work, and we are in temperature.
  #Snmpwalk is run to retrieve multiple OIDs from ths switch, and set switch and port attributes.
  #Nb the alignment with the OID Array
  def query
    process_switch(@oid) do |oid,value|
      case oid.to_str
      when @oid[0]; @txt_result += value.gsub(/;/,"\n")
        
      when @oid[1]; @txt_result += "Temperature Sensor 1 #{value.to_s} C " + set_status(value.to_f, 60.0, 80.0)                    
      when @oid[2]; @txt_result += "Temperature Sensor 2 #{value} C " + set_status(value.to_f, 60.0, 80.0) 
      when @oid[3]; @txt_result += "Temperature Sensor 3 #{value} C Fan Ctl\n" #Fan Ctl, has no limits we care about
      when @oid[4]; @txt_result += "Temperature Sensor 4 #{value} C Fan Ctl\n" #Fan Ctl, has no limits we care about
      when @oid[5]; @txt_result += "Temperature Sensor 5 #{value} C Fan Ctl\n" #Fan Ctl, has no limits we care about
      when @oid[6]; @txt_result += "Temperature Sensor 6 #{value} C " + set_status(value.to_f, 100.0, 120.0) 
      when @oid[7]; @txt_result += "Temperature Sensor 7 #{value} C " + set_status(value.to_f, 100.0, 120.0) 
      when @oid[8]; @txt_result += "Temperature Sensor 8 #{value} C " + set_status(value.to_f, 100.0, 120.0) 
      when @oid[9]; @txt_result += "Temperature Sensor 9 #{value} C " + set_status(value.to_f, 100.0, 120.0) 
      when @oid[10]; @txt_result += "Temperature Sensor 10 #{value} C " + set_status(value.to_f, 100.0, 120.0) 
      when @oid[11]; @txt_result += "Temperature Sensor 11 #{value} C " + set_status(value.to_f, 100.0, 120.0) 

      when @oid[12]; @txt_result += "Fan 1 RPM #{value} " + set_fan_status(value.to_i) #Not present in our switches
      when @oid[13]; @txt_result += "Fan 2 RPM #{value} " + set_fan_status(value.to_i) #Not present in our switches
      when @oid[14]; @txt_result += "Fan 3 RPM #{value} " + set_fan_status(value.to_i) 
      when @oid[15]; @txt_result += "Fan 4 RPM #{value} " + set_fan_status(value.to_i) 
      when @oid[16]; @txt_result += "Fan 5 RPM #{value} " + set_fan_status(value.to_i) 
      when @oid[17]; @txt_result += "Fan 6 RPM #{value} " + set_fan_status(value.to_i) 
      when @oid[18]; @txt_result += "Fan 7 RPM #{value} " + set_fan_status(value.to_i) 
      when @oid[19]; @txt_result += "Fan 8 RPM #{value} " + set_fan_status(value.to_i) 

      when @oid[20]; @txt_result += ( value ==  '0' ? "PowerSupply1: Off\n" : (value == '1' ? "PowerSupply1: On\n" : "PowerSupply1: Missing\n") ); @status_as_int = 3 if value == '0'
      when @oid[21]; @txt_result += ( value ==  '0' ? "PowerSupply2: Off\n" : (value == '1' ? "PowerSupply2: On\n" : "PowerSupply2: Missing\n") ); @status_as_int = 3 if value == '0'
        
      when @oid[22]; @txt_result += ( value ==  '1' ? "Have Panic Dump in Flash\n" : "" ); @status_as_int = 2 if value == '1' && @status_as_int != 3
      else STDERR.puts "Unknown OID '#{oid}' '#{value}'"
      end
    end
    
    @status = calc_status
  end
    
end


