class Gws::User
  include SS::Model::User
  include Gws::Reference::Role
  include Gws::Permission
end
