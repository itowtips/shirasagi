module Tasks
  module SS
    class << self
      def invoke_task(name, *args)
        task = Rake.application[name]
        task.reenable
        task.invoke(*args)
      end

      def encrypt_yaml(file)
        if file.blank?
          puts "file must be specified"
          return
        end
        unless ::File.exist?(file)
          puts "file '#{file}' is not found"
          return
        end

        contents = ::File.binread(file)
        contents = ::SS::MessageEncryptor.encryptor.encrypt_and_sign(contents)

        dest_file = "#{file}.enc"
        ::File.binwrite(dest_file, contents)
        puts "encrypted '#{file}' to '#{dest_file}'"
      end

      def decrypt_yaml(file)
        if file.blank?
          puts "file must be specified"
          return
        end
        unless ::File.exist?(file)
          puts "file '#{file}' is not found"
          return
        end

        contents = ::File.binread(file)
        contents = ::SS::MessageEncryptor.encryptor.decrypt_and_verify(contents)

        dest_file = file.chomp('.enc')
        ::File.binwrite(dest_file, contents)
        puts "decrypted '#{file}' to '#{dest_file}'"
      end
    end
  end
end
