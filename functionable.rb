class Functionable

  HOOKS = [
    :on_place_order,
    :on_update_order
  ].freeze

  def initialize configuration, context
    @configuration = configuration 
    @context = context.deep_stringify_keys
  end

  def trigger_hook hook, context
    @configuration[hook].each do |each_hook_implementation|
      if hook_should_be_run(each_hook_implementation)
        execute_hook_implementation(each_hook_implementation)
      end
    end
  end

  def hook_should_be_run(hook_implementation)
    if hook_implementation.has_key?(:if) || hook_implementation.has_key?(:unless)
    else
      true
    end
  end

  def is_registered_function
  end

  def execute_hook_implementation definition
    case definition['function']
    when 'for_each'
      iterator = get_iterator(definition['loop'])
    end
  end

  def get_iterator iterator_definition
    # `$$_schools as each_school`
    collection_variable, each_value_variable = iterator_definition.split(' as ')

    get_variable_from_context(collection_variable)
  end

  def get_variable_from_context variable
    if variable.starts_with?('$$_')
    else
      raise ArgumentError.new("Invalid variable #{variable}")
    end
  end

  def evaluate_conditional conditional_statement
    # break_iteration_if = "$$_all_success is not true"
  end

end
