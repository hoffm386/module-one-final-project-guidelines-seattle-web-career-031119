
mera = User.create(name: "mera")

pizza = Restaurant.create(name: "The pizza place")
gyros = Restaurant.create(name: "The gyros place")
pasta = Restaurant.create(name: "The pasta place")
sandwich = Restaurant.create(name: "The sandwich place")

r1 = Review.create(user: mera, restaurant: pizza, rating: 1, message: "Great food.")
r3 = Review.create(user: mera, restaurant: sandwich, rating: 2, message: "Great food.")
r1 = Review.create(user: mera, restaurant: gyros, rating: 3, message: "Great food.")
r3 = Review.create(user: mera, restaurant: pasta, rating: 4, message: "Great food.")
