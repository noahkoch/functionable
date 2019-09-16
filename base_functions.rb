module BaseFunctions  

  def valid_functions
    %w(
      set
      if
      negate 
      count
      make_external_request
      custom_function
      puts
      concat
      blank_array
      array_push
    )
  end

  def __set function_array
    variable_to_set = function_array.shift

    @user_context_change.merge!({
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
      negated_value = false 
    elsif value_to_negate.is_a?(FalseClass)
      negated_value = true
    else 
      begin
        negated_value = value_to_negate * -1
      rescue
        raise ArgumentError.new("Cannot negate this value #{value_to_negate}")
      end
    end

    return negated_value
  end

  def __custom_function function_array
    function_name = function_array.shift
    
    arguments = @user_defined_functions[function_name]['arguments']
    functions = @user_defined_functions[function_name]['functions']

    arguments.each do |argument|
      @user_context[argument] = get_value(function_array.shift)
    end

    functions.each do |function|
      get_value(function)
    end
  end

  def __puts function_array
    puts(get_value(function_array.shift))
  end

  def __concat function_array
    function_array.map do |each_element|
      get_value(each_element)
    end.join('')
  end

  def __blank_array function_array
    return []
  end

  def __array_push function_array
    # $$_successful_order_items -> successful_order_items
    context_variable_name = function_array.shift[3..-1]
    @user_context[context_variable_name] << get_value(function_array.shift)
  end
end
