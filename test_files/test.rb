require 'toml'
require 'pry'
require 'deep_merge'
load 'hollerith.rb'

config = TOML::Parser.new(File.read('/Users/noahkochanowicz/Stage/codeless_integrations/test_files/entry.toml')).parsed

Hollerith.new(config, {'order_items' => [1,2,3,4,5], 'this' => {'is' => 'a test'}}).trigger_hook('on_place_order')
