class Bakery
    
    def initialize(products)
        @products = products
    end
    
    def order(orders)
        return self.invalid_orders(orders) unless self.invalid_orders(orders) == nil
        order_details = {total_price: 0, orders: []}
        orders.each do |order|
            order_details[:total_price] += self.single_order_total_amount(self.minimal_number_of_packs(order))
            order_details[:orders] << (
                { 
                    code: order.split(' ')[1], 
                    qty: order.split(' ')[0],
                    packs: self.minimal_number_of_packs(order),
                    sub_total_price: self.single_order_total_amount(self.minimal_number_of_packs(order))
                }
            )
        end
        order_details
    end

    def print_order_details(order_details)
        order_details[:orders].each do |order|
            puts "#{order[:qty]} #{order[:code]}"
            order[:packs].each do |pack|
                puts "      #{pack[:qty]} x #{pack[:pack_of]} $#{(pack[:price] * pack[:qty]).round(2)}" 
            end
            puts "Sub Total: $#{order[:sub_total_price]}"
        end 
        puts "Total Price: $#{order_details[:total_price]}"
    end

    private
    def search_by_code(code)
        @products.find {|product| product[:code] == code}
    end
    
    def invalid_order_codes(orders)
        invalid_order_codes = []
        orders.each do |order|
            code = order.split(' ')[1]
            invalid_order_codes << code unless self.search_by_code(code)
        end
        invalid_order_codes
    end

    def invalid_orders(orders)
        return "Invalid code(s): #{self.invalid_order_codes(orders)}" if self.invalid_order_codes(orders).any?
        invalid_order_qty = []
        orders.each do |order|
            order_qty = order.split(' ')[0]
            invalid_order_qty << order if self.minimal_number_of_packs(order) == 'Invalid quantity'
        end
        return "Invalid order quantities for #{invalid_order_qty}" if invalid_order_qty.any?
    end

    def increment_pack_qty(start_index, packs, order_qty)
        packs[start_index..-1].each_with_index do |*,i| 
            total_qty = 0
            while total_qty < order_qty
                packs_copy = packs.dup.map(&:dup)
                packs_copy[i+start_index][:qty] += 1
                total_qty = packs_copy.map {|v| v[:pack_of] * v[:qty]}.reduce(:+)
                packs = packs_copy if total_qty <= order_qty
            end
            break if total_qty == order_qty
        end
        packs
    end

    # returns array of hashes sorted by :pack_of with appended qty: 0
    # e.g.,[{:pack_of=>3, :price=>5.95, :qty=>0}, {}, {}]
    def product_packs_in_desc_order(code)
        self.search_by_code(code)[:packs].map {|pack| pack.merge(qty: 0) }.sort_by {|pack| pack[:pack_of]}.reverse
    end

    def minimal_number_of_packs(order) 
        order_qty = order.split(' ')[0].to_i
        code = order.split(' ')[1]
        packs = self.product_packs_in_desc_order(code)
        start_index = 0
        packs = self.increment_pack_qty(start_index,packs,order_qty)
        
        while packs.map {|v| v[:pack_of] * v[:qty]}.reduce(:+) != order_qty do
            i = (packs.length - 1) 
            i -= 1 if i == (packs.length - 1)
            while packs[i][:qty] == 0 do
                break if i == -1
                i -= 1
            end
            packs[i][:qty] -= 1
            start_index = i + 1
            packs = self.increment_pack_qty(start_index,packs,order_qty)
            
            if packs[0][:qty] == 0 && (packs.map {|v| v[:pack_of] * v[:qty]}.reduce(:+)) != order_qty
                packs = 'Invalid quantity'
                break
            end
        end
        packs.select { |o| o[:qty] != 0 }
    end

    def single_order_total_amount(order)
        return order if order == "Invalid quantity"
        total_amount = 0
        order.each do |pack|
            total_amount += (pack[:price] * pack[:qty])
        end
        total_amount.round(2)
    end
end
products = [
    {
        name: 'Vegemite Scroll',
        code: 'VS5',
        packs: [
            {
                pack_of: 3,
                price: 6.99,
            },
            {
                pack_of: 5,
                price: 8.99,
            },
        ]
    },
    {
        name: 'Blueberry Muffin',
        code: 'MB11',
        packs: [
            {
                pack_of: 2,
                price: 9.95,
            },
            {
                pack_of: 5,
                price: 16.95,
            },
            {
                pack_of: 8,
                price: 24.95,
            },
        ]
    },
    {
        name: 'Croissant',
        code: 'CF',
        packs: [
            {
                pack_of: 3,
                price: 5.95,
            },
            {
                pack_of: 5,
                price: 9.95,
            },
            {
                pack_of: 9,
                price: 16.99,
            },
        ]
    }
]
# bakery = Bakery.new(products)
# orders = bakery.order(['10 VS5', '17 MB11', '13 CF'])
# bakery.print_order_details(orders)

class Product 
    def initialize
        @products = []
    end
    def all
        @products
    end
    def create(product)
        self.validate_product(product)
        new_product = {}
        product.each do |key, value|
            case key
            when :name
                new_product[key] = value
            when :code
                new_product[key] = value
            when :packs
                new_product[key] = value
            else
                new_product = {}
            end    
        end
        if new_product.any?
            @products << new_product
            new_product
        end
    end
    private 
    def validate_product(product)
        raise TypeError, 'create expects a hash' unless product.kind_of?(Hash)
        raise ArgumentError,  ":name key is required" unless product.key?(:name)
        raise ArgumentError,  ":name value is required" unless product[:name]
        raise ArgumentError,  ":code key is required" unless product.key?(:code)
        raise ArgumentError,  ":code value is required" unless product[:code]
        raise ArgumentError,  ":packs key is required" unless product.key?(:packs)
        raise TypeError, ':packs expects an array' unless product[:packs].kind_of?(Array)
        raise TypeError, ':packs value expects a hash' unless product[:packs].all? {|val| val.is_a? Hash}
        raise ArgumentError,  ":pack_of key is required" unless product[:packs].all? {|val| val.key?(:pack_of)}
        raise ArgumentError,  ":pack_of value is required" unless product[:packs].all? {|val| val[:pack_of]}
        raise ArgumentError,  ":pack_of value must be an Integer" unless product[:packs].all? {|val| val[:pack_of].class == Integer}
        raise ArgumentError,  ":price key is required" unless product[:packs].all? {|val| val.key?(:price)}
        raise ArgumentError,  ":price value is required" unless product[:packs].all? {|val| val[:price]}
        raise ArgumentError,  ":price value must be an Numeric" unless product[:packs].all? {|val| val[:price].is_a?(Numeric)}
    end
end

product = Product.new
product.create(name: 'Vegemite Scroll', code: 'VS5', packs: [{pack_of: 4, price: 5 },{pack_of: 5, price: 4}])
product.create(name: 'Blueberry Muffin', code: 'MB11', packs: [{pack_of: 4, price: 5 },{pack_of: 5, price: 4}])
product.create(name: 'Croissant', code: 'CF', packs: [{pack_of: 4, price: 5 },{pack_of: 5, price: 4}])

puts product.all




