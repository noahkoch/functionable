# Hollerith 
### Write executable code using JSON!

Hollerith allows you to write complex code without needing to mess up your code repo. All of your configuration can go directly in the database. Perfect for things like writing integrations with third parties.

### Install
`gem install hollerith`
or
`gem 'hollerith'` in your Gemfile

### Example (written in TOML)

```toml
[[on_place_order]]
  # If the conditions here aren't met, we won't run this hook
  run_if = "%%_eql(%%_count($$_order_items),5)"
  # We're gonna be iterating. Other options here:
  # - 'none': we'll just provide a list of functions to run.
  # - 'conditional': simple if/else.
  method = "for_each"
  loop = "$$_order_items as oi"
  [on_place_order.for_each]
    before_iteration = [
      # Set a local variable `all_success` to be true
      "%%_set(all_success,true)"
    ]
    # On each iteration, these functions will be executed in order 
    each_iteration = [
      "%%_set(successful_order_items,%%_blank_array())",
      "%%_set(result,%%_make_external_request($$_oi))",
      # Notice the custom function here, we set that up in the bottom of the function.
      "%%_if($$_result,%%_custom_function(handle_success,$$_result,$$_oi),%%_set(all_success,false))"
    ]
    next_if = "%%_or(%%_eql($$_oi,2),%%_eql($$_oi,3))" 
    break_iteration_if = "%%_negate(%%_if($$_all_success))"
  [on_place_order.finally]
    # Once we're done iterating, we'll call these functions in order
    functions = [
      "%%_puts($$_order_body.password)",
      "%%_for_each($$_successful_order_items,%%_custom_function(cancel_order_item),each_order_item)"
    ]
    

[custom_functions]
  [custom_functions.handle_success]
    arguments = [
      "result_from_success",
      "order_item"
    ]
    functions = [
      "%%_array_push($$_successful_order_items,%%_concat('this ',$$_order_item))",
      "%%_puts(%%_concat('this was our response: ',$$_result_from_success))"
    ]
  [custom_functions.cancel_order_item]
    arguments = [ ]
    functions = [
      "%%_puts($$_each_order_item)"
    ]

[configuration]
[configuration.order_body]
password = "123abc"
```

### Usage
You can write in whatever markup language you want as long as it compiles to JSON.

```ruby
Hollerith.new(
  json_integration,
  {
    'order' => Order.last,
    'api_key' => ENV['api_key']
  }
).trigger_hook('place_order')
```

See the `test_files/test.rb` for a full example.

Once this has been made into a gem it will be more straightforward to add cutom functions.

### To-Do
* Add a lot more documentation
* Implement more standard ruby methods

### About the name
Hollerith punched cards were one of the many names given to the punchcards that we used in very early computers. Named after Herman Hollerith, the founder of The Tabulating Machine Company. That company would eventually turn into IBM through an acquisition.

You can think of Hollerith as an punched card for your Ruby application.
