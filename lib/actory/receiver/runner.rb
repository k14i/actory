module Actory
module Receiver

class Runner < Base
  def initialize(protocol="tcp", target: nil)
    protocol = RECEIVER['protocol'] if RECEIVER['protocol']
    num = Parallel.processor_count
    target ||= Actory::Receiver::EventHandler
    Parallel.map(0..num, :in_processes => num) do |n|
      is_retried = false
      begin
        runner = send(protocol, target, n)
        Signal.trap(:TERM) { runner.stop }
        Signal.trap(:INT) { runner.stop }
        runner.run
      rescue => e
        @logger.error(e) unless is_retried
        is_retried = true
        retry
      end
    end
  end

  private

  def tcp(target, num)
    runner = MessagePack::RPC::Server.new
    runner.listen(RECEIVER['address'], RECEIVER['port'] + num, target.new)
    runner
  end

  def udp(target, num)
    address  = MessagePack::RPC::Address.new(RECEIVER['address'], RECEIVER['port'] + num)
    listener = MessagePack::RPC::UDPServerTransport.new(address)
    runner   = MessagePack::RPC::Server.new
    runner.listen(listener, target.new)
    runner
  end
end

end #Receiver
end #Actory
