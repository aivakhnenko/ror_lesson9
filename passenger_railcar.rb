require_relative 'accessors'
require_relative 'validation'

class PassengerRailcar < Railcar
  include Accessors
  include Validation

  attr_reader :seats_total, :seats_occupied

  validate(:seats_total, :presence)
  validate(:seats_total, :type, Integer)
  validate(:seats_occupied, :presence)
  validate(:seats_occupied, :type, Integer)

  def initialize(seats_total = 0)
    @seats_total    = seats_total
    @seats_occupied = 0
    super()
  end

  def type
    :passenger
  end

  def to_s
    "#{type.capitalize} railcar number #{number}," \
    " #{seats_free} free seats, #{seats_occupied} occupied seats"
  end

  def occupy_seat
    self.seats_occupied += 1 if seats_free.positive?
  end

  def seats_free
    seats_total - seats_occupied
  end

  protected

  attr_writer :seats_occupied
end
