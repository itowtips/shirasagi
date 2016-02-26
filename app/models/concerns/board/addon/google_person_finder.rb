module Board::Addon
  module GooglePersonFinder
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :uuid, type: String, default: ->{ SecureRandom.uuid }
    end

    def upload_to_gpf
      accessor = (node || @cur_node).accessor
      accessor.upload(self.to_pfif)
    end

    def find_gpf
      accessor = (node || @cur_node).accessor
      accessor.get(person_record_id: self.person_record_id)
    end

    def gpf_url
      accessor = (node || @cur_node).accessor
      accessor.view_uri(person_record_id: self.person_record_id)
    end

    def person_record_id
      self.member.present? ? self.member.uuid : self.uuid
    end

    def to_pfif
      pfif = {}
      pfif[:person_record_id] = person_record_id
      pfif[:author_name] = self.member.name if self.member.present?
      pfif[:author_email] = self.member.email if self.member.present?
      pfif[:full_name] = self.name
      pfif[:alternate_names] = self.kana
      # pfif[:description] = self.text
      pfif[:sex] = self.sex
      pfif[:age] = self.age
      pfif[:note] = {}
      pfif[:note][:note_record_id] = self.uuid
      pfif[:note][:author_name] = self.member.name if self.member.present?
      pfif[:note][:author_email] = self.member.email if self.member.present?
      pfif[:note][:email_of_found_person] = self.email
      pfif[:note][:phone_of_found_person] = self.tel
      if self.point.present? && self.point.loc.present?
        pfif[:note][:last_known_location] = "#{self.point.loc.lat},#{self.point.loc.lng}"
      elsif self.addr.present?
        pfif[:note][:last_known_location] = self.addr
      end
      pfif[:note][:text] = self.text

      pfif
    end
  end
end
