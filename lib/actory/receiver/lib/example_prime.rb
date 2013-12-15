module Actory
module Receiver

class Lib
  require 'prime'

  def prime(num=1)
    num = num.to_i unless num.class == Fixnum
    Prime.each(num).to_a
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end
end

end #Receiver
end #Actory
