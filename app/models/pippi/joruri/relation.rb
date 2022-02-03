module Pippi::Joruri::Relation
  class Doc
    include Mongoid::Document

    belongs_to :owner_item, class_name: "Object", polymorphic: true
    field :joruri_id, type: Integer
    field :joruri_url, type: String
    field :joruri_updated, type: DateTime

    validates :owner_item_id, presence: true
    validates :joruri_id, presence: true
  end

  class Hint < Doc
  end

  class Bousai < Doc
  end

  class Report < Doc
  end

  class Circle < Doc
  end

  class Library < Doc
  end

  class Seminar < Doc
  end

  class Hiroba < Doc
  end

  class Bunka < Doc
  end

  class Park < Doc
  end

  class Odekake < Doc
  end

  class OdekakeAuthor < Doc
  end

  class PippiContent < Doc
  end

  class Node < Doc
  end

  class Facility < Doc
    class ShoKoku < Doc
    end

    class ShoShi < Doc
    end

    class ShoWatakushi < Doc
    end

    class ShoTokubetsu < Doc
    end

    class GakushushienGakusyukyoshitsu < Doc
    end

    class GakushushienGakusyushien < Doc
    end

    class KodomoshokudoKodomoshokudo < Doc
    end
  end
end
