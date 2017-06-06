class Map::Extensions::Loc < Hash
  def to_s
    [self["lng"], self["lat"]].join(", ")
  end

  def lng
    self["lng"]
  end

  def lat
    self["lat"]
  end

  # convert to mongoid native type
  def mongoize
    { "lat" => lat, "lng" => lng }
  end

  class << self
    # convert mongoid native type to its custom type(this class)
    def demongoize(object)
      self.new(object)
    end

    # convert any possible object to mongoid native type
    def mongoize(object)
      case object
      when self then
        object.mongoize
      when String then
        object = object.gsub(/[, 　、\r\n]+/, ",").split(",").select(&:present?)
        { "lng" => Float(object[0]), "lat" => Float(object[1]) }
      when Array then
        { "lng" => Float(object[0]), "lat" => Float(object[1]) }
      when Hash then
        object.mongoize
      else
        # unknown type
        object
      end
    end

    # convert the object which was supplied to a criteria, and convert it to mongoid-friendly type
    def evolve(object)
      case object
      when self then
        object.mongoize
      else
        # unknown type
        object
      end
    end
  end
end
