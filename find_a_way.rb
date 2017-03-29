# A terminal app to take in a user's location, and where they want to go. It will
# print out the time and distance to get there and, if they want, export the directions
# to txt file.

require 'google_maps_service'
require 'terminal-table'
require_relative 'config'

##################### CLASSES ########################

# This connects to the GoogleMaps api to send back location data
class GoogleMaps

  attr_reader :maps
  # initializes the google maps api
  def initialize
    @maps = GoogleMapsService::Client.new(key: Config::API_KEY)
  end

  # Finds distance and time between locations
  def dist_time(origins, destinations, mode)

    puts "Calculating..."
    # This accesses the google maps system
    matrix = @maps.distance_matrix(origins, destinations,
      mode: mode,
      language: 'en-AU',
      avoid: 'tolls',
      units: 'metric')

    system 'clear'

    # This prints out the data
    puts "You're " +
    matrix[:rows][0][:elements][0][:distance][:text] + " " +
    "away from #{destinations}"
    puts "It'll take you" + " " +
    matrix[:rows][0][:elements][0][:duration][:text] + " " +
    "to get to #{destinations}"

    puts 'Press enter to continue'
    gets.chomp
    system 'clear'

  end

  # Spits out directions as JSON
  def directions(origins, destinations, mode)

    routes = @maps.directions(origins, destinations,
              mode: mode,
              alternatives: false)
  end

  # this accesses the directions and stores them in an array
  def access_directions(json_dir, street)

    directions = []
    # This changes arrays to hashes from the JSON data
    hash1 = Hash[*json_dir]
    array1 = hash1[:legs]
    hash2 = Hash[*array1]
    steps = hash2[:steps]

    arr_cycle = 0
    stop_loop = false

    while stop_loop == false



      puts "steps cycle inspect"
      puts steps[arr_cycle][:html_instructions].inspect
      puts stop_loop.inspect
      puts street.inspect
      # assigns the direction value to variable
      direction = steps[arr_cycle][:html_instructions]
      # assigns duraction value to variable
      duration = steps[arr_cycle][:duration][:text]
      # strip direction of html tag elemnets
      strip_dir = direction.gsub!(/(<[^>]*>)|\n|\t/s) {""}
      strip_dir = strip_dir.downcase
      puts "stripped html dir"
      puts strip_dir.inspect
      puts strip_dir.class

      # puts previous elements in array
      directions << strip_dir
      directions << duration

      # variable to cycle through array.
      arr_cycle += 1

      puts "test_street"
      # Finds the element in array that is equal to street name
      stop_loop = strip_dir.include?(street)
      #test_street = strip_dir.scan(street)
      puts stop_loop.inspect
      #this is where the problem is, it's not returning the street name.
      # Removes elemnent from array if it is in there
      # if test_street[0] != nil
      #   puts "testing if"
      #   test_street = test_street.fetch(0)
      # end

      # Tests if street name is equal to element in array, if true stops loop
      # if test_street == street
      #   stop_loop = true

      end

    return directions

  end

  # Extracts the street name from destination
  def extract_street(destination)
    words = destination.split(/\W+/)
    street = words[1]
  end

end

