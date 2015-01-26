class Blog::Page
  include Cms::Page::Model
  include Cms::Addon::Meta
  include Cms::Addon::Body
  include Cms::Addon::File
  include Cms::Addon::Release
  include Cms::Addon::RelatedPage
  include Category::Addon::Category
  include Workflow::Addon::Approver
  include Blog::Addon::Weather
  include Blog::Addon::Author

  before_save :seq_filename, if: ->{ basename.blank? }

  default_scope ->{ where(route: "blog/page") }

  private
    def validate_filename
      (@basename && @basename.blank?) ? nil : super
    end

    def seq_filename
      self.filename = dirname ? "#{dirname}#{id}.html" : "#{id}.html"
    end
end
