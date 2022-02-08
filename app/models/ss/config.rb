module SS::Config
  class << self
    def setup
      @@config = {}
      Dir.glob("#{Rails.root}/config/defaults/*.yml").each do |path|
        @@config[File.basename(path, '.yml').to_sym] = nil
      end
      self
    end

    def env
      return send(:environment) if @@config[:environment]
      @@config[:environment] = true
      load_config(:environment, nil)
    end

    def load_config(name, section = nil)
      default_conf = load_default_config(name, section)
      user_conf = load_user_config(name, section)

      if default_conf
        if user_conf
          conf = default_conf.deep_merge(user_conf)
        else
          conf = default_conf
        end
      else
        conf = user_conf
      end

      struct = OpenStruct.new(conf).freeze
      define_singleton_method(name) { struct }
      struct
    end

    def load_default_config(name, section = nil)
      load_one_config "#{Rails.root}/config/defaults", name, section
    end

    def load_user_config(name, section = nil)
      load_one_config "#{Rails.root}/config", name, section
    end

    def load_one_config(base, name, section = nil)
      config = "#{base}/#{name}.yml.enc".then do |path|
        if File.exist?(path)
          load_enc_yml(path, section)
        end
      end
      return config if config

      "#{base}/#{name}.yml".then do |path|
        if File.exist?(path)
          load_yml(path, section)
        end
      end
    end

    def load_yml(file, section = nil)
      conf = YAML.load_file(file)
      section ? conf[section] : conf
    end

    def load_enc_yml(file, section = nil)
      content = ::File.binread(file)
      content = SS::MessageEncryptor.encryptor.decrypt_and_verify(content)
      conf = YAML.safe_load(content, aliases: true)
      section ? conf[section] : conf
    end

    def method_missing(name, *args, &block)
      load_config(name, Rails.env) if @@config.key?(name)
      # super
    end

    def respond_to?(name, *args)
      @@config.key?(name)
    end

    def respond_to_missing?(*args)
      true
    end
  end
end
