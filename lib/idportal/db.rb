class Idportal::Db
  class << self
    def client
      conf = SS.config.idportal[:mysql]
      client = Mysql2::Client.new(host: conf["host"], username: conf["username"], password: conf["password"])
      client.select_db(conf["database"])
      client
    end
  end
end
