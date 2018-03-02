require 'csv'
require 'time'
require 'pry'

require_relative 'driver'
require_relative 'passenger'
require_relative 'trip'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize
      @drivers = load_drivers
      @passengers = load_passengers
      @trips = load_trips
    end

    def load_drivers
      my_file = CSV.open('support/drivers.csv', headers: true)

      all_drivers = []
      my_file.each do |line|
        input_data = {}
        # Set to a default value
        vin = line[2].length == 17 ? line[2] : "0" * 17

        # Status logic
        status = line[3]
        status = status.to_sym

        input_data[:vin] = vin
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:status] = status
        all_drivers << Driver.new(input_data)
      end

      return all_drivers
    end

    def find_driver(id)
      check_id(id)
      @drivers.find{ |driver| driver.id == id }
    end

    def load_passengers
      passengers = []

      CSV.read('support/passengers.csv', headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        passengers << Passenger.new(input_data)
      end

      return passengers
    end

    def find_passenger(id)
      check_id(id)
      @passengers.find{ |passenger| passenger.id == id }
    end

    def load_trips
      trips = []
      trip_data = CSV.open('support/trips.csv', 'r', headers: true, header_converters: :symbol)

      trip_data.each do |raw_trip|
        driver = find_driver(raw_trip[:driver_id].to_i)
        passenger = find_passenger(raw_trip[:passenger_id].to_i)

        parsed_trip = {
          id: raw_trip[:id].to_i,
          driver: driver,
          passenger: passenger,
          start_time: Time.parse(raw_trip[:start_time]),
          end_time: Time.parse(raw_trip[:end_time]),
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i
        }

        trip = Trip.new(parsed_trip)
        driver.add_trip(trip)
        passenger.add_trip(trip)
        trips << trip
      end

      trips
    end

    def least_recent
      last_trips = []
      drivers.each do |driver|
        unless driver.trips.first == nil
          driver.trips.sort! do |trip1, trip2|
            trip1.end_time <=> trip2.end_time
          end
        end
      end

      drivers.each do |driver|
        unless driver.trips.first == nil
          last_trips << driver.trips.last
        end
      end


      completed_trips = last_trips.find_all do |trip|
        trip.end_time != nil && trip.driver.status == :AVAILABLE
      end
      trips_hash = Hash[completed_trips.collect {|trip| [trip.driver.id, trip.end_time]}]
      sorted_trips = trips_hash.sort {|first_trip, second_trip| first_trip[1] <=> second_trip[1]}
      # if trip.end_time > least_recent.end_time
      #   least_recent = trip
      # end
      # binding.pry
      return find_driver(sorted_trips.first[0])
    end

    def select_driver

      available_driver = drivers.find_all{ |driver| driver.status == :AVAILABLE }
      least_recent
      if available_driver.empty?
        raise ArgumentError.new("No drivers currently available.")
      else
        return least_recent
      end
    end

    def request_trip(passenger_id)
      driver = select_driver
      id = trips.length + 1

      passenger = find_passenger(passenger_id)

      trip_data = {
        id: id,
        driver: driver,
        passenger: passenger
      }
      new_trip = Trip.new(trip_data)
      trips << new_trip
      passenger.add_trip(new_trip)
      driver.add_trip(new_trip)

      return new_trip
    end

    def inspect
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)}>"
    end

    private

    def check_id(id)
      if id == nil || id <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero. (got #{id})")
      end
    end
  end
end
