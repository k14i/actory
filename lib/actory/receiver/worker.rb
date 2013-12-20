module Actory
module Receiver

class Worker < Base
  def initialize(protocol="tcp", target: nil)
    protocol = RECEIVER['protocol'] if RECEIVER['protocol']
    num = Parallel.processor_count
    target ||= Actory::Receiver::EventHandler
    Parallel.map(0..num, :in_processes => num) do |n|
      @@logger.info "Starting Actory Receiver Worker ##{n + 1}/#{num} (PID = #{Process.pid}, PGROUP = #{Process.getpgrp}, protocol = #{protocol})"
      is_retried = false
      begin
        worker = send(protocol, target, n)
        Signal.trap(:TERM) { worker.stop }
        Signal.trap(:INT) { worker.stop }
        worker.run
      rescue => e
        @@logger.error(Actory::Errors::Generator.new.json(level: "error", message: e, backtrace: $@)) unless is_retried
        is_retried = true
        retry
      end
    end
  end

  private

  def tcp(target, num)
    worker = MessagePack::RPC::Server.new
    worker.listen(RECEIVER['address'], RECEIVER['port'] + num, target.new)
    worker
  end

  def udp(target, num)
    address  = MessagePack::RPC::Address.new(RECEIVER['address'], RECEIVER['port'] + num)
    listener = MessagePack::RPC::UDPServerTransport.new(address)
    worker   = MessagePack::RPC::Server.new
    worker.listen(listener, target.new)
    worker
  end
end

end #Receiver
end #Actory
