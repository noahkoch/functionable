class Hollerith 

  HOOKS = %w(
    on_place_order
    on_update_order
  )

  def initialize configuration, main_context = {}
    @configuration = configuration 
    @main_context = main_context
    @user_context = @configuration['configuration'] || {}
    @user_defined_functions = @configuration['custom_functions'] 
  end

  def trigger_hook hook
    @configuration[hook].each do |each_hook_implementation|
      Hollerith::Hook.new(each_hook_implementation).trigger
    end
  end

  def evaluate_functions functions
    functions.each do |definition|
      evaluate_functions(definition)
    end
  end

  def evaluate_conditional conditional_statement
    return false unless conditional_statement

    evaluate_function(conditional_statement)
  end

  def evaluate_function function_definition
    Hollerith::Function.new(
      definition: function_definition,
      main_context: @main_context,
      user_context: @user_context,
      user_defined_functions: @user_defined_functions
    ).invoke!
  end

end

require 'hollerith/function_runner'
require 'hollerith/utilities/value_getter'
require 'hollerith/utilities/argument_decoder'
require 'hollerith/system_functions'
require 'hollerith/hook'
