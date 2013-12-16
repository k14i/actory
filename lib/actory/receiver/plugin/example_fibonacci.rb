module Actory
module Receiver

class Plugin

  def fibonacci(num=10)
    num = num.to_i unless num.class == Fixnum
    num <= 1 ? num : fibonacci(num - 1) + fibonacci(num - 2)
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end
end

end #Receiver
end #Actory