# This contains the table and the prompts for the user to enter in location data
class PromptsTable

  attr_accessor :prompts, :table, :address

  def initialize
    # All the prompts for the user
    @prompts = [
          "\tPlease enter your current location.\n
           Press enter to begin.", #0
          "Now enter your destination.\n
           Press enter to begin.",  #1
          "Lets start with you street \n number and street name: ", #2
          "Groovy, now put in your suburb: ", #3
          "Good. Now enter your State, just a few more steps: ", #4
          "You're one step closer to.\n
           Please enter your country: ", #5
           "Is this your address?\n #{@address}.\n
            (Y)es or (N)o? ", #6
           '*le sigh*, press enter to try again', #7
           "Remember Y = yes and N = no.\n
           Please select either Y or N to continue", #8
           "How do you want to get to there?\n
           (W)alk? (D)rive? or (P)ublic Transit? ", #9
           "Do you want to print out directions?\n
           (Y)es or (N)o", #10
           "\tDirections printed!\n
            Press enter to continue.", #11
           "Okay, no problem!\n
            Press enter to continue.", #12
           "Do you want to save directions to a file?", #13
           "Directions saved to directions.txt\n
            Press return to exit program." #14
        ]
  end

  # Creates the table to display prompts
  def prompt_sel(sel_num)

     @rows = []

     # This is a way to get around not being able to inset the @address
     # into the prompts array.
     if sel_num == 6
        temp1 = [
                "Is this the address?\n #{@address}.\n
                 (Y)es or (N)o? "
              ]
        @rows << temp1
     else
        temp = @prompts[sel_num]
        @rows << [temp]
     end

     # The table around the prompts
     @table = Terminal::Table.new :title => "Distance & Time?",
     :rows => @rows, :style => {:width => 55,  :border_i => "*"}

   end

   # Cycles through the prompts and stores location

  # Main promppts to ask user for destination and/or origin
  def ask_user(from_or_to)

     # Test if the user is entering origin or destination
     # Changes prompts starting point
     if from_or_to == 1
       @prompt_sel_count = 1
     else
       @prompt_sel_count = 0
     end

     in_loop_limit = 5

     puts prompt_sel(@prompt_sel_count)
     gets.chomp

     system 'clear'

     continue = 'n'

     @prompt_sel_count = 1

     # Cycles through prompts of address questions
     while continue != 'y'

       while @prompt_sel_count < in_loop_limit
         @prompt_sel_count += 1
         puts prompt_sel(@prompt_sel_count)

         if @prompt_sel_count == 2
           street = gets.chomp
           system 'clear'
         elsif @prompt_sel_count == 3
           suburb = gets.chomp
           system 'clear'
         elsif @prompt_sel_count == 4
           state = gets.chomp
           system 'clear'
         elsif @prompt_sel_count == 5
           country = gets.chomp
           system 'clear'
         end
       end

      @address = street + " " + suburb + " " + state + " " + country

      # 6 is this your address
      @prompt_sel_count += 1
      puts prompt_sel(@prompt_sel_count)
      correct = gets.chomp.downcase
      system 'clear'

      # checks if user entered correct address
       if correct == 'y'
         return @address.downcase
       elsif correct == 'n'
         # 7 le sigh
         @prompt_sel_count += 1
         puts prompt_sel(@prompt_sel_count)
         gets.chomp
         @prompt_sel_count = 1
         system 'clear'
       else
         # continually asks user to input corrects values if not y or n
         while correct != 'y' || correct != 'n'
           # 8 remember y = yes
           puts prompt_sel(8)
           correct = gets.chomp
           @prompt_sel_count = 1
           system 'clear'
           if correct == 'y'
             return @address.downcase
           elsif correct == 'n'
             # 7 le sigh
             puts prompt_sel(7)
             gets.chomp
             system 'clear'
             break
           end
         end
       end
   end
  end

  # Asks user for mode of transit
  def mode

     mode = 'a'

     while mode != 'w'|| mode != 'd' || mode != 'p'
       prompt_sel(9)
       puts @table

       mode = gets.chomp.downcase

       #system 'clear'

       if mode == 'w'
         return 'walking'
       elsif mode == 'd'
         return 'driving'
       elsif mode == 'p'
         return 'transit'
       else
         puts "Wrong input, please enter again. Soooo close!"
         system 'clear'
       end
     end
  end

  # Prints directions
  def print_dir(directions)

    puts prompt_sel(10)
    correct = gets.chomp.downcase
    system 'clear'

    # continually asks user to input corrects values if not y or n
    while correct != 'y' || correct != 'n'
      # Prints directions if y
      if correct == 'y'
        directions.each do |direction|
            puts direction
        end
        puts prompt_sel(11)
        gets.chomp
        break
      # Don't print
      elsif correct == 'n'
        puts prompt_sel(12)
        gets.chomp
        system 'clear'
        break
      # 8 remember y = yes
      else
        puts prompt_sel(8)
        correct = gets.chomp
        system 'clear'
      end
    end


  end

  #saves directions to file
  def save_to_file(dir_arr)

    puts prompt_sel(13)
    correct = gets.chomp.downcase
    system 'clear'

    # continually asks user to input corrects values if not y or n
    while correct != 'y' || correct != 'n'
      # Saves directions to txt file
      if correct == 'y'
        dir_save = File.new('directions' + '.txt', 'w+')
        dir_arr.each do |direction|
          dir_save.write(direction + "\n")
        end
        dir_save.close
        puts prompt_sel(14)
        gets.chomp
        break
      # Don't save
      elsif correct == 'n'
        puts prompt_sel(12)
        gets.chomp
        system 'clear'
        break
      # 8 remember y = yes
      else
        puts prompt_sel(8)
        correct = gets.chomp
        system 'clear'
      end
    end


  end
end

##################### MAIN ########################

# Create new CLASSES
m_prompt = PromptsTable.new
maps = GoogleMaps.new

# Ask user for origin, destination, and mode
# origin = m_prompt.ask_user(0)
# destination = m_prompt.ask_user(1)
# mode = m_prompt.mode

# Prints out how long it'll take and how far away
#maps.dist_time(origin, destination, mode)

origin = "44 crystal st, petersham, nsw, australia"
destination = "120 spencer st, melbourne, vic, australia"
mode = "driving"
# Saves directions JSON
json_dir = maps.directions(origin, destination, mode)

# Extracts the street name from destination to use as loop limiter
# when printing directions
street = maps.extract_street(destination)

# Converts JSON to accessible format to print
directions = maps.access_directions(json_dir, street)

# Prints directions if user chooses
m_prompt.print_dir(directions)

# Saves directions to file if user chooses
m_prompt.save_to_file(directions)
