class Map::Extensions::Point < Hash
  def to_s
    return "" if self.loc.blank?
    [self.loc["lng"], self.loc["lat"]].join(", ")
  end

  def mongoize
    ret = {}
    ret["loc"] = self.loc
    ret["zoom_level"] = self.zoom_level if self.zoom_level
    ret
  end

  def loc
    self[:loc]
  end

  def zoom_level
    self[:zoom_level]
  end

  def empty?
    return true if super
    loc.empty?
  end
  alias blank? empty?

  class << self
    # convert mongoid native type to its custom type(this class)
    def demongoize(object)
      return self.new if object.nil?
      self[object.to_h.symbolize_keys]
    end

    # convert any possible object to mongoid native type
    def mongoize(object)
      case object
      when self then
        object.mongoize
      when Hash then
        loc = Map::Extensions::Loc.mongoize(object[:loc].presence || object['loc'].presence)
        zoom_level = object[:zoom_level].presence || object['zoom_level'].presence
        zoom_level = Integer(zoom_level) rescue nil if zoom_level.present?

        return self.new.mongoize if loc.blank?
        ret = self.new
        ret[:loc] = loc
        ret[:zoom_level] = zoom_level if zoom_level
        ret.mongoize
      else object
        object
      end
    end

    # convert the object which was supplied to a criteria, and convert it to mongoid-friendly type
    def evolve(object)
      mongoize(object)
    end
  end
end
