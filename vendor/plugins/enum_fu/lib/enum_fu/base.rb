# encoding: utf-8
module EnumFu
  module Base
    def self.included(base)
      base.send :extend,  ClassMethods
    end
    
    module ClassMethods
      # make a enum colume in active record model 
      # db schema
      #	  create_table 'users' do |t|
      #	    t.column 'role', :integer, :limit => 2
      #	  end
      #
      # model
      #	  class User < ActiveRecord::Base
      #	    acts_as_enum :role, [:customer, :admin]
      #	  end
      def acts_as_enum(name, values)
        # keep original name  in n to use later, 
        # I don't know why, but name's value is changed later
        enum_name = name.to_s.dup

        # define an array contant with the given values
        # example: Car::STATUS =>  [:normal, :broken, :running]
        const_name = enum_name.upcase
        self.const_set const_name, values

        # define a singleton method which get the enum value
        # example: Car.status(:broken)   =>  1
        pstatic =  Proc.new { |value| self.const_get(const_name).index(value) }
        metaclass = class << self
          self
        end
        metaclass.send(:define_method, enum_name, pstatic)

        # define an instance get/set methods  which get/set  the enum value
        # example: 
        # c = Car.new :status => :normal  
        # c.status => :normal
        # c.status = :broken
        #
        define_method(enum_name.to_sym) do
          attr_value = read_attribute(enum_name)
          attr_value.nil? ? nil : self.class.const_get(const_name)[attr_value.to_i]
        end

        define_method "#{enum_name}=" do |value|
          if value.blank?
            casted_value = nil
          elsif (value.is_a?(String) && value =~ /\A\d+\Z/) || value.is_a?(Integer)
            casted_value = value.to_i
          else
            casted_value = self.class.const_get(const_name).index(value.to_sym)
          end
          
          write_attribute enum_name, casted_value
        end
      end
    end
  end
end
