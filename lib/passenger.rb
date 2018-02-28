module RideShare
  class Passenger
    attr_reader :id, :name, :phone_number, :trips

    def initialize(input)
      if input[:id] == nil || input[:id] <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero.")
      end

      @id = input[:id]
      @name = input[:name]
      @phone_number = input[:phone]
      @trips = input[:trips] == nil ? [] : input[:trips]
    end

    def get_drivers
      @trips.map{ |t| t.driver }
    end

    def add_trip(trip)
      @trips << trip
    end

    def sum_trip_cost
      total_cost = 0
      trips.each do |trip|
        total_cost += trip.cost
      end
      return total_cost
    end

    def sum_trip_time
      subtotal = 0
      trips.each do |trip|
        subtotal += trip.duration
      end
      return subtotal
    end
  end
end
