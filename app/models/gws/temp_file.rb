class Gws::TempFile
  include SS::Model::File
  #include Gws::Reference::Site
  include SS::UserPermission
  include Cms::Lgwan::File

  default_scope ->{ where(model: "ss/temp_file") }

  class << self
    def site(site)
      all
    end
  end
end
