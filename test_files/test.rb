require 'toml'
require 'pry'
load 'functionable.rb'

config = TOML::Parser.new(File.read('/Users/noahkochanowicz/Stage/codeless_integrations/test_files/entry.toml')).parsed

Functionable.new(config, {'order_items' => [1,2,3,4, 5]}).trigger_hook('on_place_order')
