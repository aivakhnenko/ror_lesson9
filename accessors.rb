module Accessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attr_accessor_with_history(*names)
      attr_history_name = :@attr_history
      names.each do |name|
        attr_name = "@#{name}".to_sym
        define_method(name) { instance_variable_get(attr_name) }
        define_method("#{name}=".to_sym) do |value|
          instance_variable_set(attr_name, value)
          instance_variable_set(attr_history_name, {}) unless instance_variable_get(attr_history_name)
          attr_history = instance_variable_get(attr_history_name)
          attr_history[attr_name] ||= []
          attr_history[attr_name] << value
          instance_variable_set(attr_history_name, attr_history)
        end
        define_method("#{name}_history".to_sym) do
          instance_variable_set(attr_history_name, {}) unless instance_variable_get(attr_history_name)
          attr_history = instance_variable_get(attr_history_name)
          attr_history[attr_name] ? instance_variable_get(attr_history_name)[attr_name] : nil
        end
      end
    end

    def strong_attr_accessor(name, type)
      attr_name = "@#{name}".to_sym
      define_method(name) { instance_variable_get(attr_name) }
      define_method("#{name}=".to_sym) do |value|
        raise 'Wrong type' if value.class != type
        instance_variable_set(attr_name, value)
      end
    end
  end
end
