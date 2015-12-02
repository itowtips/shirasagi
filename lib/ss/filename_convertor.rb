class SS::FilenameConvertor
  class << self
    public
      def convert(filename, opts = {})
        id = opts[:id]
        return filename unless filename =~ /[^\w\-\.]/

        #case SS.config.env.multibyte_filename
        case "sequence"
        when "sequence"
          "#{id}#{::File.extname(filename)}"
        when "underscore"
          filename.gsub(/[^\w\-\.]/, "_")
        else
          filename
        end
      end
  end
end
