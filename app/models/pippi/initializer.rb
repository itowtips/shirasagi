module Pippi
  class Initializer
    Cms::Node.plugin "pippi/tips"
    Cms::Part.plugin "pippi/tips"
    Cms::Node.plugin "pippi/skill_json"

    Cms::Role.permission :read_pippi_tips
    Cms::Role.permission :edit_pippi_tips
  end
end
