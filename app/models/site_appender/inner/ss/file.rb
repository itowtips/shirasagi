class SiteAppender::Inner::SS::File
  include SS::Model::File
  include SS::Relation::Thumb
  include SiteAppender::FixRelation

  store_in collection: :ss_files

  field :_old_id, type: Integer

  cattr_accessor(:models, instance_accessor: false) { [] }

  default_scope ->{ where(:_old_id.exists => true) }

  def becomes_with_inner_id
    item = SS::File.find(id)
    if item.respond_to?(:becomes_with_route)
      item.becomes_with_route
    else
      item
    end
  end

  def fix_thumb_original_id
    item = SS::ThumbFile.find(id) rescue nil
    return unless item
    return unless item.original_id

    old_id = item.original_id
    new_id = SiteAppender::Inner::SS::File.where(_old_id: old_id).first.id rescue nil

    if new_id
      item.set("original_id" => new_id)
      puts " original_id #{old_id} #{new_id}"
    end
  end

  def name
    self["name"]
  end

  class << self
    def model(model, klass)
      self.models << [ model, klass ]
    end

    def find_model_class(model)
      klass = SS::File.models.find { |k, v| k == model }
      klass = klass[1] if klass
      klass
    end
  end
end
