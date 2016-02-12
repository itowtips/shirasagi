module Member::Addon::Blog
  module Body
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :html, type: String
      permit_params :html
      validates :html, presence: true
    end

    public
      def summary
        #return summary_html if summary_html.present?
        return "" unless html.present?
        ApplicationController.helpers.sanitize(html, tags: []).squish.truncate(120)
      end
  end
end
