if RUBY_VERSION =~ /1.8/ then
  require 'rcov'
else
  require 'simplecov'
  SimpleCov.start 'test_frameworks'
end

require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rantly'

class Test::Unit::TestCase
end
