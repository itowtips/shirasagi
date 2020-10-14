Rails.application.routes.draw do

  Translate::Initializer

  namespace "translate", path: ".g:site/translate" do
    namespace "apis" do
      post "convertors" => "convertors#convertor"
    end
  end

  part "translate" do
    get "tool" => "public#index", cell: "parts/tool"
  end
end
