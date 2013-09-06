class SimCard
  class SignalQuality
    attr_reader :signal_strength

    def initialize at_interface
      @at_interface = at_interface
      @signal_strength = nil
      @bit_error_rate_min = nil
      @bit_error_rate_max = nil
      parse
    end

    private 
    def parse
      response = @at_interface.send 'AT+CSQ'
      a = response.split("\n")
      if a[1] && a[1].include?('+CSQ: ')
        b = a[1].match /(\d+),(\d+)/
        if b.size == 3
          raw_signal_strength = b[1].to_i
          parse_signal_strength raw_signal_strength
        end
      end
    end
    
    def parse_signal_strength raw_signal_strength
      if raw_signal_strength >= 0 && raw_signal_strength <= 31
        @signal_strength =  (2 * raw_signal_strength) - 113
      elsif raw_signal_strength == 99
        # not known
      end
    end
  end
end
