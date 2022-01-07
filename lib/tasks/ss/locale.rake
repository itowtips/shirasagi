namespace :ss do
  task locale: :environment do
    assets_path = "#{Rails.public_path}#{Rails.application.config.assets.prefix}"

    I18n.available_locales.each do |lang|
      json = I18n.t(".", locale: lang).to_json
      json.gsub!(/%{\w+?}/) do |matched|
        "{{#{matched[2..-2]}}}"
      end

      dir = "#{assets_path}/locales/#{lang}"
      ::FileUtils.mkdir_p dir unless ::Dir.exist?(dir)
      ::File.write "#{dir}/translation.json", json

      puts "#{dir}/translation.json"
    end
  end
end
