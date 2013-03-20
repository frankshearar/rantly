require 'rantly'
require 'test/unit'
require 'pp'

class Rantly::Property

  def initialize(property)
    @property = property
    @shrink = Rantly::Shrink.null_shrink
  end
  
  def check(n=100,limit=10,&assertion)
    i = 0
    test_data = nil
    begin
      Rantly.singleton.generate(n,limit,@property) do |val|
        test_data = val
        begin
          assertion.call(val) if assertion
        rescue => boom
          # Try minimise the counterexample
          val = @shrink.shrink(val, assertion)
        end
        puts "" if i % 100 == 0
        print "." if i % 10 == 0
        i += 1
      end
      puts
      puts "success: #{i} tests"
    rescue Rantly::TooManyTries => e
      puts
      puts "too many tries: #{e.tries}"
      raise e
    rescue => boom
      puts
      puts "failure: #{i} tests, on:"
      pp test_data
      raise boom
    end
  end

  def report
    distribs = self.classifiers.sort { |a,b| b[1] <=> a[1] }
    total = distribs.inject(0) { |sum,pair| sum + pair[1]}
    distribs.each do |(classifier,count)|
      format "%10.5f%% of => %s", count, classifier
    end
  end

  def shrink(&block)
    @shrink = Rantly::Shrink.new(block)
  end
end

class Rantly::Shrink
  # A Shrink takes a counterexample - a value that fails an assertion -
  # and attempts to make the counterexample simpler. To that end, its
  # :call method returns a list of possibly simpler values. The
  # Shrink attempts to iteratively simplify the counterexample.
  def self.null_shrink
    new(->x{x})
  end

  def initialize(&block)
    @shrinker = block
  end

  def shrink(seed, assertion=nil)
    candidates = @shrinker.call(seed)
  end
end

module Test::Unit::Assertions
  def property_of(&block)
    Rantly::Property.new(block)
  end
end

begin
  require 'rspec'
  class RSpec::Core::ExampleGroup
    def property_of(&block)
      Rantly::Property.new(block)
    end
  end
rescue LoadError
  "No RSpec loaded. Oh, well."
end
