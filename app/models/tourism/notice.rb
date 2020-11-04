class Tourism::Notice
  include Cms::Model::Page
  include Cms::Page::SequencedFilename
  include Cms::Addon::EditLock
  include Workflow::Addon::Branch
  include Workflow::Addon::Approver
  include Tourism::Addon::Facility
  include Cms::Addon::Meta
  include Cms::Addon::Thumb
  include Cms::Addon::Body
  include Cms::Addon::BodyPart
  include Cms::Addon::File
  include Cms::Addon::Form::Page
  include Category::Addon::Category
  include Cms::Addon::ParentCrumb
  include Event::Addon::Date
  include Map::Addon::Page
  include Cms::Addon::RelatedPage
  include Contact::Addon::Page
  include Cms::Addon::Release
  include Cms::Addon::ReleasePlan
  include Cms::Addon::GroupPermission
  include Cms::AttachedFiles
  include History::Addon::Backup

  set_permission_name "tourism_notices"

  default_scope ->{ where(route: "tourism/notice") }

  scope :keyword_in, ->(words, *fields) {
    options = fields.extract_options!
    method = options[:method].presence || 'and'
    operator = method == 'and' ? "$and" : "$or"

    words = words.split(/[\s　]+/).uniq.compact.map { |w| /#{::Regexp.escape(w)}/i } if words.is_a?(String)
    words = words[0..4]
    cond  = words.map do |word|
      { "$or" => fields.map { |field| { field => word } } }
    end

    # with facility
    site_id = criteria.selector["site_id"].presence || nil
    ids = ::Facility::Node::Page.where(site_id: site_id).
      keyword_in(words, *fields).
      pluck(:id)

    cond = { "$or" => [ { operator => cond }, facility_id: { "$in" => ids } ] }
    self.and(cond)
  }
end
