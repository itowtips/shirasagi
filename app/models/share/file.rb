class Share::File
  include SS::Model::File
  include SS::Reference::User
  include Share::Reference::Group

  default_scope ->{ where(model: "share/file") }
end
