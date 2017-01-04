module Nices::Node
  class Base
    include Cms::Model::Node

    default_scope ->{ where(route: /^nices\//) }
  end

  class Mypage
    include Cms::Model::Node
    include Cms::Addon::NodeSetting
    include Cms::Addon::Meta
    include Cms::Addon::Html
    include Nices::Addon::MemberKind
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "nices/mypage") }

    def children
      Member::Node::Base.and_public.
        where(filename: /^#{filename}\//, depth: depth + 1).
        order_by(order: 1)
    end
  end

  class Curriculum
    include Cms::Model::Node
    include Cms::Addon::NodeSetting

    default_scope ->{ where(route: "nices/curriculum") }
  end

  class CurriculumChecker
    include Cms::Model::Node
    include Cms::Addon::NodeSetting

    default_scope ->{ where(route: "nices/curriculum_checker") }
  end
end
