namespace :ss do
  task crypt: :environment do
    puts SS::Crypt.crypt(ENV["value"])
  end

  task encrypt: :environment do
    puts SS::Crypt.encrypt(ENV["value"])
  end

  task encrypt_yaml: :environment do
    ::Tasks::SS.encrypt_yaml ENV["file"]
  end

  task decrypt_yaml: :environment do
    ::Tasks::SS.decrypt_yaml ENV["file"]
  end
end
