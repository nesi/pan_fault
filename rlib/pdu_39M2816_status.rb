
class PDU_39M2816_Status < Status
  VOLTAGE_LOW = 2030
  VOLTAGE_HIGH = 2440
  OUTLET_CURRENT_WARN = 16000 #Amps in pairs, so 8A each
  OUTLET_CURRENT_MAX = 20000 #Amps in pairs, so 10A max each
  PHASE_CURRENT_MAX = 32000 #Amps, which means not all outlets can run at 10A.
  SINGLE_PHASE_CURRENT_MAX = 64000 #Amps, which means not all outlets can run at 10A.
  FREQUENCY_MAX = 525 # 0.1Hz units 50HZ +/- 5%
  FREQUENCY_MIN = 475 # 0.1Hz units
  OID_PHASE_TEST = [ 
    '1.3.6.1.4.1.534.6.6.2.1.1.2.0', #IBM-DPI-MIB::pduIdentModel.0
    '1.3.6.1.4.1.534.6.6.2.1.3.1.1.0' #IBM-DPI-MIB::pduDeviceInputLineNumber.0 
  ]
  
  OID1 = [
    '1.3.6.1.4.1.534.6.6.2.1.3.1.2.0', # IBM-DPI-MIB::pduDeviceInputFrequency.0 = INTEGER: 500 0.1 Hertz

    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.2.1', # IBM-DPI-MIB::pduInputVoltage.1 = INTEGER: 2305 0.1 RMS Volts

    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.3.1', # IBM-DPI-MIB::pduInputCurrent.1 = INTEGER: 16 0.1 RMS Amp

    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.1.22.0', # IBM-DPI-MIB::pduOutputPowerfactorAPresentValue.0 = INTEGER: 87 0.01
    '1.3.6.1.4.1.534.6.6.2.1.3.2.5.0', # IBM-DPI-MIB::pduDeviceOutputTotalPower.0 = INTEGER: 926 watts

    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.2.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 7 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.3.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 9 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.4.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 8 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.5.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 7 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.6.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 8 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.7.4.0' #  IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 7 0.1 RMS Amp
  ]

  OID3 = [
    '1.3.6.1.4.1.534.6.6.2.1.3.1.2.0', # IBM-DPI-MIB::pduDeviceInputFrequency.0 = INTEGER: 500 0.1 Hertz

    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.2.1', # IBM-DPI-MIB::pduInputVoltage.1 = INTEGER: 2305 0.1 RMS Volts
    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.2.2', # IBM-DPI-MIB::pduInputVoltage.2 = INTEGER: 2274 0.1 RMS Volts
    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.2.3', # IBM-DPI-MIB::pduInputVoltage.3 = INTEGER: 2267 0.1 RMS Volts

    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.3.1', # IBM-DPI-MIB::pduInputCurrent.1 = INTEGER: 16 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.3.2', # IBM-DPI-MIB::pduInputCurrent.2 = INTEGER: 15 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.1.3.1.3.3', # IBM-DPI-MIB::pduInputCurrent.3 = INTEGER: 15 0.1 RMS Amp

    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.1.22.0', # IBM-DPI-MIB::pduOutputPowerfactorAPresentValue.0 = INTEGER: 87 0.01
    '1.3.6.1.4.1.534.6.6.2.1.3.2.5.0', # IBM-DPI-MIB::pduDeviceOutputTotalPower.0 = INTEGER: 926 watts

    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.2.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 7 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.3.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 9 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.4.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 8 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.5.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 7 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.6.4.0', # IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 8 0.1 RMS Amp
    '1.3.6.1.4.1.534.6.6.2.1.3.2.7.7.4.0' #  IBM-DPI-MIB::pduOutputCurrentPresentValue.0 = INTEGER: 7 0.1 RMS Amp
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
      case @phase_count
      when 1; @oid = OID1 #Need to do this, as a child class can't override constansts seen by the methods in this class
              query1
      when 3; @oid = OID3 #Need to do this, as a child class can't override constansts seen by the methods in this class
              query3
      else STDERR.puts "#{@hostname}: Unknown phase '#{@phase_count}'"
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
      when OID_PHASE_TEST[1]; @txt_result += "Phases #{value}\n\n"
                    @phase_count = value.to_i
      end
    end
  end
  
  #Snmpwalk is run to retrieve multiple OIDs from ths switch, and set switch and port attributes.
  #Nb the alignment with the OID Array
  def query3
    phase1 = phase2 = phase3 = 0
    process_switch(@oid) do |oid,value|
      case oid.to_str
      when @oid[0]; #Frequency
        f = value.to_i
        f_status = (f >= FREQUENCY_MIN && f <= FREQUENCY_MAX) ? 'ok' : 'Critical'  
        @txt_result += "Frequency #{f/10.0} #{f_status}\n"
        @status = worse_than(f_status)
      when @oid[1],@oid[2],@oid[3]; #Input voltage
        v = value.to_i
        v_status = (v >= VOLTAGE_LOW && v <= VOLTAGE_HIGH) ? 'ok' : 'Critical'  
        @txt_result += "Phase #{oid[-1]} Voltage #{v/10.0} #{v_status}\n"
        @status = worse_than(v_status)
      when @oid[4],@oid[5],@oid[6]; #Input Current
        a_status = value.to_i <= PHASE_CURRENT_MAX ? 'ok' : 'Critical'  
        @txt_result += "Phase #{oid[-1]} #{value.to_i/10.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      when @oid[7];
        @txt_result += "Power Factor #{value.to_i/100.0}\n"
      when @oid[8];
        @txt_result += "Total Power #{value.to_i/100.0} KW\n"
      when @oid[9], @oid[10], @oid[11], @oid[12], @oid[13], @oid[14];
        milliamps = value.to_i*100
        a_status = milliamps <= OUTLET_CURRENT_WARN ? 'ok' : (milliamps > OUTLET_CURRENT_MAX ? 'Critical' : 'Non-critical')
        @txt_result += "Outlet Pair #{oid[-2] - 1} #{milliamps/1000.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      end
    end
  end

  #Snmpwalk is run to retrieve multiple OIDs from ths switch, and set switch and port attributes.
  #Nb the alignment with the OID Array
  def query1    
    phase1 = 0
    process_switch(@oid) do |oid,value|
      case oid.to_str
      when @oid[0]; #Frequency
        f = value.to_i
        f_status = (f >= FREQUENCY_MIN && f <= FREQUENCY_MAX) ? 'ok' : 'Critical'  
        @txt_result += "Frequency #{f/10.0} #{f_status}\n"
        @status = worse_than(f_status)
      when @oid[1]; #Input voltage
        v = value.to_i
        v_status = (v >= VOLTAGE_LOW && v <= VOLTAGE_HIGH) ? 'ok' : 'Critical'  
        @txt_result += "Phase #{oid[-1]} Voltage #{v/10.0} #{v_status}\n"
        @status = worse_than(v_status)
      when @oid[2]; #Input Current
        a_status = value.to_i <= SINGLE_PHASE_CURRENT_MAX ? 'ok' : 'Critical'  
        @txt_result += "Phase #{oid[-1]} #{value.to_i/10.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      when @oid[3];
        @txt_result += "Power Factor #{value.to_i/100.0}\n"
      when @oid[4];
        @txt_result += "Total Power #{value.to_i/100.0} KW\n"
      when @oid[5], @oid[6], @oid[7], @oid[8], @oid[9], @oid[10];
        milliamps = value.to_i*100
        a_status = milliamps <= OUTLET_CURRENT_WARN ? 'ok' : (milliamps > OUTLET_CURRENT_MAX ? 'Critical' : 'Non-critical')
        @txt_result += "Outlet Pair #{oid[-2] - 1} #{milliamps/1000.0} Amps #{a_status}\n"
        @status = worse_than(a_status)
      end
    end
  end

  #Process switch is called by snmpwalk to run a single SNMP query to retrieve the OID or OIDS passed in.
  # @param ifTable_columns [String, Array<String>] The OIDS we want to retrieve from this switch.
  def process_switch(ifTable_columns)
    begin
      SNMP::Manager.open(:Host => @hostname, :Community => "#{@snmp_community}", :Version => :SNMPv1) do |manager|
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

