class Cms::ShortUrl
  include SS::Document
  include SS::Reference::Site

  store_in collection: "cms_short_url"

  field :url, type: String

  #validate :validate_groups

  #public

  #private

end
