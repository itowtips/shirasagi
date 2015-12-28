require 'rest-client'
require 'json'

class Facility::SyncInstitutionsJob
  include Job::Worker

  public
    def call(host, url)
      Rails.logger.info("sync institutions")

      begin
        response = RestClient.get url
      rescue => e
        Rails.logger.info("error response: #{e.response.code}")
        return false
      end

      begin
        site = Cms::Site.find_by(host: host)
      rescue => e
        Rails.logger.info("error: site not found")
        return false
      end

      tels = []
      tels_hash = {}

      institutions = JSON.parse(response.body)
      institutions.each do |institution|
        id   = institution["institution_id"]
        tel  = institution["telephone"]
        name = institution["institution_name"]

        if tel.present?
          tels << tel
          tels_hash[tel] = institution
        end
      end

      Facility::Node::Page.site(site).each do |item|
        item.set(institution_state: "none")
      end

      Facility::Node::Page.site(site).in(tel: tels).each do |item|
        institution = tels_hash.delete(item.tel)
        id   = institution["institution_id"]
        tel  = institution["telephone"]
        name = institution["institution_name"]
        item.set(institution_state: "supported")

        Rails.logger.info("○ #{id} → #{item.id}: #{name} #{tel}")
      end

      tels_hash.each do |tel, institution|
        id   = institution["institution_id"]
        tel  = institution["telephone"]
        name = institution["institution_name"]

        Rails.logger.info("× #{id}: #{name} #{tel}")
      end

      return true
    end
end
