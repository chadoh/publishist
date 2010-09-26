module AutoCompleteJquery      
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  #
  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     auto_complete_for :post, :title
  #   end
  #
  #   # View
  #   <%= text_field_with_auto_complete :post, title %>
  #
  # By default, auto_complete_for limits the results to 10 entries,
  # and sorts by the given field.
  # 
  # auto_complete_for takes a third parameter, an options hash to
  # the find method used to search for the records:
  #
  #   auto_complete_for :post, :title, :limit => 15, :order => 'created_at DESC'
  #
  # auto_complete_for allows you to pass multiple attributes if you want to return a full name for example
  # NOTE: this will not work with jquery.autocomplete using the option mustMatch
  #   auto_complete_for :user, [:first_name, :last_name]
  #     AND you can also pass a delimiter if you want, it defaults to a " " (space)
  #   auto_complete_for :user, [:first_name, :last_name], :delimiter => ","
  # 
  # For help on defining text input fields with autocompletion, 
  # see ActionView::Helpers::JavaScriptHelper.
  #
  # For more on jQuery auto-complete, see the docs for the jQuery autocomplete 
  # plugin used in conjunction with this plugin:
  # * http://www.dyve.net/jquery/?autocomplete
  #
  # Option hash:
  #
  # :collection_instance_variable
  #
  # pass in the name of an instance variable w/o the '@' to bypass
  # SQL and provide autocomplete from a collection.  Currently, this
  # only works for single methods not an array of methods.  
  #
  # example, pull data from @tags, no SQL used:
  # auto_complete_for :tag, :name, :collection_instance_variable => :tags
  
  module ClassMethods

    def auto_complete_for(object, method=[], options = {})
      if options.has_key?(:collection_instance_variable) && method.is_a?(Array)
        raise(ArgumentError, "method array cannot be combined with :collection_instance_variable option")
      end

      # define_method should not require array, allow non array input
      method = [method] unless method.is_a?(Array)
      method_name = options.delete(:method_name) || "auto_complete_for_#{object}_#{method.join("_")}"

      define_method(method_name) do
        object_constant = object.to_s.camelize.constantize
        ac_options = options.dup
        ac_options[:delimiter] ||= " "
        ac_options[:order] ||= "#{method.first} ASC"
        
        delimiter = ac_options[:delimiter]
        ac_options.delete :delimiter
        limit = ac_options[:limit] || 10 

        collection_instance_variable = ac_options.delete(:collection_instance_variable)

        if collection_instance_variable
          collection = instance_variable_get('@' + collection_instance_variable.to_s)
          if collection
            filter = params[:q].to_s.downcase
            filter_by = ac_options.delete(:collection_filter_by) || method.first.to_s
            items = collection.find_all { |item| 
              filter_for = item.send(filter_by).to_s.downcase
              filter_for.to_s =~ /#{filter}/
            }
            if items
              items.sort! { |a, b| a.send(filter_by) <=> b.send(filter_by) }
              # truncate at limit exclusive of the "limit" endpoint
              items = items[0...limit]
            end
          end
        else
          # assemble the conditions
          conditions = ""
          selects = "#{object_constant.table_name}.id,"
          method = [method] unless method.is_a?(Array)
          method.each do |arg|
            conditions << "LOWER(#{arg}) LIKE ?"
            conditions << " OR " unless arg == method.last

            selects << "#{object_constant.table_name}.#{arg}"
            selects << "," unless arg == method.last
          end
          conditions = Array(conditions)
          filters = Array("%#{params[:q].to_s.downcase}%")*method.length
          filters.each { |filter| conditions.push filter }
          
          # These options can be overridden by the subsequent merge ac_options below
          find_options = { 
            :conditions => conditions, 
            :select => selects,
            :limit => limit }.merge!(ac_options)
          
          items = object_constant.find(:all, find_options)
        end

        content = ""
        if block_given?
          content = yield(items)
        elsif items
          content = items.map{ |item| 
            values = []
            method.each do |m|
              values << item.send(m)
            end
            "#{values.join(delimiter)}|#{item.send(object_constant.primary_key)}"
          }.join("\n")
        end

        render :text => content 

      end
    end
  end
  
end
