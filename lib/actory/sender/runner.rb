module Actory
module Sender

class Runner
  attr_accessor :actors, :trusted_hosts, :receiver_count, :my_processor_count

  def initialize
    @actors = []
    @trusted_hosts = []
    @receiver_count = 0
    @my_processor_count = Parallel.processor_count
    initial_handshaking
    establish_connections
  end

  def message(method, args=[], results=[])
    args = [nil] if args.empty?
    assignment = assign_jobs(args)

    results << Parallel.map(assignment, :in_processes => @receiver_count) do |arg, actor|
      print '.'
      begin
        res = actor.send("receive", method, arg)
        sleep SENDER['get_interval']
        ret = res.get
        ret.flatten!
        {actor.address.to_s => ret}
      rescue
        actor = change_actor(actor)
        retry
      end
    end
    return results.flatten
  end

  private

  def initial_handshaking
    SENDER['actors'].each do |actor|
      next unless actor.class == String
      actor = actor.gsub(/:/, " ").split
      host = actor[0]
      port = actor[1].to_i
      @cli = MessagePack::RPC::Client.new(host, port)
      @cli.timeout = SENDER['auth']['timeout']
      ret = get_trusted_hosts(host)
      next unless ret
      get_receiver_count
    end
  end

  def establish_connections
    case SENDER['policy']
    when "even"
      establish_connections_evenly
    when "random"
      establish_connections_randomly(@receiver_count)
    when "safe-random"
      establish_connections_randomly(@my_processor_count / @trusted_hosts.count)
    else
      establish_connections_evenly
    end
  end

  def establish_connections_randomly(num=1)
    establish_connections_helper(num)
  end

  def establish_connections_evenly
    cores_per_host = @my_processor_count / @trusted_hosts.count
    cores_per_host = 1 if cores_per_host <= 0
    establish_connections_helper(cores_per_host)
  end

  def establish_connections_helper(num=1)
    num.times do |n|
      SENDER['actors'].each do |actor|
        next unless actor.class == String
        actor = actor.gsub(/:/, " ").split
        host = actor[0]
        next unless trusted_hosts.include?(host)
        port = actor[1].to_i
        cli = MessagePack::RPC::Client.new(host, port + n)
        cli.timeout = SENDER['timeout']
        @actors << cli
      end
    end
  end

  def get_trusted_hosts(host)
    res = @cli.send("receive", "auth?", SENDER['auth']['shared_key'])
    res.get[0] ? @trusted_hosts << host : nil
  end

  def get_receiver_count
    res = @cli.send("receive", "processor_count")
    @receiver_count += res.get[0] if res.get[0]
  end

  def assign_jobs(args)
    num = 0
    params = {}
    actors = @actors.sample(@my_processor_count)
    args.each do |arg|
      next if params.has_key?(arg)
      num = 0 unless actors[num]
      actor = actors[num]
      num += 1
      params.merge!(arg => actor)
    end
    params
  end

  def select_actors
    actors = nil
    case SENDER['policy']
    when "even"
      actors = @actors
    when "random", "safe-random"
      actors = @actors.sample(@my_processor_count)
    else
      actors = @actors
    end
    return actors
  end

  def change_actor(previous_actor)
    new_actor = nil
    loop do
      new_actor = @actors.sample
      break unless new_actor == previous_actor
    end
    return new_actor
  end

end

end #Sender
end #Actory
