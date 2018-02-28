require 'csv'
require 'time'

module RideShare
  class Trip
    attr_reader :id, :passenger, :driver, :start_time, :end_time, :cost, :rating

    def initialize(input)

      @id = input[:id]
      @driver = input[:driver]
      @passenger = input[:passenger]
      @start_time = input[:start_time]
      @end_time = input[:end_time]
      @cost = input[:cost]
      @rating = input[:rating]

      if @rating > 5 || @rating < 1
        raise ArgumentError.new("Invalid rating #{@rating}")

      end

      unless input[:start_time] == nil
        unless input[:start_time] <= input[:end_time]
          raise ArgumentError.new("Trip start time cannot be after it's end time. (got start time: #{input[:start_time]} - end time: #{input[:end_time]})")
        end
      end
    end

    def duration
      duration_in_seconds = end_time - start_time
      return duration_in_seconds
    end
  end
end
