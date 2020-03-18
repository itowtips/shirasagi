require 'mongo'
require "json"

# restore translate text caches
system("mongorestore --db ss translate_text_caches/ss")

# restore translate site settings
site1 = JSON.parse(::File.open("ss_sites.json").read).select { |s| s["_id"] == 1 }.first

translate_mock_api_request_count           = site1["translate_mock_api_request_count"].to_i
translate_mock_api_request_word_count      = site1["translate_mock_api_request_word_count"].to_i
translate_microsoft_api_request_count      = site1["translate_microsoft_api_request_count"].to_i
translate_microsoft_api_request_word_count = site1["translate_microsoft_api_request_word_count"].to_i
translate_google_api_request_count         = site1["translate_google_api_request_count"].to_i
translate_google_api_request_word_count    = site1["translate_google_api_request_word_count"].to_i

set_attributes = {
  translate_mock_api_request_count: translate_mock_api_request_count,
  translate_mock_api_request_word_count: translate_mock_api_request_word_count,
  translate_microsoft_api_request_count: translate_microsoft_api_request_count,
  translate_microsoft_api_request_word_count: translate_microsoft_api_request_word_count,
  translate_google_api_request_count: translate_google_api_request_count,
  translate_google_api_request_word_count: translate_google_api_request_word_count
}

ss_dir = ENV['ss_dir'] || '/Users/ito/www/shirasagi'
clients = YAML.load_file(File.join(ss_dir, 'config/mongoid.yml'))['production']['clients']
mongo_client = Mongo::Client.new(clients['default']['hosts'], database: clients['default']['database'])
mongo_client[:ss_sites].find({ "_id" => 1 }).update_one({ '$set' => set_attributes })
