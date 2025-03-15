require 'benchmark'

class TestObject
  attr_accessor :data

  def initialize(size)
    @data = Array.new(size) { |i| { key: i, value: "val#{i}" } }
  end
end

obj = TestObject.new(10_000) # Large nested structure

Benchmark.bm do |x|
  x.report('Shallow dup:') { obj.dup }
  x.report('Deep Marshal dup:') { Marshal.load(Marshal.dump(obj)) }
end
