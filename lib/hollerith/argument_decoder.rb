class Hollerith::ArgumentDecoder
  # "result,%%_make_external_request($$_oi,true)"
  # becomes
  # ['result', '%%_make_external_request($$_oi,true)']
  #
  # harder than it looks :)
  def self.decode_argument declaration
    arguments = declaration.match(/\((?>[^)(]+|\g<0>)*\)/)[0][1..-2]

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
