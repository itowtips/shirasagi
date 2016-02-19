require 'rest-client'
require 'json'

class Facility::SyncInstitutionsJob
  include Job::Worker

  public
    def call(host, urls)
      @error = false

      begin
        site = Cms::Site.find_by(host: host)
      rescue => e
        Rails.logger.info("error site not found")
        return false
      end

      responses = {}
      urls.each do |url|
        begin
          responses[url] = RestClient.get(url)
        rescue => e
          Rails.logger.info("error response #{e.to_s}")
          @error = true
          next
        end
      end

      return false if @error

      Facility::Node::Page.site(site).each do |item|
        item.set(institution_state: "none")
      end

      responses.each do |url, response|
        Rails.logger.info("sync institutions #{url}")

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
          else
            Rails.logger.info(" error telephone null #{id} #{name} :")
          end
        end

        Facility::Node::Page.site(site).in(tel: tels).each do |item|
          institution = tels_hash.delete(item.tel)
          id   = institution["institution_id"]
          tel  = institution["telephone"]
          name = institution["institution_name"]
          item.set(institution_state: "supported")

          Rails.logger.info(" sucess #{tel} #{id} #{name} : #{item.id} #{item.name} #{item.full_url}")
        end

        tels_hash.each do |tel, institution|
          id   = institution["institution_id"]
          tel  = institution["telephone"]
          name = institution["institution_name"]

          Rails.logger.info(" error not matched #{tel} #{id} #{name} : ")
        end

        Rails.logger.info(" ")
      end
      
      return @error
   end
end
