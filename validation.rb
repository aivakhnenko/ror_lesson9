module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    VALIDATIONS_NAME = :@validations

    def validate(attr_name, validation_type, *args)
      validations = instance_variable_get(VALIDATIONS_NAME)
      validations ||= {}
      validations[attr_name] ||= {}
      validations[attr_name][validation_type] = args
      instance_variable_set(VALIDATIONS_NAME, validations)
    end
  end

  module InstanceMethods
    def valid?
      validate!
    rescue RuntimeError
      false
    end

    def validate!
      validations = self.class.instance_variable_get(ClassMethods::VALIDATIONS_NAME)
      validations ||= {}
      validations.each do |attr_name, attr_validations|
        full_attr_name = "#{self.class} #{attr_name}"
        attr_validations.each do |validation_type, args|
          attr_value = instance_variable_get("@#{attr_name}".to_sym)
          send("validate_#{validation_type}".to_sym, full_attr_name, attr_value, args)
        end
      end
      true
    end

    private

    def validate_presence(full_attr_name, attr_value, _args)
      raise "#{full_attr_name} has to exist" if !attr_value || attr_value == ''
    end

    def validate_type(full_attr_name, attr_value, args)
      raise "#{full_attr_name} has wrong type" if attr_value.class != args[0]
    end

    def validate_format(full_attr_name, attr_value, args)
      raise "#{full_attr_name} has wrong format" if attr_value !~ args[0]
    end
  end
end
