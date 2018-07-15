require_relative 'accessors'
require_relative 'validation'

class CargoRailcar < Railcar
  include Accessors
  include Validation

  attr_reader :capacity_total, :capacity_used

  validate(:capacity_total, :presence)
  validate(:capacity_total, :type, Float)
  validate(:capacity_used, :presence)
  validate(:capacity_used, :type, Float)

  def initialize(capacity_total = 0.0)
    @capacity_total = capacity_total
    @capacity_used  = 0.0
    super()
  end

  def type
    :cargo
  end

  def to_s
    "#{type.capitalize} railcar number #{number}," \
    " #{capacity_free} free capacity, #{capacity_used} used capacity"
  end

  def use_capacity(capacity_to_use)
    self.capacity_used += capacity_to_use if capacity_to_use <= capacity_free
  end

  def capacity_free
    capacity_total - capacity_used
  end

  protected

  attr_writer :capacity_used
end
