require 'rubygems'
require 'net/ssh'
require 'net/ssh/telnet'
require_relative 'status.rb'

class Voltaire_4036E_Status < Status
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
front show
device 4036E    Temperature: 37C normal  
                HW Version: A01  Serial Number: AL3211900250   
                State: ok   
                Power Consumption: 129W 
                System AC power:157.38 [W]
                System Thermal power:536.981 [BTU/h]
                Ordering:Full
PSU1U       #1  State: ok   
sFU1U           Number of fans:6
                Rate: normal
                Fans direction: IN valid
                Fan #1:ok
                Fan #2:ok
                Fan #3:ok
                Fan #4:ok
                Fan #5:ok
                Fan #6:ok
=end
    begin 
      Net::SSH.start( @hostname, USER, :password => @password ) do |session|
        tfd = Net::SSH::Telnet.new("Session" => session, "Prompt" => /^.*[>#] .*$/, "Telnetmode" => false)
        @tr = tfd.cmd('front show')
      end
      
      @tr.each_line do |l|
        pl = l.strip.split(':')
        case(pl.length)
        when 1; #Ignore these. They are messages
        when 2; @result[pl[0].squeeze(' ').strip] = pl[1].strip
                @txt_result += pl[0].squeeze(' ').strip + ': ' + pl[1].rstrip + "\n"
        when 4; @result[pl[0].squeeze(' ').strip] = pl[1].strip
                @result[pl[2].squeeze(' ').strip] = pl[3].strip #We have a pair of values
                @txt_result += pl[0].squeeze(' ').strip + ': ' + pl[1].rstrip + "\n" + pl[2].squeeze(' ').strip + ': ' +  pl[3].rstrip + "\n"
        end
      end
    rescue Exception => error
      puts "#{@hostname} #{error}"
      @txt_result += error.to_s
    end
  end

  # @return [Boolean] True if there are any faults. False if we can't tell, or everything is fine.
  def fault
    return "unknown" if @result == {} || @txt_result == ""
    check?('State', 'ok') == false
  end

  # @return [Boolean] True if everything is fine or we can't find that key.
  def check?(key, expected_value)
    @result[key] == nil || @result[key] == expected_value
  end

  def to_json_element
    "\"#{@hostname}\": { #{h_to_j} }"
  end

  private
  def h_to_j
    s = "\"fault\": \"#{fault}\", \"response\": \"#{@txt_result.gsub(/$/,"\\n\\").gsub(/\r/,' ')} \" "
  end
end
