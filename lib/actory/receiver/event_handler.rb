module Actory
module Receiver

class EventHandler

  def receive(method, arg=nil, results=[])
    if arg
      results << Actory::Receiver::Plugin.new.send(method, arg)
    else
      results << Actory::Receiver::Plugin.new.send(method)
    end
    return results
  rescue => e
    raise StandardError, e
  end

end

end #Receiver
end #Actory
