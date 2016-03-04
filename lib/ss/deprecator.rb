class SS::Deprecator < ActiveSupport::Deprecation
  def initialize(deprecation_horizon, gem_name = 'Shirasagi')
    super(deprecation_horizon, gem_name)
  end
end
