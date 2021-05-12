module Product 
    @@products = []
    def self.products
        @@products
    end
    def self.create(product)
        validate_product(product)
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
            @@products << new_product
            new_product
        end
    end
    def self.search(code)
        @@products.find {|product| product[:code] == code}
    end
    private 
    def self.validate_product(product)
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