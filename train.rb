require_relative 'instance_counter'
require_relative 'accessors'
require_relative 'validation'
require_relative 'manufacturer'

class Train
  include InstanceCounter
  include Accessors
  include Validation
  include Manufacturer

  attr_reader :number, :speed, :railcars
  strong_attr_accessor :route, Route
  attr_accessor_with_history :station

  NUMBER_FORMAT = /^[a-z0-9]{3}-?[a-z0-9]{2}$/i

  validate(:number, :presence)
  validate(:number, :type, String)
  validate(:number, :format, NUMBER_FORMAT)
  validate(:speed, :presence)
  validate(:speed, :type, Float)
  validate(:railcars, :presence)
  validate(:railcars, :type, Array)

  @@all_trains = {}

  def self.find(number)
    @@all_trains[number]
  end

  def initialize(number)
    @number = number
    @speed = 0.0
    @railcars = []
    @route = nil
    @station = nil
    validate!
    register_instance
    @@all_trains[number] = self
  end

  def type; end

  def to_s
    "#{type.capitalize} train number #{number}, #{railcars.count} railcars"
  end

  def speed_up(speed_delta)
    self.speed += speed_delta if speed_delta.positive?
  end

  def stop
    self.speed = 0.0
  end

  def attach_railcar(railcar)
    railcars << railcar if speed.zero? && railcar.type == type
  end

  def remove_railcar(railcar)
    railcars.delete(railcar) if speed.zero?
  end

  def assign_route(route)
    self.route = route
    self.station = route.first_station
    station.arrive(self)
  end

  def goto_next_station
    raise 'Station is not assigned' unless station
    raise 'Train is already at the last station' if station == route.last_station
    station.depart(self)
    self.station = next_station
    station.arrive(self)
  end

  def goto_prev_station
    raise 'Station is not assigned' unless station
    raise 'Train is already at the first station' if station == route.first_station
    station.depart(self)
    self.station = prev_station
    station.arrive(self)
  end

  def prev_station
    raise 'Route is not assigned' unless route
    raise 'Train is at the first station' if station == route.first_station
    route.stations[route.stations.find_index(station) - 1]
  end

  def next_station
    raise 'Route is not assigned' unless route
    raise 'Train is at the last station' if station == route.last_station
    route.stations[route.stations.find_index(station) + 1]
  end

  def each_railcar
    railcars.each { |railcar| yield(railcar) }
  end

  protected

  attr_writer :speed, :railcars
end
