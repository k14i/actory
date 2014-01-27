module Actory
module Sender

class Dispatcher < Base
  attr_accessor :actors, :trusted_hosts, :system_info, :receiver_count, :my_processor_count

  def initialize(actors: [])
    @actors = []
    @trusted_hosts = []
    @receiver_count = 0
    @system_info = []
    @my_processor_count = Parallel.processor_count
    initial_handshaking(actors)
    establish_connections
  rescue => e
    @@logger.error Actory::Errors::Generator.new.json(level: "error", message: "Initialization failed.", backtrace: $@)
    exit 1
  end

  def message(method, args=[], results=[])
    args = [nil] if args.empty?
    assignment = assign_jobs(args)

    pbar = ProgressBar.new(method, @receiver_count) if SENDER['show_progress']

    results << Parallel.map(assignment, :in_processes => @receiver_count) do |arg, actor|
      if SENDER['show_progress']
        begin
          pbar.set pbar.current + 1 if pbar.current <= @receiver_count
        rescue
        end
      end

      begin
        actor.send("receive", "reload") if SENDER['reload_receiver_plugins']
        res = actor.send("receive", method, arg)
        sleep SENDER['get_interval'] # @todo Assign hard-corded parameter if no param defined.
        ret = res.get
        ret.flatten!
        {actor.address.to_s => ret}
      rescue => e
        @@logger.warn Actory::Errors::Generator.new.json(level: "warn", message: "Something wrong with sending a message to #{actor.address}", backtrace: $@)
        actor = change_actor(actor)
        retry
      end
    end
    results.flatten
  rescue => e
    puts $@, e
    raise StandardError
  end

  private

  def initial_handshaking(actors=[])
    actors = SENDER['actors'] if actors.empty? and SENDER['actors'].nil? == false
    actors.each do |actor|
      next unless actor.class == String
      actor = actor.gsub(/:/, " ").split
      host = actor[0]
      port = actor[1].to_i # @todo Assign default port if no port specified.
      @cli = MessagePack::RPC::Client.new(host, port)
      @cli.timeout = SENDER['auth']['timeout'] # @todo Assign hard-corded parameter if no param defined.
      next unless get_trusted_hosts(host)
      # @todo Put the system_info to use.
      # @system_info << {:host => host, :system_info => get_system_info}
      get_receiver_count
    end
  rescue => e
    puts $@, e
    raise StandardError
  end

  def establish_connections
    case SENDER['policy']
    when "even"
      establish_connections_evenly
    when "random"
      establish_connections_randomly(@receiver_count)
    when "safe-random"
      return 0 if @trusted_hosts.empty?
      establish_connections_randomly(@my_processor_count / @trusted_hosts.count)
    else
      establish_connections_evenly
    end
    raise StandardError if @actors.count == 0
    @actors.count
  end

  def establish_connections_randomly(num=0)
    establish_connections_helper(num)
  end

  def establish_connections_evenly
    return nil if @trusted_hosts.empty?
    cores_per_host = @my_processor_count / @trusted_hosts.count
    cores_per_host = 1 if cores_per_host <= 0
    establish_connections_helper(cores_per_host)
  end

  def establish_connections_helper(num=0)
    num.times do |n|
      SENDER['actors'].each do |actor|
        next unless actor.class == String
        actor = actor.gsub(/:/, " ").split
        host = actor[0]
        next unless trusted_hosts.include?(host)
        port = actor[1].to_i # @todo Assign default port if no port specified.
        # @todo Examine disconnection existing connections used in in.initial_handshaking.
        cli = MessagePack::RPC::Client.new(host, port + n)
        cli.timeout = SENDER['timeout'] # @todo Assign hard-corded parameter if no param defined.
        @actors << cli
      end
    end
    @@logger.debug @actors
  end

  def get_trusted_hosts(host)
    res = @cli.send("receive", "auth?", SENDER['auth']['shared_key'])
    res.get[0] ? @trusted_hosts << host : nil
  rescue => e
    @@logger.warn Actory::Errors::Generator.new.json(level: "warn", message: "#{__method__} failed with #{host}", backtrace: $@)
    return nil
  end

  def get_system_info
    res = @cli.send("receive", "system_info")
    res.get[0]
  end

  def get_receiver_count
    res = @cli.send("receive", "processor_count")
    @receiver_count += res.get[0] if res.get[0]
  rescue
    return -1
  end

  def assign_jobs(args)
    num = 0
    params = {}
    return params if args[0].nil? or @actors.empty? or @my_processor_count.nil?
    actors = @actors.sample(@my_processor_count)
    args.each do |arg|
      next if params.has_key?(arg) # @note Skip duplicated keys.
      num = 0 unless actors[num] # @note Make the actors loop reset if the pointer reaches the end.
      params.merge!(arg => actors[num]) # @note Assign a job to an actor.
      num += 1
    end
    @@logger.debug params
    params
  end

  #def select_actors
  #  actors = nil
  #  case SENDER['policy']
  #  when "even"
  #    actors = @actors
  #  when "random", "safe-random"
  #    actors = @actors.sample(@my_processor_count)
  #  else
  #    actors = @actors
  #  end
  #  actors
  #end

  def change_actor(previous_actor)
    new_actor = nil
    loop do
      new_actor = @actors.sample
      break unless new_actor == previous_actor
    end
    new_actor
  end

end

end #Sender
end #Actory
