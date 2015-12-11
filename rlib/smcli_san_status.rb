require 'open3'
require_relative 'status.rb'

class SMcli_san_status < Status
  attr_reader :hostname, :txt_result
  
  def initialize(hostname)
    @fault = "unknown"
    @hostname = hostname
    @txt_result = ""
    query
  end
  
  def query
    begin
      @txt_result, err_txt, status = Open3.capture3("/usr/bin/SMcli", "#{@hostname}", "-S", "-quick", "-c", "show storageSubsystem healthStatus;")
      raise err_txt  if status.success? == false
      @txt_result.each_line do |l|
        ls = l.strip
        @fault = "false" if ls == "Storage Subsystem health status = optimal."
        @fault = "Non-critical" if ls == "The following failures have been found:" && @fault != "critical"
        @fault = "Critical" if ls == "Drive Expansion Enclosure - Loss of Path Redundancy" || 
                               ls =~ /^Failed.*/
        
      end
    rescue Exception => error
      puts "#{@hostname}: #{error}"
      @txt_result += error.to_s
    end
  end
    
  def to_json_element
    "\"#{@hostname}\": { #{h_to_j} }"
  end
  
  private
  def h_to_j
    "\"fault\": \"#{@fault}\", \"response\": \"#{@txt_result.gsub(/$/,"\\n\\").gsub(/\r/,' ')} \" "
  end
end
