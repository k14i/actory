module Actory
module Receiver

class Plugin

  def system_info
    info = {
      :processor => {
        :count => Facter.value(:processorcount),
        :physicalcount => Facter.value(:physicalprocessorcount),
      },
      :memory => {
        :free => Facter.value(:memoryfree),
        :size => Facter.value(:memorysize),
      },
      :swap => {
        :free => Facter.value(:swapfree),
        :size => Facter.value(:swapsize),
      },
      :timezone => Facter.value(:timezone),
    }
    return info
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end

end

end #Receiver
end #Actory
