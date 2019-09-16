load 'base_functions.rb'

class FunctionRunner

  attr_reader :user_context_change
  
  include BaseFunctions

  def initialize declaration, main_context, user_context, user_defined_functions
    @declaration = declaration
    @main_context = main_context
    @user_context = user_context
    @user_context_change = {}
    @user_defined_functions = user_defined_functions
  end

  def evaluate
    if @declaration.start_with?('%%_')
      function = @declaration[3..-1].split(/,|\(|\)/)

      # This will create a function array
      # '%%_set(result,%%_make_external_request($$_oi))'
      # becomes
      # ["set", "result", "%%_make_external_request", "$$_oi"]
      if valid_functions.include?(function[0])
        arguments_array = get_arguments_from_declaration

        if self.respond_to?("__#{function[0]}", arguments_array)
          send("__#{function[0]}", arguments_array)
        else
          raise ArgumentError.new("#{function[0]} is listed as a valid function but not implemented.")
        end
      else
        raise ArgumentError.new("Undefined function #{function[0]}.")
      end
    else
      raise ArgumentError.new("Exepected function, received #{@declaration}.")
    end
  end

  private

  def get_value value_to_get
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

      get_value(result)
    elsif value_to_get.is_a?(String) && (value_to_get.start_with?("'") || value_to_get.start_with?('"')) && (value_to_get.end_with?("'") || value_to_get.end_with?('"'))
      value_to_get[1..-2]
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
    unclosed_parens = 0
    unclosed_square_brackets = 0
    unclosed_single_quotes = 0
    unclosed_double_quotes = 0

    arguments.split('').each do |char|
      everything_is_closed = (
        unclosed_parens == 0 &&
        unclosed_square_brackets == 0 &&
        unclosed_single_quotes == 0 &&
        unclosed_double_quotes == 0
      )

      if everything_is_closed && char == ','
        arguments_array << each_argument
        each_argument = ''
      elsif char == '('
        unclosed_parens += 1
        each_argument += char
      elsif char == ')'
        unclosed_parens -= 1
        each_argument+= char
      elsif char == "["
        unclosed_square_brackets += 1
        each_argument += char
      elsif char == ']'
        unclosed_square_brackets -= 1
        each_argument+= char
      elsif char == "'" && unclosed_single_quotes == 0
        unclosed_single_quotes += 1
        each_argument += char
      elsif char == "'"
        unclosed_single_quotes -= 1
        each_argument+= char
      elsif char == '"' && unclosed_double_quotes == 0
        unclosed_double_quotes += 1
        each_argument += char
      elsif char == '"'
        unclosed_double_quotes -= 1
        each_argument+= char
      else
        each_argument += char
      end
    end
    arguments_array << each_argument

    arguments_array
  end
end
