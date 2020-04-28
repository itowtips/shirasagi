class Idportal::Agents::Nodes::PageController < ApplicationController
  include Cms::NodeFilter::View

  def index
    client = Mysql2::Client.new(:host => "localhost", :username => "root")
    client.select_db("id_portal")
    @results = client.query("SELECT * FROM sub")
  end
end
