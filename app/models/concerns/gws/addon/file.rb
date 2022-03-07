module Gws::Addon
  module File
    extend ActiveSupport::Concern
    extend SS::Addon
    include Gws::Addon::Model::File
  end
end
