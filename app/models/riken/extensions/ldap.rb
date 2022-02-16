module Riken::Extensions::Ldap

  class CustomGroupCondition
    include ActiveModel::Model

    attr_accessor :name, :dn, :filter

    def to_h
      { name: name, dn: dn, filter: filter }
    end

    # Converts an object of this instance into a database friendly value.
    alias mongoize to_h

    class << self
      # Get the object as it was stored in the database, and instantiate
      # this custom class from it.
      def demongoize(object)
        return nil if object.nil?

        name = object[:name] || object["name"]
        dn = object[:dn] || object["dn"]
        filter = object[:filter] || object["filter"]
        return nil if name.blank? && dn.blank? && filter.blank?

        new(name: name, dn: dn, filter: filter)
      end

      # Takes any possible object and converts it to how it would be
      # stored in the database.
      def mongoize(object)
        return nil if object.nil?
        case object
        when self
          object.mongoize
        else
          object
        end
      end
    end
  end

  class CustomGroupConditions
    include ActiveModel::Model
    include Enumerable
    extend Forwardable

    attr_accessor :values

    def_delegators(
      :@values,
      :[], :[]=, :length, :size, :each, :sort_by, :count, :find, :find_index, :select, :reject,
      :map, :group_by, :all?, :any?, :each_with_index, :reverse_each, :each_slice, :take, :drop,
      :empty?, :present?, :blank?)

    def to_a
      return if values.blank?
      values.map { |value| value.to_h }
    end

    # Converts an object of this instance into a database friendly value.
    alias mongoize to_a

    class << self
      # Get the object as it was stored in the database, and instantiate
      # this custom class from it.
      def demongoize(object)
        return new(values: []) if object.nil?

        array = object.map { |value| CustomGroupCondition.demongoize(value) }
        array.compact!
        new(values: array)
      end

      # Takes any possible object and converts it to how it would be
      # stored in the database.
      def mongoize(object)
        return nil if object.nil?
        case object
        when self
          object.mongoize
        else
          object
        end
      end
    end
  end

end
