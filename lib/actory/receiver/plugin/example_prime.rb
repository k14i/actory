module Actory
module Receiver

class Plugin < Base
  require 'prime'

  def prime(num=1)
    raise StandardError unless [Fixnum, String].include?(num.class)
    num = num.to_i if num.class == String and num =~ /\A[0-9]+\z/
    Prime.each(num).to_a
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end
end

end #Receiver
end #Actory
