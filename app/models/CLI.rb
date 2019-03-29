class CLI

  @@user = nil
  @@location = nil
  @@cuisine = nil
  @@restaurant = nil
  @@restaurants = nil
  @@find_hotspots = 0
  @@cheapest_hood = nil
  @@priciest_hood = nil
  @@densest_hood = nil
  @@rest_strata_hash = nil
  @@restaurants_master_list = nil

## Reader methods for Review class to access - added by Mera

  def self.user
    @@user
  end

  ## writer method only for testing
  def self.user=(user)
    @@user = user
  end

  def self.restaurant
    @@restaurant
  end

  def self.priciest_hood=(hash)
    @@priciest_hood = hash
  end

  def self.cheapest_hood=(hash)
    @@priciest_hood = hash
  end

  def self.densest_hood=(hash)
    @@priciest_hood = hash
  end

  def self.rest_strata_hash=(hash)
    @@priciest_hood = hash
  end

  def self.priciest_hood
    @@priciest_hood
  end

  def self.cheapest_hood
    @@priciest_hood
  end

  def self.densest_hood
    @@priciest_hood
  end

  def self.rest_strata_hash
    @@priciest_hood
  end

  def self.restaurants_master_list
    @@restaurants_master_list
  end

  ## ------------------------------------
  ## MENU HELPER METHODS
  ## ------------------------------------


  def self.main_menu(prompt)
    active = 1

    self.display_prompt(prompt)

    while active == 1

        user_response = STDIN.gets.chomp
        user_response.downcase!
        user_response.strip!

        if user_response.match(/^[\w\s]+$/) != nil #check if special characters are present in user input
              case user_response

              when "logout"
                active = 0
                system "clear"
                puts "OK, see you later #{@@user.name.capitalize}!"
                sleep(1.5)
                @@user = nil
                system "clear"
                self.user_entry

              when "search"
                active = 0
                system "clear"
                self.food_search

              when "find hotspots"
                active = 0
                @@find_hotspots = 1
                self.food_search

              when "back"
                active = 0
                self.get_restaurants

              when "review"
                active = 0
                Review.create_review

              when "see reviews"
                active = 0
                system "clear"
                Review.read_reviews

              when "update review"
                active = 0
                Review.update_review

              when "delete review"
                active = 0
                Review.delete_review

              when "quit"
                active = 0
                exit

              when "exit"
                active = 0
                exit

              when "!!!"
                active = 0
                exit

              else
                puts "\nI am not smart enough to understand that. Please enter a valid command.\n"
              end

        else
          puts "\nPlease enter a command that does not contain special characters.\n"
        end

    end

  end

  def self.prompt_hash
    {
      "search" => "Start a new search",
      "find hotspots" => "In a new city? Find the hotspots!",
      "logout" => "Log out of your account",
      "back" => "Go back to restaurants list",
      "review" => "Create a review of this restaurant",
      "see reviews" => "See all of your reviews",
      "update review" => "Update one of your reviews",
      "delete review" => "Delete one of your reviews",
      "quit" => "Leave I guess"
    }
  end

  def self.display_prompt(prompt)
    puts "—" * 80
    puts Paint["#{@@user.name.capitalize}, would you like to:", :bright, :bold, :green]
    prompt.each do |line|
      puts "\t#{line}:" + " "*(20-line.length) + "#{prompt_hash[line]}"
    end
    puts "\tquit: " + " "*15 + "#{prompt_hash['quit']}"
    puts "—" * 80
    print "> "
  end

  def self.menu_get_input(prompt, condition=nil)
    #binding.pry
    # Use to get a response from the user.
    # Condition can be {"alpha" => "any"} (alphabetical), {"number" => []}, or nil.

    active = 1
    while active == 1 do
      puts "#{prompt}"
      print "> "
      user_response = STDIN.gets.chomp
      case
      when condition == nil
        active = 0
        system "clear"
        return user_response.strip
      when condition.keys[0] == "alpha"
        if user_response.match(/^[\w\s]+$/) != nil
          active = 0
          system "clear"
          return user_response.strip
        else
          puts Paint["No special characters please!", :red]
        end
      when condition.keys[0] == "number"
        if condition.values[0].include?(user_response.to_i)
          active = 0
          system "clear"
          return user_response.to_i
        else
          puts Paint["Please enter a valid number!", :red]
        end
      when user_response.downcase == "quit" || "exit"
        active = 0
        system "clear"
        exit
      else
        active = 0
        puts "I don't really know how you got here"
        self.menu_get_input(prompt, condition)
      end
    end
  end

  ## ------------------------------------
  ## CLI/USER INTERACTIVE METHODS
  ## ------------------------------------

  def self.start
    system "clear"
    puts "hello world!"
    sleep(0.4)
    system "clear"
    puts Paint["Welcome to 'Eat or Quit' our Zomato based CLI!", :bright, :bold, :green]
    sleep(1.5)
    system "clear"
    self.user_entry
  end

  def self.user_entry
    prompt = "Please login by entering your first name:"
    condition = {"alpha" => "any"}
    username = self.menu_get_input(prompt, condition)
    @@user = User.find_or_create_by(name: username)
    system "clear"
    puts "You are now logged in as #{@@user.name.capitalize}"
    sleep(0)
    system "clear"
    self.main_menu(["search", "find hotspots", "see reviews", "logout"])
  end

  def self.food_search

    if @@find_hotspots == 0
      prompt = "\nEnter a neighborhood or city name\n"
    else
      prompt = "\nEnter a city\n"
    end
    condition = {"alpha" => "any"}
    location = self.menu_get_input(prompt, condition)
    self.choose_location(location)
  end

  def self.choose_location(location)
    location_options_array = API.location_suggestions(location)
    location_suggestions_hash = Processor.location_menu_prep(location_options_array)
    pretty_location_hash = Processor.pretty_location_menu(location_suggestions_hash, location_options_array)
    Processor.display_pretty_location_hash(pretty_location_hash)

    prompt = "\nEnter the number of the location you would like\n"
    condition = {"number" => (1..location_options_array.length).to_a }
    number = self.menu_get_input(prompt, condition)

    chosen_location_index = pretty_location_hash[number].values[0]
    @@location = location_options_array[chosen_location_index]
    if @@find_hotspots == 1
      self.get_hotspots
    else
      self.get_cuisines
    end
  end

  def self.get_hotspots
    @@find_hotspots = 0
    @@restaurants_master_list = API.get_restaurants_from_location(@@location)
    @@hoods_list= Processor.hoods_list(@@restaurants_master_list)
    @@densest_hood= Processor.densest_hood(@@restaurants_master_list)
    array = Processor.cost_by_hood(@@restaurants_master_list)
    @@cheapest_hood= array[0]
    @@priciest_hood= array[1]

    system "clear"
    Processor.pretty_hoods_list(@@hoods_list, @@location)
    puts "\nOf these neighborhoods:\n"
    puts "\n#{@@densest_hood[0]} had the most restaurants, with #{(@@densest_hood[1] / @@restaurants_master_list.count.to_f).round(2)*100}% of the total."
    Processor.pretty_dense_hood(@@densest_hood)
    Processor.pretty_price_minmax(array)
    Processor.pretty_strata_hash(Processor.rest_strata_hash(@@restaurants_master_list))
    puts

    self.main_menu(["search", "find hotspots", "see reviews", "logout"])

  end

  def self.get_cuisines
    @@restaurants_master_list = API.get_restaurants_from_location(@@location)
    hash_of_cuisines = Processor.most_occuring_cuisines(@@restaurants_master_list)

    hash_of_cuisines.each do |key, value|
      print "#{key}: "
      value.each {|key, value| puts "#{key} - #{value} restaurant(s)\n"}
    end

    prompt = "Choose which cuisine you would like"
    condition = {"number" => (1..hash_of_cuisines.length).to_a }
    chosen_cuisine_number = self.menu_get_input(prompt, condition)

    @@cuisine = hash_of_cuisines[chosen_cuisine_number].keys[0]
    self.get_restaurants
  end

  def self.get_restaurants
    @@restaurants = @@restaurants_master_list.select {|rest| rest["restaurant"]["cuisines"].include?(@@cuisine)}.uniq
    @@restaurants.sort_by! { |r| r["restaurant"]["user_rating"]["aggregate_rating"].to_f*-1 }
    restaurants_menu_hash = Hash.new
    @@restaurants.each.with_index(1) do |rest, index|
      restaurants_menu_hash[index] = {rest["restaurant"]["name"] => rest["restaurant"]["user_rating"]["aggregate_rating"]}
    end
    restaurants_menu_hash.each do |key, value|
      print "#{key}: "
      value.each {|key, value| puts "#{key}, (#{value} avg rating)\n"}
    end
    #needs to make multiple choice: "new search", "review one of the above rests"
    prompt = "Choose a number to view a restaurant"
    condition = {"number" => (1..restaurants_menu_hash.length).to_a}
    restaurant_number = self.menu_get_input(prompt, condition)

    @@restaurant = @@restaurants.find{|r| r['restaurant']['name'] == restaurants_menu_hash[restaurant_number].keys[0]}
    self.pick_restaurant
  end

  def self.pretty_restaurant_data
    ["—"*80,
     "Restaurant:                  #{@@restaurant['restaurant']['name']}",
     "—"*80,
     "Cuisine(s):                  #{@@restaurant['restaurant']['cuisines']}",
     "Average Rating:              #{@@restaurant['restaurant']['user_rating']['aggregate_rating']}",
     "Locality:                    #{@@restaurant['restaurant']['location']['locality']}",
     "Price Range:                 " + '$'*@@restaurant['restaurant']['price_range'].to_i,
     "Average Cost for Two:        $#{@@restaurant['restaurant']['average_cost_for_two'].to_i}",
     "Address:                     #{@@restaurant['restaurant']['location']['address']}"
  ]
  end

  def self.pick_restaurant
    self.pretty_restaurant_data.each {|line| puts "#{line}"}
    main_menu(["review", "back", "search", "find hotspots", "logout"])
  end
end
