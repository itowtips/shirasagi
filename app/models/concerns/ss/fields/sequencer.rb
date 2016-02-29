module SS::Fields::Sequencer
  extend ActiveSupport::Concern

  module ClassMethods
    def sequence_field(name, options = {})
      fields = instance_variable_get(:@_sequenced_fields) || []
      instance_variable_set(:@_sequenced_fields, fields << [name, options])
      before_save :set_sequence
    end

    def sequenced_fields
      instance_variable_get(:@_sequenced_fields) || []
    end
  end

  def current_sequence(name)
    SS::Sequence.current_sequence collection_name, name
  end

  def next_sequence(name, options = {})
    SS::Sequence.next_sequence collection_name, name, options
  end

  def unset_sequence(name)
    SS::Sequence.unset_sequence collection_name, name
  end

  private
    def set_sequence
      self.class.sequenced_fields.each do |name, options|
        next if self[name].to_s =~ /^[1-9]\d*$/
        self[name] = next_sequence(name, options)
      end
    end
end
