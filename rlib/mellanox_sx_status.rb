=begin
ENTITY-MIB::entPhysicalDescr.1 = STRING: Mellanox SX6036, 36-Port FDR/FDR10 Switch System
ENTITY-MIB::entPhysicalDescr.2 = STRING: MGMT
ENTITY-MIB::entPhysicalDescr.3 = STRING: FAN
ENTITY-MIB::entPhysicalDescr.4 = STRING: PS1
ENTITY-MIB::entPhysicalDescr.5 = STRING: PS2
ENTITY-MIB::entPhysicalDescr.6 = STRING: CPU
ENTITY-MIB::entPhysicalDescr.7 = STRING: CPU/CPU_BOARD_MONITOR
ENTITY-MIB::entPhysicalDescr.8 = STRING: MGMT/SX
ENTITY-MIB::entPhysicalDescr.9 = STRING: MGMT/QSFP_TEMP1
ENTITY-MIB::entPhysicalDescr.10 = STRING: MGMT/QSFP_TEMP2
ENTITY-MIB::entPhysicalDescr.11 = STRING: MGMT/QSFP_TEMP3
ENTITY-MIB::entPhysicalDescr.12 = STRING: MGMT/BOARD_MONITOR
ENTITY-MIB::entPhysicalDescr.13 = STRING: FAN/F1
ENTITY-MIB::entPhysicalDescr.14 = STRING: FAN/F2
ENTITY-MIB::entPhysicalDescr.15 = STRING: FAN/F3
ENTITY-MIB::entPhysicalDescr.16 = STRING: FAN/F4
ENTITY-MIB::entPhysicalDescr.17 = STRING: PS1/F1
ENTITY-MIB::entPhysicalDescr.18 = STRING: PS2/F1
ENTITY-MIB::entPhysicalName.1 = STRING: Chassis
ENTITY-MIB::entPhysicalName.2 = STRING: Chassis
ENTITY-MIB::entPhysicalName.3 = STRING: Fan
ENTITY-MIB::entPhysicalName.4 = STRING: Power Supply
ENTITY-MIB::entPhysicalName.5 = STRING: Power Supply
ENTITY-MIB::entPhysicalName.6 = STRING: Cpu
ENTITY-MIB::entPhysicalName.7 = STRING: Temperature sensor
ENTITY-MIB::entPhysicalName.8 = STRING: Temperature sensor
ENTITY-MIB::entPhysicalName.9 = STRING: Temperature sensor
ENTITY-MIB::entPhysicalName.10 = STRING: Temperature sensor
ENTITY-MIB::entPhysicalName.11 = STRING: Temperature sensor
ENTITY-MIB::entPhysicalName.12 = STRING: Temperature sensor
ENTITY-MIB::entPhysicalName.13 = STRING: Fan Sensor
ENTITY-MIB::entPhysicalName.14 = STRING: Fan Sensor
ENTITY-MIB::entPhysicalName.15 = STRING: Fan Sensor
ENTITY-MIB::entPhysicalName.16 = STRING: Fan Sensor
ENTITY-MIB::entPhysicalName.17 = STRING: Fan Sensor
ENTITY-MIB::entPhysicalName.18 = STRING: Fan Sensor
SNMPv2-SMI::mib-2.99.1.1.1.6.7 = STRING: "Celsius"
SNMPv2-SMI::mib-2.99.1.1.1.6.8 = STRING: "Celsius"
SNMPv2-SMI::mib-2.99.1.1.1.6.9 = STRING: "Celsius"
SNMPv2-SMI::mib-2.99.1.1.1.6.10 = STRING: "Celsius"
SNMPv2-SMI::mib-2.99.1.1.1.6.11 = STRING: "Celsius"
SNMPv2-SMI::mib-2.99.1.1.1.6.12 = STRING: "Celsius"
SNMPv2-SMI::mib-2.99.1.1.1.6.13 = STRING: "RPM"
SNMPv2-SMI::mib-2.99.1.1.1.6.14 = STRING: "RPM"
SNMPv2-SMI::mib-2.99.1.1.1.6.15 = STRING: "RPM"
SNMPv2-SMI::mib-2.99.1.1.1.6.16 = STRING: "RPM"
SNMPv2-SMI::mib-2.99.1.1.1.6.17 = STRING: "RPM"
SNMPv2-SMI::mib-2.99.1.1.1.6.18 = STRING: "RPM"
SNMPv2-SMI::mib-2.99.1.1.1.4.7 = INTEGER: 410
SNMPv2-SMI::mib-2.99.1.1.1.4.8 = INTEGER: 580
SNMPv2-SMI::mib-2.99.1.1.1.4.9 = INTEGER: 355
SNMPv2-SMI::mib-2.99.1.1.1.4.10 = INTEGER: 385
SNMPv2-SMI::mib-2.99.1.1.1.4.11 = INTEGER: 370
SNMPv2-SMI::mib-2.99.1.1.1.4.12 = INTEGER: 400
SNMPv2-SMI::mib-2.99.1.1.1.4.13 = INTEGER: 10740
SNMPv2-SMI::mib-2.99.1.1.1.4.14 = INTEGER: 11160
SNMPv2-SMI::mib-2.99.1.1.1.4.15 = INTEGER: 10350
SNMPv2-SMI::mib-2.99.1.1.1.4.16 = INTEGER: 11580
SNMPv2-SMI::mib-2.99.1.1.1.4.17 = INTEGER: 9360
SNMPv2-SMI::mib-2.99.1.1.1.4.18 = INTEGER: 9360
=end

