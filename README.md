# Ride Share
Remember the ride share exercise we did with designing and creating a system to track the ride share data from a CSV file? We did a lot of great work on this exercise in creating arrays and hashes of data, but we've learned a lot since we did that exercise!

Now, we're going to use our understanding of classes, methods and attributes to create an object-oriented implementation of our ride share system.

This is a [level 2](https://github.com/Ada-Developers-Academy/pedagogy/blob/master/rule-of-three.md) individual project.

## Learning Goals
Reinforce and practice all of the Ruby and programming concepts we've covered in class so far:
- Creating and instantiating classes with attributes
- Creating class methods and instance methods within our classes
- Writing pseudocode and creating tests to drive the creation of our code


## Context
We have a code base that already pulls data from CSV files and turns them into collections of the following objects:
- `Driver`s
- `Passenger`s
- `Trip`s

All of this data is managed in a class called `TripDispatcher`. Our program will contain _one_ instance of `TripDispatcher`, which will load and manage the lists of `Driver`s, `Passenger`s and `Trip`s.

We are going to continue making functionality that works with this data, such as finding the duration of a specific trip or the total amount of money a passenger has spent, and also make functionality to create a new trip.

### The Code So Far
#### Driver
Each `Driver` has:

**Attribute**|**Description**
-----|-----
id|The Driver's ID number
name|The name of the Driver
vehicle\_identification|The driver's Vehicle Identification Number (VIN Number), Each vehicle identification number should be a specific length to ensure it is a valid vehicle identification number
status|Indicating availability, a driver's availability should be either `:AVAILABLE` or `:UNAVAILABLE`

Each `Driver` instance is able to:

**Method**|**Description**
-----|-----
average_rating  |  retrieve an average rating for that driver based on all trips taken

#### Passenger
Each `Passenger` has:

**Attribute**|**Description**
-----|-----
id|The Driver's ID number
name|The name of the Driver
Phone Number|The Passenger's Phone Number which must be in phone number format (XXX) XXX-XXXX
trips|A list of trips that only this passenger has taken

Each `Passenger` instance is able to:

**Method**|**Description**
-----|-----
get_drivers  |  retrieve the list of all previous driver instances associated with trips this passenger has taken

#### Trip
Each `Trip` has:

**Attribute**|**Description**
-----|-----
id|The Driver's ID number
passenger|The passenger on the trip
driver|The driver for the trip
rating|The rating given by the passenger, a number 1-5

Each `Trip` instance is able to:

**Method**|**Description**
-----|-----
driver  |  retrieve the associated driver instance
passenger  |  retrieve the associated passenger instance

#### TripDispatcher
The `TripDispatcher` has:

**Attribute**|**Description**
-----|-----
drivers|A list of all drivers in the system|a collection of Driver instances
passengers|A list of all passengers in the system|a collection of Passenger instances
trips|A list of all trips taken in the system|a collection of Trip instances

The `TripDispatcher` has the following responsibilities:
- load collections of `Driver`s, `Passenger`s, and `Trip`s from CSV files
- store and manage this data into separate collections

The `TripDispatcher` does the following:
- on instantiation, loads and creates `Trip`s, `Passenger`s, and `Driver`s and stores them into collections

The `TripDispatcher` instance is able to:

**Methods**|**Description**
-----|-----
drivers, passengers, trips  |  retrieve the collection of `Trip`s, `Passenger`s, and `Driver`s
find_driver  |  find an instance of `Driver` given an ID
find_passenger  |  find an instance of `Passenger` given an ID

By the end of this project, a `TripDispatcher` will be able to:
- create new trips with assigning appropriate passengers and drivers

## Getting Started

We will use the same project structure we used for the previous project. Classes should be in files in the `lib` folder, and tests should be in files in the `specs` folder. You will run tests by executing the `rake` command, as configured in a Rakefile.

The `support` folder contains CSV files which will drive your system design. Each CSV corresponds to a different type of object _as well as_ creating a relationship between different objects.

### Setup
1. Fork this repository in GitHub
1. Clone the repository to your computer
1. Run `rake` to run the tests

### Process
You should use the following process as much as possible:

1. Write pseudocode
1. Write test(s)
1. Write code
1. Refactor

## Requirements

### Baseline

To start this project, take some time to get familiar with the code. Do the following in this order:
1. Read through all of the tests
1. Look at the provided CSV files: `support/drivers.csv`, `support/passengers.csv`, `support/trips.csv`
1. Then look through the ruby files in the `lib` folder

Create a diagram that describes how each of these classes and methods (messages) interact with one another as well as with the CSV files.

**Exercise:** Look at this requirement in Wave 1: "For a given driver, calculate their total revenue for all trips. Each driver gets 80% of the trip cost after a fee of $1.65 is subtracted." Spend some time writing pseudocode for this.

### Wave 1

The purpose of Wave 1 is to help you become familiar with the existing code, and to practice working with enumerables.

#### 1.1: Upgrading Dates

Currently our implementation saves the start and end time of each trip as a string. This is our first target for improvement. Instead of storing these values as strings, we will use Ruby's built-in `Time` class. You should:

1. Spend some time reading the docs for `Time` - you might be particularly interested in `Time.parse`
1. Modify `TripDispatcher#load_trips` to store the `start_time` and `end_time` as `Time` instances
1. Add a check in `Trip#initialize` that raises an `ArgumentError` if the end time is before the start time, and a corresponding test
1. Add an instance method to the `Trip` class to calculate the _duration_ of the trip in seconds, and a corresponding test

**Hint:** If you're hitting a `NoMethodError` for `Time.parse`, be aware that you need to `require 'time'` in order for it to work. This is a weird quirk of how the library is designed.

#### 1.2: Aggregate Statistics

Now that we have data for cost available for every trip, we can do some interesting data processing. Each of these should be implemented as an instance method on `Driver` or `Passenger`.

1. Add an instance method to `Passenger` that will return the _total amount of money_ that passenger has spent on their trips
1. Add an instance method to `Passenger` that will return the _total amount of time_ that passenger has spent on their trips
1. Add an instance method to `Driver` to calculate that driver's _total revenue_ across all their trips. Each driver gets 80% of the trip cost _after_ a fee of $1.65 is subtracted.
1. Add an instance method to `Driver` to calculate that driver's _average revenue per hour_ spent driving, using the above formula for revenue

**All of these methods must have tests.**

### Wave 2

Our program needs a way to make new trips and appropriately assign a driver and passenger.

This logic will be handled by our `TripDispatcher` in a new instance method: `TripDispatcher#request_trip(passenger_id)`. When we create a new trip with this method, the following will be true:
- The passenger ID will be supplied (this is the person requesting a trip)
- Your code should automatically assign a driver to the trip
  - For this initial version, choose the first driver whose status is `:AVAILABLE`
- Your code should use the current time for the start time
- The end date, cost and rating will all be `nil`
  - The trip hasn't finished yet!

You should use this information to:

- Create a new instance of `Trip`
- Modify this selected driver using a new helper method in `Driver`:
  - Add the new trip to the collection of trips for that `Driver`
  - Set the driver's status to `:UNAVAILABLE`
- Modify the passenger for the trip using a new helper method in `Passenger`:
  - Add the new trip to the collection of trips for the `Passenger`
- Add the new trip to the collection of all `Trip`s in `TripDispatcher`
- Return the newly created trip

**All of this code must have tests.** Things to pay attention to:
- Was the trip created properly?
- Were the trip lists for the driver and passenger updated?
- Was the driver who was selected `AVAILABLE`?
- What happens if you try to request a trip when there are no `AVAILABLE` drivers?

#### Interaction with Wave 1

One thing you may notice is that this change breaks your code from Wave 1, possibly in subtle ways. We've added a new kind of trip, an _in-progress_ trip, that is missing some of the values you need to compute those numbers.

Your code from wave 1 should _ignore_ any in-progress trips. That is to say, any trip where the end time is `nil` should not be included in your totals.

You should also add explicit tests for this new situation. For example, what happens if you attempt to calculate the total money spent for a `Passenger` with an in-progress trip, or the average hourly revenue of a `Driver` with an in-progress trip?

### Wave 3

We want to evolve `TripDispatcher` so it assigns drivers in more intelligent ways. Every time we make a new trip, we want to pick drivers who haven't completed a trip in a long time.

In other words, we should assign the driver to **the available driver whose most recent trip ending is the oldest compared to today.**

Modify `TripDispatcher#request_trip` to use the following rules to select a `Driver`:
- The `Driver` must have a status of `AVAILABLE`
- The `Driver` must not have any in-progress trips (end time of `nil`)
- From the `Driver`s that remain, select the one whose most recent trip ended the longest time ago

For example, if we have three drivers, each with two trips:

Driver Name | Status        | Trip 1 end time | Trip 2 end time
---         | ---           | ---             | ---
Ada         | `AVAILABLE`   | Jan 3, 2018     | Jan 9, 2018
Katherine   | `AVAILABLE`   | Jan 1, 2018     | Jan 12, 2018
Grace       | `UNAVAILABLE` | Jan 5, 2018     | `nil`

Grace is excluded because they are not `AVAILABLE`, and because they have one in-progress trip.

Of Ada and Katherine, we prefer Ada, because their most recent trip is older.

**All of this code must have tests.** -->

## What Instructors Are Looking For
Check out the [feedback template](feedback.md) which lists the items instructors will be looking for as they evaluate your project.
