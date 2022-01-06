namespace :ss do
  task locale: :environment do
    assets_path = "#{Rails.public_path}#{Rails.application.config.assets.prefix}"

    I18n.available_locales.each do |lang|
      dir = "#{assets_path}/locales/#{lang}"
      ::FileUtils.mkdir_p dir
      ::File.write "#{dir}/translation.json", I18n.t(".", locale: lang).to_json
    end
  end
end
