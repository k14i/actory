module Benchmark
  module_function

  def measure(&block)
    t0 = Time.now
    ret = block.call
    span = Time.now - t0
    return ret, span
  end

end
