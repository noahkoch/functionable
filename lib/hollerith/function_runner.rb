require 'hollerith/value_getter'
require 'hollerith/argument_decoder'
require 'hollerith/base_functions'

module Hollerith
  class FunctionRunner < Hollerith::BaseFunctions
    attr_reader :user_context_change
    
    def initialize declaration, main_context, user_context, user_defined_functions
      @declaration = declaration
      @main_context = main_context
      @user_context = user_context
      @user_context_change = {}
      @user_defined_functions = user_defined_functions
    end

    def evaluate
      if @declaration.start_with?('%%_')
        function = @declaration[3..-1].split(/,|\(|\)/)

        # This will create a function array
        # '%%_set(result,%%_make_external_request($$_oi))'
        # becomes
        # ["set", "result", "%%_make_external_request", "$$_oi"]
        if valid_functions.include?(function[0])
          arguments_array = get_arguments_from_declaration

          if self.respond_to?("__#{function[0]}", arguments_array)
            send("__#{function[0]}", arguments_array)
          else
            raise ArgumentError.new("#{function[0]} is listed as a valid function but not implemented.")
          end
        else
          raise ArgumentError.new("Undefined function #{function[0]}.")
        end
      else
        raise ArgumentError.new("Exepected function, received #{@declaration}.")
      end
    end

    private

    def get_value value_to_get, local_context = {}
      getter = ValueGetter.new(
        @main_context,
        @user_context,
        @user_defined_functions,
        @user_context_change,
        local_context
      )

      return_value = getter.get(value_to_get)

      @user_context_change.merge!(getter.user_context_change || {}) 

      return_value
    end

    def get_arguments_from_declaration
      ArgumentDecoder.decode_argument(@declaration)
    end

  end
end
