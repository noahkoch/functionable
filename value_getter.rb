class ValueGetter

  attr_reader :user_context_change

  def initialize user_context, main_context, user_defined_functions, user_context_change
    @main_context = main_context  
    @user_context = user_context  
    @user_defined_functions = user_defined_functions  
    @user_context_change = user_context_change  
  end

  def get value_to_get
    if !value_to_get.is_a? String
      return value_to_get
    elsif value_to_get.downcase == 'true'
      return true
    elsif value_to_get.downcase == 'false'
      return false
    elsif value_to_get.to_i.to_s == value_to_get 
      value_to_get.to_i
    elsif value_to_get.start_with?('$$_')
      hash_key = value_to_get[3..-1].strip
      if @user_context.has_key?(hash_key)
        @user_context[hash_key]
      else
        @main_context[hash_key]
      end
    elsif value_to_get.start_with?('%%_')
      runner = FunctionRunner.new(
        value_to_get,
        @main_context,
        @user_context.merge(@user_context_change || {}),
        @user_defined_functions
      )

      result = runner.evaluate

      @user_context_change.merge!(runner.user_context_change || {}) 

      get(result)
    elsif value_to_get.is_a?(String) && (value_to_get.start_with?("'") || value_to_get.start_with?('"')) && (value_to_get.end_with?("'") || value_to_get.end_with?('"'))
      value_to_get[1..-2]
    else
      value_to_get
    end
  end
end
