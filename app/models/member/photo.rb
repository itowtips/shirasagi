class Member::Photo
  include Cms::Model::Page
  include Cms::Reference::Member
  include Member::Addon::Photo::Body
  include Member::Addon::Photo::Category
  include Member::Addon::Photo::Location
  include Member::Addon::Photo::Map
  include Cms::Addon::GroupPermission
  include History::Addon::Backup

  set_permission_name "member_photos"

  before_save :seq_filename, if: ->{ basename.blank? }

  default_scope ->{ where(route: "member/photo") }

  field :listable_state, type: String, default: "public"
  field :slideable_state, type: String, default: "closed"

  permit_params :listable_state, :slideable_state

  def listable_state_options
    [
      %w(表示 public),
      %w(非表示 closed),
    ]
  end

  def slideable_state_options
    [
      %w(表示 public),
      %w(非表示 closed),
    ]
  end

  def html
    ## for loop html img summary
    %(<img alt="#{name}" src="#{image.thumb_url}">) rescue ""
  end

  private
    def validate_filename
      (@basename && @basename.blank?) ? nil : super
    end

    def seq_filename
      self.filename = dirname ? "#{dirname}#{id}.html" : "#{id}.html"
    end

  class << self
    def contents_search(params = {})
      criteria = self.where({})
      return criteria if params.blank?

      if params[:keyword].present?
        criteria = criteria.search_text(params[:keyword])
      end

      if params[:contributor].present?
        # mongodb does not support joins
        member_ids = Cms::Member.search_text(params[:contributor]).map(&:id)
        criteria = criteria.in(member_id: member_ids)
      end

      if params[:location_ids].present?
        criteria = criteria.in(photo_location_ids: params[:location_ids])
      end

      if params[:category_ids].present?
        criteria = criteria.in(photo_category_ids: params[:category_ids])
      end

      criteria
    end

    def listable
      where listable_state: "public"
    end

    def slideable
      where slideable_state: "public"
    end
  end
end
