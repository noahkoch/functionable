module Hollerith
  class Function
    def initialize definition: definition, user_context: nil, main_context: nil, user_defined_functions: nil
      @definition             = definition
      @user_context           = user_context
      @main_context           = user_context
      @user_defined_functions = user_defined_functions
    end

    def invoke! 
      return unless @definition 

      runner = Hollerith::FunctionRunner.new(
        @definition,
        @main_context,
        @user_context,
        @user_defined_functions
      )

      results = runner.evaluate

      if runner.user_context_change
        @user_context.deep_merge!(runner.user_context_change)
      end
      
      return results
    end
  end
end
