module Actory
module Receiver

class Plugin < Base

  def reload
    Dir[File.join(File.dirname(__FILE__), "./*.rb")].each { |f| load f }
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, e
  end

end

end #Receiver
end #Actory
