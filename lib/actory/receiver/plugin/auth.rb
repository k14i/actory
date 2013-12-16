module Actory
module Receiver

class Plugin

  def auth?(shared_key)
    RECEIVER['shared_key'] == shared_key
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end
end

end #Receiver
end #Actory
