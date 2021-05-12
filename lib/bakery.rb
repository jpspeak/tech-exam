require_relative 'product.rb'
class Bakery 
    include Product
    
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
        self.print_order_details(order_details)
    end

    private
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
    
    def invalid_order_codes(orders)
        invalid_order_codes = []
        orders.each do |order|
            code = order.split(' ')[1]
            invalid_order_codes << code unless Product::search(code)
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

    def increment_pack_qty(packs, order_qty, start_index)
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

    def minimal_number_of_packs(order) 
        order_qty = order.split(' ')[0].to_i
        code = order.split(' ')[1]
        packs = Product::search(code)[:packs].map {|pack| pack.merge(qty: 0) }.sort_by {|pack| pack[:pack_of]}.reverse       
        packs = self.increment_pack_qty(packs, order_qty, 0)       
        while self.total_qty(packs) != order_qty do
            i = packs.length - 2
            while packs[i][:qty] == 0 do
                break if i == -1
                i -= 1
            end
            packs[i][:qty] -= 1
            start_index = i + 1
            packs = self.increment_pack_qty(packs, order_qty, start_index)
            if packs[0][:qty] == 0 && self.total_qty(packs) != order_qty
                packs = 'Invalid quantity'
                break
            end
        end
        packs.select { |o| o[:qty] != 0 }
    end

    def total_qty(packs)
        packs.map {|v| v[:pack_of] * v[:qty]}.reduce(:+)
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