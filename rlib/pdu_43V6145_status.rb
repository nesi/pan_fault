
=begin
Can get better info on voltage and power factor from XML query
<XMLdata>
<info8_IPDP1_volt1>228.2</info8_IPDP1_volt1>
<info8_IPDP1_total_curr>4.62</info8_IPDP1_total_curr>
<info8_IPDP1_curr1>0.59</info8_IPDP1_curr1> #First four outlets
<info8_IPDP1_curr2>0.00</info8_IPDP1_curr2>
<info8_IPDP1_curr3>1.95</info8_IPDP1_curr3>
<info8_IPDP1_curr4>2.08</info8_IPDP1_curr4>
<info8_IPDP1_pf1>1.000</info8_IPDP1_pf1>
<info8_IPDP1_pf2>0.000</info8_IPDP1_pf2>
<info8_IPDP1_pf3>0.991</info8_IPDP1_pf3>
<info8_IPDP1_pf4>0.997</info8_IPDP1_pf4>
... Repeat for IPDP2 & 3
</XMLdata>
=end

require 'snmp'
require_relative 'snmp_override.rb'
require_relative 'status.rb'
require 'pp'


#Container for snmp queries retrieving brocade fc switch hardware status
class PDU_43V6145_Status < Status
  OUTLET_CURRENT_WARN = 8000 #milliAmps
  OUTLET_CURRENT_MAX = 10000 #milliAmps
  PHASE_CURRENT_MAX = 32000 #milliamps, which means not all outlets can run at 10A.
  SINGLE_PHASE_CURRENT_MAX = 64000
  OID_PHASE_TEST = [ '1.3.6.1.4.1.2.6.223.7.6.0', #IBM-PDU-MIB::ibmPduPartNumber.0
                     '1.3.6.1.4.1.2.6.223.8.3.1.0' #IBM-PDU-MIB::ibmPduPhaseCount.0
  ]
  OID3=['1.3.6.1.4.1.2.6.223.0.1.1.7.0',   #IBM-PDU-MIB::ibmPduVoltageWarning.0 = INTEGER: voltageNormal(0)
    #Phase 1
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.1', #IBM-PDU-MIB::ibmPduOutletCurrent.1 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.2', #IBM-PDU-MIB::ibmPduOutletCurrent.2 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.3', #IBM-PDU-MIB::ibmPduOutletCurrent.3 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.4', #IBM-PDU-MIB::ibmPduOutletCurrent.4 = INTEGER: 680 #0.001A Units
    #Phase 2
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.5', #IBM-PDU-MIB::ibmPduOutletCurrent.5 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.6', #IBM-PDU-MIB::ibmPduOutletCurrent.6 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.7', #IBM-PDU-MIB::ibmPduOutletCurrent.7 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.8', #IBM-PDU-MIB::ibmPduOutletCurrent.8 = INTEGER: 680 #0.001A Units
    #Phase 3
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.9', #IBM-PDU-MIB::ibmPduOutletCurrent.9 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.10', #IBM-PDU-MIB::ibmPduOutletCurrent.10 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.11', #IBM-PDU-MIB::ibmPduOutletCurrent.11 = INTEGER: 680 #0.001A Units
    '1.3.6.1.4.1.2.6.223.8.2.2.1.7.12' #IBM-PDU-MIB::ibmPduOutletCurrent.12 = INTEGER: 680 #0.001A Units
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
    if run_query
      phase_test
      if @phase_count == 1 || @phase_count == 3
        @oid = OID3 #Need to do this, as a child class can't override constansts seen by the methods in this class
        query
      else 
        STDERR.puts "#{@hostname}: Unknown phase '#{@phase_count}'"
      end
    end
  end
    
  #To_s for this class for diagnositic purposes.
  def to_s
    to_json_element
  end
  
  def worse_than(new_status)
    return new_status if @status == 'unknown'
    return case new_status
    when 'ok'; @status
    when 'Non-critical'; @status == 'Critical' ? @status : new_status
    when 'Critical'; new_status
    end
  end

  def phase_test
    process_switch(OID_PHASE_TEST) do |oid,value|
      case oid.to_str
      when OID_PHASE_TEST[0]; @txt_result += "Model #{value}\n"
      when OID_PHASE_TEST[1]; @txt_result += "Phases #{value}\n"
                    @phase_count = value.to_i
      end
    end
  end

  #Snmpwalk is run to retrieve multiple OIDs from ths switch, and set switch and port attributes.
  #Nb the alignment with the OID Array
  def query
    phase1 = phase2 = phase3 = 0
    process_switch(@oid) do |oid,value|
      case oid.to_str
      when @oid[0]; 
        v_status = value == '0' ? 'ok' : 'Critical'  #Might  be a warning state too
        @txt_result += "Voltage #{v_status}\n"
        @status = worse_than(v_status)
      when @oid[1], @oid[2], @oid[3], @oid[4];
        milliamps = value.to_i 
        phase1 += milliamps
        a_status = milliamps <= OUTLET_CURRENT_WARN ? 'ok' : (milliamps > OUTLET_CURRENT_MAX ? 'Critical' : 'Non-critical')
        @txt_result += "Outlet #{oid[-1]} #{milliamps/1000.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      when @oid[5], @oid[6], @oid[7], @oid[8];
        milliamps = value.to_i 
        phase2 += milliamps
        a_status = milliamps <= OUTLET_CURRENT_WARN ? 'ok' : (milliamps > OUTLET_CURRENT_MAX ? 'Critical' : 'Non-critical')
        @txt_result += "Outlet #{oid[-1]} #{milliamps/1000.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      when @oid[9], @oid[10], @oid[11], @oid[12];
        milliamps = value.to_i 
        phase3 += milliamps
        a_status = milliamps <= OUTLET_CURRENT_WARN ? 'ok' : (milliamps > OUTLET_CURRENT_MAX ? 'Critical' : 'Non-critical')
        @txt_result += "Outlet #{oid[-1]} #{milliamps/1000.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      end
    end
    
    if @phase_count == 1
      a_status = phase1 + phase2 + phase3 <= SINGLE_PHASE_CURRENT_MAX  ? 'ok' : 'Critical'
      @txt_result += "Phase 1 #{(phase1 + phase2 + phase3 )/1000.0} Amps #{a_status}\n"
      @status = worse_than(a_status)
    else
      a_status = phase1 <= PHASE_CURRENT_MAX  ? 'ok' : 'Critical'
      @txt_result += "Phase 1 #{phase1/1000.0} Amps #{a_status}\n"
      @status = worse_than(a_status)
    
      a_status = phase2 <= PHASE_CURRENT_MAX  ? 'ok' : 'Critical'
      @txt_result += "Phase 2 #{phase1/1000.0} Amps #{a_status}\n"
      @status = worse_than(a_status)
    
      a_status = phase3 <= PHASE_CURRENT_MAX  ? 'ok' : 'Critical'
      @txt_result += "Phase 3 #{phase3/1000.0} Amps #{a_status}\n"
      @status = worse_than(a_status)
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
      STDERR.puts "#{@hostname}: #{message}"
      @txt_result += "#{@hostname} #{message}\n"
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
