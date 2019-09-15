load 'function_runner.rb'

class Functionable

  HOOKS = %w(
    on_place_order
    on_update_order
  )

  def self.function_runner
    FunctionRunner
  end

  def initialize configuration, context
    @configuration = configuration 
    @context = context
    @user_defined_context = {}
  end

  def trigger_hook hook
    @configuration[hook].each do |each_hook_implementation|
      if hook_should_be_run(each_hook_implementation)
        execute_hook_implementation(each_hook_implementation)
      end
    end
  end

  def hook_should_be_run(hook_implementation)
    if hook_implementation.has_key?(:if) || hook_implementation.has_key?(:unless)
      # TODO
    else
      true
    end
  end

  def execute_hook_implementation definition
    case definition['function']
    when 'for_each'
      iterator = get_iterator(definition['loop'])
      before_iteration_functions = definition['for_each']['before_iteration']
      each_iteration_rules = definition['for_each']['each_iteration']
      break_when = definition['for_each']['break_iteration_if']

      before_iteration_functions.each do |each_function|
        evaluate_function(each_function)
      end

      iterator do
        each_iteration_rules.each do |each_function|
          evaluate_function(each_function)
        end
        
        break if evaluate_conditional(break_when)
      end
    end
  end

  def get_iterator iterator_definition
    # `$$_schools as each_school`
    collection_variable, each_value_variable = iterator_definition.split(' as ')

    get_variable_from_context(collection_variable).each do |each_iteration|
      @user_defined_context[each_value_variable] = each_iteration
      yield
    end
  end

  def get_variable_from_context variable
    if variable.starts_with?('$$_')
      value_to_return = @context[variable[3..-1].strip]   

      if value_to_return
        return value_to_return
      else
        raise ArgumentError.new("Variable not found #{value_to_return} in this context")
      end
    else
      raise ArgumentError.new("Invalid variable definition #{variable}")
    end
  end

  def evaluate_conditional conditional_statement
    results = evaluate_function(conditional_statement)

    return results[:output]
  end

  def evaluate_function function_definition
    results = self.class.function_runner.new(
      function_definition,
      @context,
      @user_defined_context
    )

    if results.user_context_change
      @user_defined_context.merge!(results.user_context_change)
    end
    
    return results
  end

end
