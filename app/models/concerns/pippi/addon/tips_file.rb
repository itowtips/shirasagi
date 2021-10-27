module Pippi::Addon
  module TipsFile
    extend SS::Addon
    extend ActiveSupport::Concern
    include SS::Relation::File
    include Fs::FilePreviewable

    included do
      belongs_to_file2 :image1
      belongs_to_file2 :image2
      belongs_to_file2 :image3
    end

    def file_previewable?(file, user:, member:)
      node.present? && node.public?
    end
  end
end
