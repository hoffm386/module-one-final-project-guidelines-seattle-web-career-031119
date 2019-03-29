class Processor

  def self.display_pretty_location_hash(hash)
    hash.each do |key, value|
      print "#{key}: "
      value.each {|key, value| puts "#{key}\n"}
    end
  end

  def self.location_menu_prep(locations)
    # Filters out non-US locations and returns an array of indexes to the
    # locations from the api_location_suggestions hash
    location_suggestions_hash = []
    locations.each_with_index do |loc, i|
      if loc["country_id"] == 216
        location_suggestions_hash << i
      end
    end
    location_suggestions_hash
  end

  def self.pretty_location_menu(location_suggestions_hash, locations)
    # Takes the suggestions menu index
    loc_menu_hash = Hash.new
    menu_number = 1
    location_suggestions_hash.map do |itemno|
      #puts "#{menu_number}. #{locations[itemno]['title']}"
      state = API.connect("cities?city_ids=#{locations[itemno]["city_id"]}")["location_suggestions"][0]["state_name"]
      loc_menu_hash[menu_number] = {"#{locations[itemno]['title']}, #{state}"  => itemno}
      menu_number += 1
    end
    loc_menu_hash
  end

  def self.most_occuring_cuisines(restaurants)
    # Take in a hash of restaurants and make a hash of cuisines (keys) and frequency (values)
    cuis_hash = Hash.new(0)
    restaurants.map do |res|
      cuisine_array = []
      cuisine_array = res["restaurant"]["cuisines"].split(", ")
      cuisine_array.map {|c| cuis_hash[c] += 1 }
    end
    # Sorts hash by values, turning it into an array and back
    cuis_hash = cuis_hash.sort { |l, r| r[1]<=>l[1] }.to_h
    final_hash = Hash.new
    cuis_hash.keys.each.with_index(1) do |key, index|
      final_hash[index] = {key => cuis_hash[key]}
    end
    final_hash

  end

  def self.hotspots_parse(cli_rest_list)
    binding.pry

    #densest restaurant area
    rest_count_hash = Hash.new(0)
    hoods_list = cli_rest_list.map{|r| r["restaurant"]["location"]["locality"] }.uniq
    hoods_list.map do |hood|
      rest_count_hash[hood] = cli_rest_list.select{|r| r["restaurant"]["location"]["locality"] == hood}.count
    end
    densest_hood = rest_count_hash.max_by{ |k,v| v }

    #average cost for two, average by hood
    hood_price_hash = Hash.new(0)
    hood_arrays = Hash.new(0)
    hoods_list.map do |hood|
      hood_array = cli_rest_list.select{|r| r["restaurant"]["location"]["locality"] == hood}
      hood_arrays[hood] = hood_array
      hood_price_hash[hood] = hood_array.reduce(0) { |sum, r| sum + r["restaurant"]["average_cost_for_two"]}/hood_array.count
    end
    priciest_hood = hood_price_hash.max_by{ |k, v| v }
    cheapest_hood = hood_price_hash.min_by{ |k, v| v }

    # % of restaurants by hood in high, medium, and low end
    hood_arrays.map do |array|
      hood_name = array.first
      rest_strata_hash[hood_name] = {low: 0, med: 0, hi: 0}
    end

    hood_arrays.map do |hood_array|
      hood_name = hood_array.first
      rest_strata_hash[hood_name][:low] = hood_array[1].select { |r| r["restaurant"]["average_cost_for_two"] <= 25}.count.to_f / hood_array[1].count
      rest_strata_hash[hood_name][:med] = hood_array[1].select { |r| (r["restaurant"]["average_cost_for_two"] >= 25) && (r["restaurant"]["average_cost_for_two"] <= 55) }.count.to_f / hood_array[1].count
      rest_strata_hash[hood_name][:hi] = hood_array[1].select { |r| r["restaurant"]["average_cost_for_two"] >= 55}.count.to_f / hood_array[1].count
    end



  end

end
