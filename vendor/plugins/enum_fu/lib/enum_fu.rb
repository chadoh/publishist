# encoding: utf-8
module EnumFu
  autoload :Base, 'enum_fu/base'
end

require 'enum_fu/railtie' if defined?(Rails)
