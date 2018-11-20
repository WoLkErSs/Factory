# frozen_string_literal: true.
# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  class << self
    def new(*args_factory, &block)
      check_entity = args_factory.first.is_a? String
      check_string = !args_factory.first.empty?
      const_set(args_factory.shift.capitalize, create_klass(*args_factory, &block)) if check_entity && check_string
      create_klass(*args_factory, &block)
    end

    def create_klass(*args_factory, &block)
      Class.new do
        attr_accessor(*args_factory)

        define_method :initialize do |*arg_class|
          raise ArgumentError, 'Extra arguments passed' if args_factory.count < arg_class.count
          args_factory.zip(arg_class).to_h.each { |key, value| instance_variable_set("@#{key}", value) }
        end

        define_method :== do |other|
          self.class == other.class && self.values == other.values
        end

        define_method :values do
          instance_variables.map { |instance_var| instance_variable_get(instance_var) }
        end

        define_method :[] do |argument|
          (argument.is_a? Integer) ? values[argument] : instance_variable_get("@#{argument}")
        end

        define_method :[]= do |arg, value|
          instance_variable_set("@#{arg}", value) if args_factory.include? arg.to_sym
        end

        define_method :dig do |*arr|
          arr.reduce(self) { |memo, char| (memo[char].is_a? NilClass) ? (return nil) : memo[char] }
        end

        define_method :each do |&block|
          values.each(&block)
        end

        define_method :each_pair do |&block|
          args_factory.zip(values).each(&block)
        end

        define_method :length do
          values.count
        end

        define_method :members do
          args_factory
        end

        define_method :select do |&block|
          values.select(&block)
        end

        define_method :to_a do |num|
          values[num]
        end

        define_method :values_at do |*num|
          num.map { |x| values[x] }
        end

        alias_method :eql?, :==
        alias_method :to_a, :values
        alias_method :size, :length
        class_eval(&block) if block_given?
      end

    end
  end
end

Customer = Factory.new(:name, :address) do
  def greeting
    "Hello #{name}!"
  end
end
joe = Customer.new('Leha', {:b => {:a => 1}})
jue = Customer.new('Lely', 'Voronina 9')

jue.values_at 1
joe.dig(:address, :b, :a)
joe['name']
joe[:name]
joe[0]
jue == joe
