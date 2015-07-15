class PublicBoard::Post
  include PublicBoard::Model::Post
  include SimpleCaptcha::ModelHelpers

  permit_params :captcha, :captcha_key

  apply_simple_captcha
end
