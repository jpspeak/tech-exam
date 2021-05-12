require_relative 'product'
require_relative 'bakery'

Product.create(name: 'Vegemite Scroll', code: 'VS5', packs: [{pack_of: 3, price: 6.99 },{pack_of: 5, price: 8.99}])
Product.create(name: 'Blueberry Muffin', code: 'MB11', packs: [{pack_of: 2, price: 9.95 },{pack_of: 5, price: 16.95},{pack_of: 8, price: 24.95}])
Product.create(name: 'Croissant', code: 'CF', packs: [{pack_of: 3, price: 5.95 },{pack_of: 5, price: 9.95},{pack_of: 9, price: 16.99}])

bakery = Bakery.new(Product.products)
puts bakery.order(['10 VS5', '17 MB11', '13 CF'])



