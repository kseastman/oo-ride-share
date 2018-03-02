require 'csv'
require_relative 'trip'

module RideShare
  class Driver
    attr_reader :id, :name, :vehicle_id, :status, :trips

    def initialize(input)
      if input[:id] == nil || input[:id] <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero. (got #{input[:id]})")
      end
      if input[:vin] == nil || input[:vin].length != 17
        raise ArgumentError.new("VIN cannot be less than 17 characters.  (got #{input[:vin]})")
      end

      @id = input[:id]
      @name = input[:name]
      @vehicle_id = input[:vin]
      @status = input[:status] == nil ? :AVAILABLE : input[:status]
      @trips = input[:trips] == nil ? [] : input[:trips]
    end

    def average_rating
      total_ratings = 0
      @trips.each do |trip|
        total_ratings += trip.rating
      end

      if trips.length == 0
        average = 0
      else
        average = (total_ratings.to_f) / trips.length
      end

      return average
    end

    def add_trip(trip)
      if trip.class != Trip
        raise ArgumentError.new("Can only add trip instance to trip collection")
      elsif trip.end_time == nil
      change_status
      end
      @trips << trip
    end

    def change_status
      if
        @status == :UNAVAILABLE
        @status = :AVAILABLE
      else
        @status = :UNAVAILABLE
      end
    end


    def total_revenue
      fee = 1.65
      driver_take = 0.8


      subtotal = 0
      @trips.each do |trip|
        if trip.cost == nil
          next
        else
          subtotal += (trip.cost - fee)
        end
        # Question, what if the cost is less than the fee?
      end

      total = subtotal * driver_take
      return total.round(2)
    end

    def average_revenue
      revenue = total_revenue
      hour_time = 0
      hour = 60 * 60
      trip_count = trips.length

      trips.each do |trip|
        if trip.end_time == nil
          trip_count -= 1
        else
          hour_time += trip.duration / hour
        end
      end
      revenue_per_hour = revenue / hour_time
      average_revenue_per_hour = revenue_per_hour / trip_count
      return average_revenue_per_hour
    end
  end
end