require 'rubygems'
require 'net/ssh'
require 'net/ssh/telnet'
require_relative 'status.rb'

class Mellanox_SX_Status < Status
  USER = 'admin'
  attr_reader :hostname, :txt_result

  def initialize(hostname, password)
    @hostname = hostname
    @password = password
    @result = {}
    @txt_result = ""
    query
  end

  def query
=begin
Haven't found the MIB entries for 'OK' yet, so will do the tests through an ssh connection.
Get a nice output this way too.
=end
    temperature_status
    fan_status
    power_status
    voltage_status
  end
  
  def temperature_status
=begin
    ib-sx6036-a2-003-m [standalone: master] > show temperature
    ===================================================
    Module  Component             Reg  CurTemp   Status
                                       (Celsius)       
    ===================================================
    MGMT    BOARD_MONITOR         T1  40.00     OK
    MGMT    CPU_BOARD_MONITOR     T1  40.00     OK
    MGMT    CPU_BOARD_MONITOR     T2  72.00     OK
    MGMT    QSFP_TEMP1            T1  35.50     OK
    MGMT    QSFP_TEMP2            T1  38.00     OK
    MGMT    QSFP_TEMP3            T1  37.00     OK
    MGMT    SX                    T1  58.00     OK
=end      
    begin 
      Net::SSH.start( @hostname, USER, :password => @password ) do |session|
        tfd = Net::SSH::Telnet.new("Session" => session, "Prompt" => /^.*[>#] .*$/, "Telnetmode" => false)
        @tr = tfd.cmd('show temperature')
      end
      @tr.each_line do |l|
        pl = l.strip.split(' ')
        if(pl.length == 5 && pl[0] == "MGMT")
          @result[pl[1] + '_' + pl[2]] = pl[4]
          @txt_result += l
        elsif pl[0] == "Module"
          @txt_result += l
        end
      end
    rescue Exception => error
      puts "#{@hostname} #{error}"
      @txt_result += error.to_s
    end
    @txt_result += "\n"
  end

  def fan_status
=begin
  ib-sx6036-a2-003-m [standalone: master] > show fan
  =====================================================
  Module          Device          Fan  Speed     Status
                                       (RPM)           
  =====================================================
  FAN             FAN             F1   11160.00  OK
  FAN             FAN             F2   10740.00  OK
  FAN             FAN             F3   10350.00  OK
  FAN             FAN             F4   11580.00  OK
  PS1             FAN             F1   9360.00   OK
  PS2             FAN             F1   9360.00   OK
=end      
    begin 
      Net::SSH.start( @hostname, USER, :password => @password ) do |session|
        tfd = Net::SSH::Telnet.new("Session" => session, "Prompt" => /^.*[>#] .*$/, "Telnetmode" => false)
        @tr = tfd.cmd('show fan')
      end
      @tr.each_line do |l|
        pl = l.strip.split(' ')
        if(pl.length == 5 && pl[1] == "FAN")
          @result[pl[1] + '_' + pl[2]] = pl[4]
          @txt_result += l
        elsif pl[0] == "Module"
          @txt_result += l
        end
      end
    rescue Exception => error
      puts "#{@hostname} #{error}"
      @txt_result += error.to_s
    end
    @txt_result += "\n"
  end

  def power_status
=begin
  ib-sx6036-a2-003-m [standalone: master] > show power
  ======================================
  Module         Device           Status
  ======================================
  PS1            PS               OK
  PS2            PS               OK
=end      
    begin 
      Net::SSH.start( @hostname, USER, :password => @password ) do |session|
        tfd = Net::SSH::Telnet.new("Session" => session, "Prompt" => /^.*[>#] .*$/, "Telnetmode" => false)
        @tr = tfd.cmd('show power')
      end
      @tr.each_line do |l|
        pl = l.strip.split(' ')
        if(pl.length == 3 && pl[1] == "PS")
          @result[pl[0]] = pl[2]
          @txt_result += l
        elsif pl[0] == "Module"
          @txt_result += l
        end
      end
    rescue Exception => error
      puts "#{@hostname} #{error}"
      @txt_result += error.to_s
    end
    @txt_result += "\n"
  end

  def voltage_status
=begin
  ib-sx6036-a2-003-m [standalone: master] > show voltage
  ==========================================================================
  Module  Power Meter           Reg  Expected  Actual   Status  High   Low  
                                     Voltage   Voltage          Range  Range
  ==========================================================================
  MGMT    BOARD_MONITOR         V1   5.00      5.02     OK      5.75   4.25 
  MGMT    BOARD_MONITOR         V2   2.27      2.11     OK      2.61   1.93 
  MGMT    BOARD_MONITOR         V3   1.80      1.81     OK      2.07   1.53 
  MGMT    BOARD_MONITOR         V4   3.30      3.28     OK      3.79   2.80 
  MGMT    BOARD_MONITOR         V5   0.90      0.89     OK      1.10   0.81 
  MGMT    BOARD_MONITOR         V6   1.20      1.20     OK      1.38   1.02 
  MGMT    CPU_BOARD_MONITOR     V1   12.00     11.55    OK      13.80  10.20
  MGMT    CPU_BOARD_MONITOR     V2   2.50      2.46     OK      2.88   2.12 
  MGMT    CPU_BOARD_MONITOR     V3   3.30      3.31     OK      3.79   2.80 
  MGMT    CPU_BOARD_MONITOR     V4   3.30      3.28     OK      3.79   2.80 
  MGMT    CPU_BOARD_MONITOR     V5   1.80      1.79     OK      2.07   1.53 
  MGMT    CPU_BOARD_MONITOR     V6   1.20      1.24     OK      1.38   1.02 
=end      
    begin 
      Net::SSH.start( @hostname, USER, :password => @password ) do |session|
        tfd = Net::SSH::Telnet.new("Session" => session, "Prompt" => /^.*[>#] .*$/, "Telnetmode" => false)
        @tr = tfd.cmd('show voltage')
      end
      @tr.each_line do |l|
        pl = l.strip.split(' ')
        if(pl.length == 8 && pl[0] == "MGMT")
          @result[pl[1] + '_' + pl[2]] = pl[5]
          @txt_result += l
        elsif pl[0] == "Module"
          @txt_result += l
        end
      end
    rescue Exception => error
      puts "#{@hostname} #{error}"
      @txt_result += error.to_s
    end
    @txt_result += "\n"
  end


  # @return [Boolean] True if there are any faults. False if we can't tell, or everything is fine.
  def fault
    return "unknown" if @result == {} || @txt_result == ""
    @result.each do |k,v|
      if v != 'OK'
        puts "#{@hostname}: #{k} #{v}"
        return 'Critical'
      end
    end
    return 'ok'
  end

  def to_json_element
    "\"#{@hostname}\": { #{h_to_j} }"
  end

  private
  def h_to_j
    s = "\"fault\": \"#{fault}\", \"response\": \"#{@txt_result.gsub(/$/,"\\n\\").gsub(/\r/,' ')} \" "
  end
end
