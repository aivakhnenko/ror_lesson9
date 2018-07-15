module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def validate(name, validation, *args)
      validations_name = :@validations
      instance_variable_set(validations_name, []) unless instance_variable_get(validations_name)
      validations = instance_variable_get(validations_name)
      case validation
      when :presence then validations << { name: name, validation: validation }
      when :type     then validations << { name: name, validation: validation, type:   args[0] }
      when :format   then validations << { name: name, validation: validation, format: args[0] }
      end
      instance_variable_set(validations_name, validations)
    end
  end

  module InstanceMethods
    def valid?
      validate!
    rescue RuntimeError
      false
    end

    def validate!
      validations = self.class.instance_variable_get(:@validations)
      if validations
        validations.each do |validation|
          name = validation[:name]
          full_name = "#{self.class} #{name}"
          value = instance_variable_get("@#{name}".to_sym)
          case validation[:validation]
          when :presence then raise "#{full_name} has to exist"     if !value || value == ''
          when :type     then raise "#{full_name} has wrong type"   if value.class != validation[:type]
          when :format   then raise "#{full_name} has wrong format" if value !~ validation[:format]
          end
        end
      end
      true
    end
  end
end
