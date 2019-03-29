
sarah = User.create(name: "mera")
ted = User.create(name: "ted")
lydia = User.create(name: "lydia")

pizza = Restaurant.create(name: "The pizza place")
gyros = Restaurant.create(name: "The gyros place")
pasta = Restaurant.create(name: "The pasta place")
sandwich = Restaurant.create(name: "The sandwich place")

r1 = Review.create(user: mera, restaurant: pizza, rating: 1, message: "Not good.")
r2 = Review.create(user: mera, restaurant: sandwich, rating: 2, message: "ok, could do better.")
r3 = Review.create(user: mera, restaurant: gyros, rating: 3, message: "Great food.")
r4 = Review.create(user: mera, restaurant: pasta, rating: 4, message: "Wowww!")
