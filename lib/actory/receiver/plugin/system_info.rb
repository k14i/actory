module Actory
module Receiver

class Plugin

  def system_info
    info = {
      :memory => {
        :free => Facter.value(:memoryfree),
        :size => Facter.value(:memorysize),
      },
      :processor => {
        :count => Facter.value(:processorcount),
        :physicalcount => Facter.value(:physicalprocessorcount),
      },
      :swap => {
        :free => Facter.value(:swapfree),
        :size => Facter.value(:swapsize),
      },
      :timezone => Facter.value(:timezone),
      :virtual => Facter.value(:virtual),
    }
    return info
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end

end

end #Receiver
end #Actory
