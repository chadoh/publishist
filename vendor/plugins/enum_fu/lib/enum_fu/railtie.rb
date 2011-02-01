# encoding: utf-8
require 'enum_fu'

module EnumFu
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      config.before_initialize do
        ActiveSupport.on_load :active_record do
          ActiveRecord::Base.send :include, EnumFu::Base
        end
      end
    end
  end
end
