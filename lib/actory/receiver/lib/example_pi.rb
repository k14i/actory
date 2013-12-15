module Actory
module Receiver

class Lib

  def pi(len=2)
    len = len.to_i unless len.class == Fixnum
    b = 10 ** len
    b2 = b << 1
    pi = (len * 8 + 1).step(3, -2).inject(b) {|a, i| (i >> 1) * (a + b2) / i} - b
    return "3.#{pi}"
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end
end

end #Receiver
end #Actory
