########### 
# the line starting with 'class_eval <<-EOV' had a before_destroy call in it that reloaded the model
# when this happens, all nested dependent: :destroy actions are not called
# so took this call out.

module ActiveRecord
  module Acts 
    module List 
       module ClassMethods
        # Configuration options are:
        #
        # * +column+ - specifies the column name to use for keeping the position integer (default: +position+)
        # * +scope+ - restricts what is to be considered a list. Given a symbol, it'll attach <tt>_id</tt>
        #   (if it hasn't already been added) and use that as the foreign key restriction. It's also possible
        #   to give it an entire string that is interpolated if you need a tighter scope than just a foreign key.
        #   Example: <tt>acts_as_list scope: 'todo_list_id = #{todo_list_id} AND completed = 0'</tt>
        # * +top_of_list+ - defines the integer used for the top of the list. Defaults to 1. Use 0 to make the collection
        #   act more like an array in its indexing.
        # * +add_new_at+ - specifies whether objects get added to the :top or :bottom of the list. (default: +bottom+)
        #                   `nil` will result in new items not being added to the list on create
        def acts_as_list(options = {})
          configuration = { column: "position", scope: "1 = 1", top_of_list: 1, add_new_at: :bottom}
          configuration.update(options) if options.is_a?(Hash)

          configuration[:scope] = "#{configuration[:scope]}_id".intern if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/

          if configuration[:scope].is_a?(Symbol)
            scope_methods = %(
              def scope_condition
                { :#{configuration[:scope].to_s} => send(:#{configuration[:scope].to_s}) }
              end
              def scope_changed?
                changes.include?(scope_name.to_s)
              end
            )
          elsif configuration[:scope].is_a?(Array)
            scope_methods = %(
              def attrs
                %w(#{configuration[:scope].join(" ")}).inject({}) do |memo,column|
                  memo[column.intern] = read_attribute(column.intern); memo
                end
              end
              def scope_changed?
                (attrs.keys & changes.keys.map(&:to_sym)).any?
              end
              def scope_condition
                attrs
              end
            )
          else
            scope_methods = %(
              def scope_condition
                "#{configuration[:scope]}"
              end
              def scope_changed?() false end
            )
          end

          class_eval <<-EOV
            include ::ActiveRecord::Acts::List::InstanceMethods
            def acts_as_list_top
              #{configuration[:top_of_list]}.to_i
            end
            def acts_as_list_class
              ::#{self.name}
            end
            def position_column
              '#{configuration[:column]}'
            end
            def scope_name
              '#{configuration[:scope]}'
            end
            def add_new_at
              '#{configuration[:add_new_at]}'
            end
            def #{configuration[:column]}=(position)
              write_attribute(:#{configuration[:column]}, position)
              @position_changed = true
            end
            #{scope_methods}
            # only add to attr_accessible
            # if the class has some mass_assignment_protection
            if defined?(accessible_attributes) and !accessible_attributes.blank?
              attr_accessible :#{configuration[:column]}
            end
            
            after_destroy :decrement_positions_on_lower_items
            before_update :check_scope
            after_update :update_positions
            before_validation :check_top_position
            scope :in_list, lambda { where("#{table_name}.#{configuration[:column]} IS NOT NULL") }
          EOV

          if configuration[:add_new_at].present?
            self.send(:before_create, "add_to_list_#{configuration[:add_new_at]}")
          end

        end
      end        
    end        
  end        
end