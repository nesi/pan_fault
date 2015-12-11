require 'open3'
require_relative 'status.rb'

class Ipmi_IBM_status < Status
  attr_reader :hostname, :txt_result
  
  def initialize(hostname)
    @hostname = hostname
    @result = {}
    query
  end
  
  def query
=begin
System Power         : on
Power Overload       : false
Power Interlock      : inactive
Main Power Fault     : false
Power Control Fault  : false
Power Restore Policy : previous
Last Power Event     : 
Chassis Intrusion    : inactive
Front-Panel Lockout  : inactive
Drive Fault          : false
Cooling/Fan Fault    : false
=end
    begin
      @txt_result, err_txt, status = Open3.capture3("/usr/bin/ipmitool", "-H", "#{@hostname}", "-U", "USERID", "-P", "PASSW0RD", "chassis", "status")
      raise err_txt  if status.success? == false
      @txt_result.each_line do |l|
        pl = l.split(':')
        pl.collect! { |plv| plv.strip }
        @result[pl[0]] = pl[1]
      end
    rescue Exception => error
      puts "#{@hostname} #{error}"
      @txt_result = error.to_s
    end
  end

  # @return [Boolean] True if there are any faults. False if we can't tell, or everything is fine.
  def fault
    return "unknown" if @result == {} || @txt_result == ""
    (check?('Power Overload') && check?('Main Power Fault') && check?('Power Control Fault') && check?('Drive Fault') && check?("Cooling/Fan Fault") ) ? "false" : "true"
  end
  
  # @return [Boolean] True if everything is fine or we can't find that key.
  def check?(key)
    @result[key] == nil || @result[key] == "false"
  end
  
  def to_json_element
    "\"#{@hostname}\": { #{h_to_j} }"
  end
  
  private
  def h_to_j
    s = "\"fault\": \"#{fault}\", \"response\": \"#{@txt_result.gsub(/$/,"\\n\\").gsub(/\r/,' ')} \" "
  end
end