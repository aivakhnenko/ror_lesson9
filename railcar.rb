require_relative 'accessors'
require_relative 'validation'
require_relative 'manufacturer'

class Railcar
  include Accessors
  include Validation
  include Manufacturer

  attr_reader :number

  validate(:number, :presence)
  validate(:number, :type, Integer)

  def initialize
    @number = rand(999)
    validate!
  end

  def type; end

  def to_s
    "#{type.capitalize} railcar number #{number}"
  end
end
