class API

  def self.key
    API_KEY
  end

  def self.connect(query_url)
    # General purpose search, append in query_url with characteristics.
    url_string = "https://developers.zomato.com/api/v2.1/" + query_url
    response_string = RestClient::Request.execute(method: :get,
      url: url_string,
      headers: {"user-key": self.key},
      timeout: 10)
    JSON.parse(response_string)
  end

  def self.location_suggestions(location)
    # Takes the user's location query and returns the API's location suggestions.
    results = self.connect("locations?query=#{location}&count=10")["location_suggestions"]
    if results.length >= 1
      return results
    else
      puts "Sorry, no results found for '#{location}'.\n"
      CLI.food_search
    end
  end

  def self.get_restaurants_from_location(location_hash)
    # Once user has selected a location, first get x pages of restaurant results
    # from that city (results), and return as an array of restaurant hashes.
    # We get 20 results per page. Change "number".times to process multiple pages.
    restaurants = []
    10.times do |page|
      results = self.connect("search?entity_id=#{location_hash["entity_id"]}&entity_type=#{location_hash["entity_type"]}&start=#{(page-1)*20}")
      results["restaurants"].map {|rest| restaurants << rest}
    end
    restaurants
  end

end
