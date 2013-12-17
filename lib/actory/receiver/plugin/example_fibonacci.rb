module Actory
module Receiver

class Plugin

  def fibonacci(num=10)
    raise StandardError unless [Fixnum, String].include?(num.class)
    num = num.to_i if num.class == String and num =~ /\A[0-9]+\z/
    num <= 1 ? num : fibonacci(num - 1) + fibonacci(num - 2)
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end
end

end #Receiver
end #Actory
