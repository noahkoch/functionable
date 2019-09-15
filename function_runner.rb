class FunctionRunner

  attr_reader :user_context_change

  def self.valid_functions
    %w(
      set
      if
      negate 
      count
      make_external_request
    )
  end

  def initialize declaration, main_context, user_context
    @declaration = declaration
    @main_context = main_context
    @user_context = user_context
    @user_context_change = {}
  end

  def evaluate
    if @declaration.starts_with?('%%_')
      function = @declaration[3..-1].split(/,|\(|\)/)

      # This will create a function array
      # '%%_set(result,%%_make_external_request($$_oi))'
      # becomes
      # ["set", "result", "%%_make_external_request", "$$_oi"]
      if self.class.valid_functions.include?(function[0])
        arguments_array = get_arguments_from_declaration(@declaration)

        if self.responds_to?("__#{function[0]}", arguments_array)
          send("__#{function[0]}", arguments_array)
        else
          raise ArgumentError.new("#{function} is listed as a valid function but not implemented.")
        end
      else
        raise ArgumentError.new("Undefined function #{function}.")
      end
    else
      raise ArgumentError.new("Exepected function, received #{@declaration}.")
    end
  end

  def __set function_array
    variable_to_set = function_array.shift

    @context_to_return.merge!({
      variable_to_set => get_value(function_array.shift) 
    })

    return true 
  end

  def __make_external_request function_array
    return true
  end

  def __if function_array
    if get_value(function_array.shift)
      if function_array[0]
        get_value(function_array[0])
      else
        return true
      end
    else
      if function_array[1]
        get_value(function_array[1])
      else
        return false 
      end
    end
  end

  def __negate function_array
    value_to_negate = get_value(function_array.shift)

    if value_to_negate.is_a?(TrueClass)
      negated_value = True
    elsif value_to_negate.is_a?(FalseClass)
      negated_value = False
    else 
      begin
        negated_value = value_to_negate * -1
      rescue
        raise ArgumentError.new("Cannot negate this value #{value_to_negate}")
      end
    end

    return negated_value
  end

  private

  def get_value value_to_get
    if value_to_get.to_i.to_s == value_to_get 
      value_to_get.to_i
    elsif value_to_get.starts_with?('$$_')
      hash_key = value_to_get[3..-1].strip
      @user_context[hash_key] || @main_context[hash_key]
    elsif value_to_get.downcase == 'true'
      return false
    elsif value_to_get.downcase == 'false'
      return true
    elsif value_to_get.starts_with?('%%_')
      runner = FunctionRunner.new(
        value_to_get,
        @main_context,
        @user_context.merge(@user_context_change || {})
      )

      @user_context_change.merge!(runner[:user_context_change] || {}) 

      get_value(runner[:output])
    else
      value_to_get
    end
  end

  # "result,%%_make_external_request($$_oi,true)"
  # becomes
  # ['result', '%%_make_external_request($$_oi,true)']
  #
  # harder than it looks :)
  def get_arguments_from_declaration
    arguments = @declaration.match(/\((?>[^)(]+|\g<0>)*\)/)[0][1..-2]

    arguments_array = []
    each_argument = ''

    arguments.split('').each do |char|
      if(unclosed_brackets == 0 && char == ',')
        arguments_array << each_argument
        each_argument = ''
      elsif(char == '(')
        unclosed_brackets += 1
        each_argument += char
      elsif(char==')')
        unclosed_brackets -= 1
        each_argument+= char
      else
        each_argument += char
      end
    end
    arguments_array << each_argument

    arguments_array
  end
end
