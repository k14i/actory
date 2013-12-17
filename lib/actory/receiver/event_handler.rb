module Actory
module Receiver

class EventHandler

  def receive(method, arg=nil, results=[])
    plugin = Actory::Receiver::Plugin.new
    arg ? results << plugin.send(method, arg) : results << plugin.send(method)
    return results
  rescue => e
    raise StandardError, e
  end

end

end #Receiver
end #Actory
