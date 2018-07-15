require_relative 'instance_counter'
require_relative 'accessors'
require_relative 'validation'

class Route
  include InstanceCounter
  include Accessors
  include Validation

  attr_reader :stations

  validate(:stations, :presence)
  validate(:stations, :type, Array)

  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    validate!
    register_instance
  end

  def to_s
    "Route from #{first_station.name} to #{last_station.name}"
  end

  def first_station
    stations.first
  end

  def last_station
    stations.last
  end

  def add_station(station)
    raise 'Route already has this station' if stations.include?(station)
    stations.insert(-2, station)
  end

  def remove_station(station)
    raise 'You cannot remove first station' if station == first_station
    raise 'You cannot remove last station'  if station == last_station
    stations.delete(station)
  end

  def stations_list
    stations.each { |station| puts station.name }
  end
end
