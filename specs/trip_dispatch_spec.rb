require_relative 'spec_helper'

describe "TripDispatcher class" do
  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = RideShare::TripDispatcher.new
      [:trips, :passengers, :drivers].each do |prop|
        dispatcher.must_respond_to prop
      end

      dispatcher.trips.must_be_kind_of Array
      dispatcher.passengers.must_be_kind_of Array
      dispatcher.drivers.must_be_kind_of Array
    end
  end

  describe "find_driver method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_driver(0) }.must_raise ArgumentError
    end

    it "finds a driver instance" do
      driver = @dispatcher.find_driver(2)
      driver.must_be_kind_of RideShare::Driver
    end
  end

  describe "find_passenger method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
    end

    it "finds a passenger instance" do
      passenger = @dispatcher.find_passenger(2)
      passenger.must_be_kind_of RideShare::Passenger
    end
  end

  describe "loader methods" do
    it "accurately loads driver information into drivers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_driver = dispatcher.drivers.first
      last_driver = dispatcher.drivers.last

      first_driver.name.must_equal "Bernardo Prosacco"
      first_driver.id.must_equal 1
      first_driver.status.must_equal :UNAVAILABLE
      last_driver.name.must_equal "Minnie Dach"
      last_driver.id.must_equal 100
      last_driver.status.must_equal :AVAILABLE
    end

    it "accurately loads passenger information into passengers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_passenger = dispatcher.passengers.first
      last_passenger = dispatcher.passengers.last

      first_passenger.name.must_equal "Nina Hintz Sr."
      first_passenger.id.must_equal 1
      last_passenger.name.must_equal "Miss Isom Gleason"
      last_passenger.id.must_equal 300
    end

    it "accurately loads trip info and associates trips with drivers and passengers" do
      dispatcher = RideShare::TripDispatcher.new

      trip = dispatcher.trips.first
      driver = trip.driver
      passenger = trip.passenger

      driver.must_be_instance_of RideShare::Driver
      driver.trips.must_include trip
      passenger.must_be_instance_of RideShare::Passenger
      passenger.trips.must_include trip

    end

    it 'stores start_time and end_time as time objects' do
      dispatcher = RideShare::TripDispatcher.new
      trip = dispatcher.trips.first

      trip_starts = trip.start_time
      trip_ends = trip.end_time

      trip_starts.must_be_instance_of Time
      trip_ends.must_be_instance_of Time
    end
  end

  describe "Wave 2: TripDispatcher#request_trip(passenger_id)" do

    it "assigns a driver to the trip" do
      dispatcher = RideShare::TripDispatcher.new
      result = dispatcher.request_trip(34)
      result.must_be_instance_of RideShare::Trip
      result.driver.wont_be_nil
    end

    # This test is superseded by later tests
    # it "chooses the first driver whose status is :AVAILABLE" do
    #   dispatcher = RideShare::TripDispatcher.new
    #   drivers = dispatcher.drivers
    #   driver_hash = Hash[drivers.collect { |driver| [driver.id, driver.status] } ]
    #   expected_value = driver_hash.key(:AVAILABLE)
    #
    #   result = dispatcher.request_trip(34)
    #
    #   result.driver.must_be_instance_of RideShare::Driver
    #   result.must_be_instance_of RideShare::Trip
    # end

    it "uses the current time for the start time" do
      dispatcher = RideShare::TripDispatcher.new
      result = dispatcher.request_trip(34)

      current_time = Time.now.to_s
      result_time = result.start_time.to_s

      result_time.must_equal current_time

    end

    it "end date, cost and rating are nil" do
      dispatcher = RideShare::TripDispatcher.new
      result = dispatcher.request_trip(34)

      result.end_time.must_be_nil
      result.cost.must_be_nil
      result.rating.must_be_nil
    end

    describe "edge cases for request_trip" do
      before do
        @dispatcher = RideShare::TripDispatcher.new
      end
      it "raises an error if there are no more available drivers" do
        drivers = @dispatcher.drivers


        proc{ drivers.each do |driver|
          @dispatcher.request_trip(14)
        end }.must_raise ArgumentError
      end
    end

    describe "TripDispatcher#request_trip - Limit Wave 1 Interactions" do
      before do
        @dispatcher = RideShare::TripDispatcher.new
        @result = @dispatcher.request_trip(34)
        @passenger = @result.passenger
        @driver = @result.driver
      end

      it "is an inprogress trip" do
        ended = @result.end_time
        ended.must_be_nil
      end

      it "ignores inprogress trips in Passenger#cost" do
        subtotal = 0
        @passenger.trips.each do |trip|
          unless trip.cost == nil
            subtotal += trip.cost
          end
        end
        expected_value = subtotal

        total_cost = @passenger.sum_trip_cost
        total_cost.must_equal expected_value
      end

      it "ignores inprogress trips in Driver#total_revenue" do
        subtotal = 0
        @driver.trips.each do |trip|
          if trip.cost == nil
            next
          else
            subtotal += trip.cost - 1.65
          end
        end
        expected_value = subtotal * 0.8

        result = @driver.total_revenue
        result.must_equal expected_value.round(2)
      end

      it "ignores inprogress trips in Driver#average_revenue" do
        hour = 60 * 60
        hour_time = 0
        @driver.trips.each do |trip|
          if trip.duration == nil
            next
          else
            hour_time += (trip.duration / hour)
          end
        end
        trip_count = @driver.trips.length - 1
        revenue = @driver.total_revenue
        expected = (revenue / hour_time) / trip_count

        test = @driver.average_revenue

        test.must_equal expected
      end
    end

    describe "Wave 3 - TripDispatcher#request_trip" do
      before do
        @passenger_id = 34
        @dispatcher = RideShare::TripDispatcher.new

      end

      it "helper method only selects available drivers" do
        available_drivers = @dispatcher.select_driver
        result = available_drivers.status
        result.wont_equal :UNAVAILABLE
      end

      it "Does not include drivers with in-progress trips" do
        result = @dispatcher.select_driver

        result.wont_be_nil
      end

      it "Selects the driver whose most recent trip was longest back" do
        # trips = @dispatcher.trips
        # most_recent = trips.first
        #
        # trips.each do |trip|
        #   driver = trip.driver
        #   if driver.status == :AVAILABLE
        #     if trip.end_time < most_recent.end_time
        #       most_recent = trip
        #     end
        #   end
        # end
        # expected_value = most_recent.driver.id

        expected_value = [14, 27, 6, 87, 75] #driver_id supplied by instructors


          result = @dispatcher.request_trip(1)
          result.driver.id.must_equal 14

      end
    end

  end
end
