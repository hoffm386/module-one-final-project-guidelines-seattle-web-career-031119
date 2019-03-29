class Review < ActiveRecord::Base

  @@reviews_hash = {}

  belongs_to :user
  belongs_to :restaurant

## HELPER METHODS --------------------------------------------------------------------

  def self.print_single_review(review_obj)
    ## prints out the passed review
    puts "\n#{review_obj.restaurant.name}"
    puts "\tRating: #{review_obj.rating}"
    puts "\tReview: #{review_obj.message}\n"
  end

  def self.make_review_hash
    #create a hash of all reviews with numerical keys
    @@reviews_hash.clear
    Review.all.where(user: CLI.user).each.with_index(1) {|review, index|
      @@reviews_hash[index] = [review.restaurant.name, review.rating, review.message, review.id]
    }
  end

  def self.get_rating
    ## prompt user for resto's rating
    prompt = "What would you rate this restaurant? (1-5)"
    CLI.menu_get_input(prompt, {"number" => (1..5).to_a})
  end

  def self.get_message
    ## prompt user for review message
    puts "\nPlease write a brief review."
    STDIN.gets.strip
  end

  def self.find_review_from_user_input(user_input)
    # initialize a blank name
    review_id = nil
    # iterate over pretty hash and find review id from index number
    @@reviews_hash.each {|key, value|
      if key == user_input
        review_id = value[3]
      end
    }
    #find review by review id
    CLI.user.reviews.find {|review|
      review.id == review_id
    }
  end

## CRUD METHODS -----------------------------------------------------------------------

  def self.create_review
    rating = self.get_rating
    message = self.get_message
    ## make restaurant object and review object and save to our tables
    restaurant = Restaurant.find_or_create_by(name: CLI.restaurant['restaurant']['name'])
    review = Review.create(user: CLI.user, restaurant: restaurant, rating: rating, message: message)
    ## show the user their new review
    system "clear"
    puts "\nYour new review:"
    self.print_single_review(review)
    ## ask user where they want to go next
    prompt = ["see reviews", "search", "find hotspots", "logout"]
    CLI.main_menu(prompt)
  end

  def self.read_reviews
    ## if no reviews exist then go back to menu
    if Review.all.where(user: CLI.user).empty?
      puts "\nYou have no reviews! Go start a search to find a restaurant to review!"
      prompt = ["search", "find_hotspots", "logout"]
      CLI.main_menu(prompt)
    else
      ## make sure reviews_hash is up to date
      self.make_review_hash
      ## send them back to menu if there are no reviews to view
      puts "\nYour Reviews:\n"
      ## iterate over reviews hash and print them to console
      @@reviews_hash.each {|key, value|
        puts "#{key}: #{value[0]} \n\t Rating: #{value[1]} \n\t Review: #{value[2]}\n"
      }
      ## ask user where they want to go next
      prompt = ["update review", "delete review", "search", "find hotspots", "logout"]
      CLI.main_menu(prompt)
    end
  end

  def self.update_review
    prompt = "Type number of review you wish to edit"
    review_num = CLI.menu_get_input(prompt, {"number" => (1..@@reviews_hash.length).to_a})
    # get the right review from the index the user gave
    review = self.find_review_from_user_input(review_num)
    ## get new rating and message
    rating = self.get_rating
    message = self.get_message
    ## update those fields in the database
    review.update(rating: rating, message: message)
    ##print out new version of review
    system "clear"
    puts "\nYour new review:"
    self.print_single_review(review)
    ## ask user where they want to go next
    prompt = ["see reviews", "search", "find hotspots", "logout"]
    CLI.main_menu(prompt)
  end

  def self.delete_review
    prompt =  "Type number of review you want to delete"
    review_num = CLI.menu_get_input(prompt, {"number" => (1..@@reviews_hash.length).to_a})
    # get the right review from the index the user gave
    review = self.find_review_from_user_input(review_num)
    ## let the user know what they deleted
    system "clear"
    puts "\nYou have deleted the following review."
    self.print_single_review(review)
    ## delete it
    review.delete
    ## ask user where they want to go next
    prompt = ["see reviews", "search", "find hotspots", "logout"]
    CLI.main_menu(prompt)
  end

end
