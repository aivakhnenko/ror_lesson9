require_relative 'station'
require_relative 'route'
require_relative 'railcar'
require_relative 'cargo_railcar'
require_relative 'passenger_railcar'
require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'

class Main
  def initialize
    @stations = []
    @routes   = []
    @trains   = []
    @commands = {}
    set_commands
  end

  def start
    print "\nWelcome to the Railroad Cockpit\n\n"
    show_commands_list
    loop do
      ask_user_to_select_command
    end
  end

  private

  attr_reader :stations, :routes, :trains, :commands

  def set_commands
    commands[:c0]  = { name: 'Show commands list'               }
    commands[:c1]  = { name: 'Add station'                      }
    commands[:c2]  = { name: 'Add train'                        }
    commands[:c3]  = { name: 'Add route'                        }
    commands[:c4]  = { name: 'Add station to route'             }
    commands[:c5]  = { name: 'Remote station from route'        }
    commands[:c6]  = { name: 'Assign route to train'            }
    commands[:c7]  = { name: 'Attach railcar to train'          }
    commands[:c8]  = { name: 'Remove railcar from train'        }
    commands[:c9]  = { name: 'Move train to next station'       }
    commands[:c10] = { name: 'Move train to previous station'   }
    commands[:c11] = { name: 'Show stations list'               }
    commands[:c12] = { name: 'Show trains list at station'      }
    commands[:c13] = { name: 'Show railcars list of train'      }
    commands[:c14] = { name: 'Occupy/use railcar seat/capacity' }
    commands[:c15] = { name: 'Show visited stations for train'  }
    commands[:c99] = { name: 'Exit'                             }
    commands.each { |i, c| c[:id]     = i.to_s[1..-1].rjust(2, ' ') }
    commands.each { |_, c| c[:action] = c[:name].downcase.gsub(%r{[ \/]}, '_') }
  end

  def show_commands_list
    puts 'Select command:'
    commands.each { |_, c| puts "ID #{c[:id]}: #{c[:name]}\n" }
  end

  def ask_user_to_select_command
    print "====================\n" \
          'Enter command ID: '
    command = commands["c#{gets.chomp}".to_sym]
    action = command ? command[:action] : 'unknown_command'
    send(action)
  rescue RuntimeError => e
    puts e.message
  end

  def unknown_command
    puts 'Unknown command'
  end

  def add_station
    print 'Enter station name: '
    station_name = gets.chomp
    station = Station.new(station_name)
    stations << station
    puts "#{station} successfully added"
  end

  def add_train
    print 'Enter train number: '
    train_number = gets.chomp
    print 'Enter c for cargo, p for passenger train: '
    train_type = gets.chomp
    case train_type
    when 'c' then train = CargoTrain.new(train_number)
    when 'p' then train = PassengerTrain.new(train_number)
    else raise 'Wrong train type'
    end
    trains << train
    puts "#{train} successfully added"
  end

  def add_route
    first_station = ask_user_to_select(:station, stations, 'first station')
    last_station  = ask_user_to_select(:station, stations, 'last station')
    route = Route.new(first_station, last_station)
    routes << route
    puts "#{route} successfully added"
  end

  def add_station_to_route
    route   = ask_user_to_select(:route)
    station = ask_user_to_select(:station)
    route.add_station(station)
  end

  def remote_station_from_route
    route   = ask_user_to_select(:route)
    station = ask_user_to_select(:station, route.stations)
    route.remove_station(station)
  end

  def assign_route_to_train
    train = ask_user_to_select(:train)
    route = ask_user_to_select(:route)
    train.assign_route(route)
  end

  def attach_railcar_to_train
    train = ask_user_to_select(:train)
    case train.type
    when :cargo
      print 'Enter total capacity volume: '
      capacity_total = gets.chomp.to_f
      train.attach_railcar(CargoRailcar.new(capacity_total))
    when :passenger
      print 'Enter total seats number: '
      seats_total = gets.chomp.to_i
      train.attach_railcar(PassengerRailcar.new(seats_total))
    end
  end

  def remove_railcar_from_train
    train   = ask_user_to_select(:train)
    railcar = ask_user_to_select(:railcar, train.railcars)
    train.remove_railcar(railcar)
  end

  def move_train_to_next_station
    train = ask_user_to_select(:train)
    train.goto_next_station
  end

  def move_train_to_previous_station
    train = ask_user_to_select(:train)
    train.goto_prev_station
  end

  def show_stations_list
    raise 'There are no stations' if stations.empty?
    stations.each { |station| puts station }
  end

  def show_trains_list_at_station
    station = ask_user_to_select(:station)
    raise 'There are no trains at station' if station.trains.empty?
    station.each_train { |train| puts train }
  end

  def show_railcars_list_of_train
    train = ask_user_to_select(:train)
    raise 'Train has no railcars' if train.railcars.empty?
    train.each_railcar { |railcar| puts railcar }
  end

  def occupy_use_railcar_seats_capacity
    train   = ask_user_to_select(:train)
    railcar = ask_user_to_select(:railcar, train.railcars)
    case railcar.type
    when :cargo
      print 'Enter capacity to use: '
      capacity_to_use = gets.chomp.to_f
      railcar.use_capacity(capacity_to_use)
    when :passenger
      railcar.occupy_seat
    end
  end

  def show_visited_stations_for_train
    train = ask_user_to_select(:train)
    station_history = train.station_history
    if station_history
      puts train.station_history
    else
      puts 'Train has not visited any station'
    end
  end

  def ask_user_to_select(array_type, array = nil, title = nil)
    array ||= case array_type
              when :station then stations
              when :route   then routes
              when :train   then trains
              end
    raise "There are no #{array_type}s" if array.empty?
    title ||= array_type.to_s
    puts "Select #{title}:"
    array.each_with_index { |value, index| puts "ID #{index}: #{value}" }
    print "Enter #{title} ID: "
    result_id = gets.to_i
    raise 'Wrong ID' if result_id.negative? || result_id >= array.size
    array[result_id]
  end
end

Main.new.start
