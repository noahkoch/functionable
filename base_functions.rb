module BaseFunctions  

  def valid_functions
    %w(
      set
      if
      or
      and
      negate 
      count
      make_external_request
      custom_function
      puts
      concat
      blank_array
      array_push
      array_value
      eql
      add
      subtract
      multiply
      divide 
      split
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

  def __or function_array
    function_array.each do |each_condition|
      if get_value(each_condition)
        return true
      end
    end

    return false 
  end

  def __and function_array
    all_true = false
    function_array.each do |each_condition|
      if !get_value(each_condition)
        return false 
      else 
        all_true = true
      end
    end

    return all_true 
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

  def __array_value function_array
    context_variable_name = get_variable(function_array.shift)
    if @user_context[context_variable_name].is_a? Array
      @user_context[context_variable_name][get_value(function_array.shift)]
    elsif @main_context[context_variable_name].is_a? Array
      @main_context[context_variable_name][get_value(function_array.shift)]
    else
      raise ArgumentError.new("#{context_variable_name} is not an array.")
    end
  end

  def __array_push function_array
    context_variable_name = get_variable(function_array.shift)

    if @user_context[context_variable_name].is_a? Array
      @user_context[context_variable_name] << get_value(function_array.shift)
    elsif @main_context[context_variable_name].is_a? Array
      @main_context[context_variable_name] << get_value(function_array.shift)
    else
      raise ArgumentError.new("#{context_variable_name} is not an array.")
    end
  end

  def __eql function_array
    compare_value = get_value(function_array.shift)

    function_array.each do |each_value_to_compare|
      if get_value(each_value_to_compare) != compare_value 
        return false
      end
    end

    return true
  end

  def __add function_array
    get_value(function_array.shift) + get_value(function_array.shift)
  end

  def __subtract function_array
    get_value(function_array.shift) - get_value(function_array.shift)
  end

  def __multiply function_array
    get_value(function_array.shift) * get_value(function_array.shift)
  end

  def __divide function_array
    get_value(function_array.shift) / get_value(function_array.shift)
  end

  def __split function_array
    get_value(function_array.shift).split(function_array.shift)
  end

  def __count function_array
    get_value(function_array.shift).count
  end

  private

  def get_array_from_variable
  end

  def get_variable variable
    # $$_successful_order_items -> successful_order_items
    if variable.start_with?('$$_')
      return variable[3..-1]
    else
      raise ArgumentError.new('Must assign to an existing variable')
    end
  end
end
