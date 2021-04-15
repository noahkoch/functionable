module Hollerith
  class Hook
    def initialize implementation
      @implementation = implementation
    end

    def trigger
      return false unless hook_should_be_run?

      execute_hook_implementation(each_hook_implementation)
    end

    private

    def hook_should_be_run(hook_implementation)
      if hook_implementation.has_key?('run_if')
        evaluate_conditional(hook_implementation['run_if'])      
      elsif hook_implementation.has_key?('run_unless')
        !evaluate_conditional(hook_implementation['run_unless'])      
      else
        true
      end
    end

    def execute_hook_implementation definition
      if definition['before'] && definition['before']['functions']
        evaluate_functions(definition['before']['functions'])
      end

      case definition['method']
      when 'none'
        evaluate_functions(definition['functions'])
      when 'conditional'
        # TODO
        raise "Not implemented!" 
      when 'for_each'
        before_iteration_functions = definition['for_each']['before_iteration']
        each_iteration_rules = definition['for_each']['each_iteration']
        break_when = definition['for_each']['break_iteration_if']
        next_when = definition['for_each']['next_if']

        evaluate_functions(before_iteration_functions)

        get_iterator(definition['loop']) do
          next if evaluate_conditional(next_when)

          evaluate_functions(each_iteration_rules)        
          break if evaluate_conditional(break_when)
        end
      end

      if definition['finally'] && definition['finally']['functions']
        evaluate_functions(definition['finally']['functions'])
      end
    end

    def get_iterator iterator_definition
      # `$$_schools as each_school`
      collection_variable, each_value_variable = iterator_definition.split(' as ')

      get_variable_from_context(collection_variable).each do |each_iteration|
        @user_context[each_value_variable] = each_iteration
        yield
      end
    end

    def get_variable_from_context variable
      if variable.start_with?('$$_')
        value_to_return = @main_context[variable[3..-1].strip]   

        if value_to_return
          return value_to_return
        else
          raise ArgumentError.new(
            "Variable not found #{value_to_return} in this context"
          )
        end
      else
        raise ArgumentError.new("Invalid variable definition #{variable}")
      end
    end
  end
end
