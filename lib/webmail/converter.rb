class Webmail::Converter
  class << self
=begin
    def encode_address(value, field = :header)
      charset = "iso-2022-jp"
      value = Mail::Preprocessor.process(value)
      value = Mail.encoding_to_charset(value, charset)
      value.force_encoding('ascii-8bit')
      value = (field == :header) ? b_value_encode(value) : encode64(value)
      value.force_encoding('ascii-8bit')
    end

    def b_value_encode(string)
      string.split(' ').map do |s|
        if s =~ /\e/ || s == "\"" || start_with_specials?(s) || end_with_specials?(s)
          encode64(s)
        else
          s
        end
      end.join(" ")
    end

    def encode64(string)
      if string.length > 0
        "=?ISO-2022-JP?B?#{Base64.encode64(string).gsub("\n", "")}?="
      else
        string
      end
    end

    def start_with_specials?(string)
      string =~ /\A[\(\)<>\[\]:;@\\,\."]+[a-zA-Z]+\Z/
    end

    def end_with_specials?(string)
      string =~ /\A[a-zA-Z]+[\(\)<>\[\]:;@\\,\."]+\Z/
    end
=end

    def extract_address(address)
      Mail::Address.new(address.encode('ascii-8bit', :invalid => :replace, :undef => :replace)).address
    end

    def extract_display_name(address)
      address.gsub(/<?#{extract_address(address)}>?/, "").strip
    end
  end
end
