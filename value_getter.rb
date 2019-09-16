class ValueGetter

  attr_reader :user_context_change

  def initialize user_context, main_context, user_defined_functions, user_context_change, local_context = {} 
    # local_context is only used for the getting of this value
    # and does not get bubbled up to other function calls,
    # helpful for each loops in functions.
    @main_context = main_context  
    @user_context = user_context.merge(local_context)
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
      read_hash_value(hash_key)
    elsif value_to_get.start_with?('%%_')
      runner = FunctionRunner.new(
        value_to_get,
        @main_context,
        @user_context.merge(@user_context_change || {}),
        @user_defined_functions
      )

      result = runner.evaluate

      @user_context_change.deep_merge!(runner.user_context_change || {}) 

      get(result)
    elsif value_to_get.is_a?(String) && (value_to_get.start_with?("'") || value_to_get.start_with?('"')) && (value_to_get.end_with?("'") || value_to_get.end_with?('"'))
      value_to_get[1..-2]
    else
      value_to_get
    end
  end

  def read_hash_value hash_key
    split_hash_key = hash_key.split('.')
    base_hash_key = split_hash_key.shift

    if @user_context.has_key?(base_hash_key)
      hash_key_value = @user_context[base_hash_key]
    else
      hash_key_value = @main_context[base_hash_key]
    end

    split_hash_key.each do |each_hash_key|
      if hash_key_value.is_a?(Hash) 
        hash_key_value = hash_key_value[each_hash_key]
      else
        if hash_key_value.respond_to?(:attributes) && hash_key_value.attributes.include?(each_hash_key)
          hash_key_value = hash_key_value.send(each_hash_key)
        elsif hash_key_value.respond_to?(:instance_variables) && hash_key_value.instance_variables.map(&:to_s).include?("@#{each_hash_key}")
          hash_key_value = hash_key_value.send(each_hash_key)
        else
          hash_key_value = nil
        end
      end
    end

    # TODO: Add dot notation handling here.
    #       - Read all rails attributes, hash values or instance variables.
    # FIXME: Variable getting needs to be DRYed up.

    return hash_key_value
  end
end
