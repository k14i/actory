actory
======

Actor model like, concurrent and distributed framework for Ruby.

## Installation

`````
gem install actory
`````

## Setup

`````
path_to_actory="/PATH/TO/GEMS/actory-0.0.1"
export PATH=$PATH:$path_to_actory/bin
`````

* /PATH/TO/GEMS above means the path to the directory of gem files. e.g. $HOME/.rvm/gems/ruby-2.0.0-p247@global/gems

### System-wide setup with the root permission

`````
sudo mkdir -p /etc/actory
sudo cp -p $path_to_actory/config/receiver.yml.example /etc/actory
sudo cp -p $path_to_actory/config/sender.yml.example /etc/actory
`````

### System-wide setup under the RubyGems

`````
cd $path_to_actory/config
cp receiver.yml.example receiver.yml
cp sender.yml.example sender.yml
sed -i '' "s/\/etc\/actory/\.\.\/\.\.\/\.\.\/config/g" global.yml
`````

### Setup inside of each indivisual project

`````
echo "gem actory" >> Gemfile
bundle install --path vendor/bundle
cp ./vendor/bundle
path_to_actory="vendor/bundle/ruby/2.0.0/gems/actory-0.0.1"
cp $path_to_actory/config/receiver.yml.example $path_to_actory/config/receiver.yml
cp $path_to_actory/config/sender.yml.example $path_to_actory/config/sender.yml
sed -i '' "s/\/etc\/actory/\.\.\/\.\.\/\.\.\/config/g" $path_to_actory/config/global.yml
`````


## Architecture

* Actor model like message passing API
* Dynamically loaded plugins
* High concurrency
* Low overheads

### System-wide

#### Sending a message to each receiver to make it deal with the message.

`````
  +--------+
  |user app|
  +--------+
    | message(method, arguments)
    v
  +------------------+
  |Sender::Dispatcher|
  +------------------+
    |                                                           execute
    |   +----------------+ msgpack-rpc +----------------------+ method(args) +----------------+
    +-->|sub-process #1/n|------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
    |   +----------------+             +----------------------+              +----------------+
    |   +----------------+             +----------------------+              +----------------+
    +-->|sub-process #2/n|------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
    |   +----------------+             +----------------------+              +----------------+
    |         :                                 :                                     :
    |   +----------------+             +----------------------+              +----------------+
    `-->|sub-process #n/n|------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
        +----------------+             +----------------------+              +----------------+
`````

#### Receiving each returned value at once.

`````
  +--------+
  |user app|
  +--------+
    ^ a hash value in {"host:port" => [return_value(s), ...], ... }
    |
  +------------------+
  |Sender::Dispatcher|
  +------------------+
    ^                                                              return
    |   +----------------+ msgpack-rpc +----------------------+   value(s)   +----------------+
    +---|sub-process #1/n|<------------|Receiver::EventHandler|<-------------|Receiver::Plugin|
    |   +----------------+             +----------------------+              +----------------+
    |   +----------------+             +----------------------+              +----------------+
    +---|sub-process #2/n|<------------|Receiver::EventHandler|<-------------|Receiver::Plugin|
    |   +----------------+             +----------------------+              +----------------+
    |         :                                 :                                     :
    |   +----------------+             +----------------------+              +----------------+
    `---|sub-process #n/n|<------------|Receiver::EventHandler|<-------------|Receiver::Plugin|
        +----------------+             +----------------------+              +----------------+
`````

#### Jobs can be assigned flexibly.

`````
  +--------+
  |user app|
  +--------+
    | message(method, arguments)
    v
  +------------------+
  |Sender::Dispatcher|
  +------------------+
    |                                                           execute
    |   +----------------+ msgpack-rpc +----------------------+ method(args) +----------------+
    +-->|sub-process #1/n|------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
    |   |                |             +----------------------+              +----------------+
    |   |                |             +----------------------+              +----------------+
    +-->|                |------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
    |   +----------------+             +----------------------+              +----------------+
    |   +----------------+             +----------------------+              +----------------+
    +-->|sub-process #2/n|------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
    |   +----------------+             +----------------------+              +----------------+
    |         :                                 :                                     :
    |   +----------------+             +----------------------+              +----------------+
    `-->|sub-process #n/n|------------>|Receiver::EventHandler|------------->|Receiver::Plugin|
        +----------------+             +----------------------+              +----------------+
`````

### Receiver

`````
  +--------------------------------------------------------------------------+
  | a receiver                                                               |
  |                                                                          |
  | +--------+                                                               |
  | | Worker |                                                               |
  | +--------+                                                               |
  |   |                                 +-------------+                      |
  |   | spawn when started              |     CPU     |                      |
  |   |   +-------------------------+   | +---------+ |  +-----------------+ |
  |   +-->|Msgpack::RPC::Server #1/n|-->| |core #1/n|--->|EventHandler #1/n| |
  |   |   +-------------------------+   | +---------+ |  +-----------------+ |
  |   |   +-------------------------+   | +---------+ |  +-----------------+ |
  |   +-->|Msgpack::RPC::Server #2/n|-->| |core #2/n|--->|EventHandler #2/n| |
  |   |   +-------------------------+   | +---------+ |  +-----------------+ |
  |   |              :                  |      :      |          :           |
  |   |   +-------------------------+   | +---------+ |  +-----------------+ |
  |   `-->|Magpack::RPC::Server #n/n|-->| |core #n/n|--->|EventHandler #n/n| |
  |       +-------------------------+   | +---------+ |  +-----------------+ |
  |                                     |             |                      |
  |                                     +-------------+                      |
  |                                                                          |
  +--------------------------------------------------------------------------+
`````

### Sender

`````
  +-----------------------------------------------------+  +-----------------------------+
  | a sender                                            |  | receiver(s)                 |
  |                                                     |  |                             |
  | +------------+                                      |  |                             |
  | | Dispatcher |                                      |  |                             |
  | +------------+                                      |  |                             |
  |   |                                 +-------------+ |  |                             |
  |   | spawn when instantized          |     CPU     | |  |                             |
  |   |   +-------------------------+   | +---------+ | |  | +-------------------------+ |
  |   +-->|Msgpack::RPC::Client #1/n|-->| |core #1/n|------->|Msgpack::RPC::Server #1/m| |
  |   |   +-------------------------+   | +---------+ | |  | +-------------------------+ |
  |   |   +-------------------------+   | +---------+ | |  | +-------------------------+ |
  |   +-->|Msgpack::RPC::Client #2/n|-->| |core #2/n|------->|Msgpack::RPC::Server #2/m| |
  |   |   +-------------------------+   | +---------+ | |  | +-------------------------+ |
  |   |              :                  |      :      | |  |            :                |
  |   |   +-------------------------+   | +---------+ | |  | +-------------------------+ |
  |   `-->|Magpack::RPC::Client #n/n|-->| |core #n/n|------->|Msgpack::RPC::Server #m/m| |
  |       +-------------------------+   | +---------+ | |  | +-------------------------+ |
  |                                     |             | |  |                             |
  |                                     +-------------+ |  |                             |
  |                                                     |  |                             |
  +-----------------------------------------------------+  +-----------------------------+
`````

## Configuration

### config/receiver.yml

* protocol
  * "tcp" or "udp"
* address
  * Binding IP Address.
* port
  * Port number to begin increment.
* shared_key
  * A pre-shared key string to establish connections with a sender.
* log
  * type
    * The type of the log. "stdout", "file" or "both".
  * level
    * A log level. "fatal", "error", "warn", "info" or "debug".
  * target
    * The log file path, used when the "type" is specified as "file" or "both".

### config/sender.yml

* actors
  * A list of actors. The format is "host_name_or_ip_address:port".
* policy
  * The policy to select actors and assign a message to them. "even", "random" or "safe-random".
* timeout
  * Connection timeout value for msgpack-rpc.
* get_interval
  * An interval to retry the get method for msgpack-rpc.
* auth
  * shared_key
    * A pre-shared key string to establish connections with each receiver.
  * timeout
    * Authentication timeout with each receiver.
* show_progress
  * If it is true, the sender shows you a progress bar.
* reload_receiver_plugins
  * If it is true, the sender force each receiver reload plugins even in running.
* log
  * type
    * The type of the log. "stdout", "file" or "both".
  * level
    * A log level. "fatal", "error", "warn", "info" or "debug".
  * target
    * The log file path, used when the "type" is specified as "file" or "both".

## Usage

### Receiver

#### Foreground

`````
actory-receiver
`````

#### Background

`````
actory-receiver -d
`````

### Sender

`````ruby
require 'actory'
dispacher = Actory::Sender::Dispatcher.new
res = dispatcher.message(METHOD, ARGS)
`````

You can specify an actor or actors with an argument with actors keyword.

`````ruby
require 'actory'
dispacher = Actory::Sender::Dispatcher.new(actors: ["localhost:18800"])
res = dispatcher.message(METHOD, ARGS)
`````

`````ruby
require 'actory'
actors = ["192.168.1.1:18800", "192.168.1.2:18800", "192.168.1.3:18800"]
dispacher = Actory::Sender::Dispatcher.new(actors: actors)
res = dispatcher.message(METHOD, ARGS)
`````

## Plugin

You can create your own plugin(s) to be executed by the receiver.

`````ruby
module Actory
module Receiver

class Plugin < Base

  def hello(arg)
    return "Hello #{arg}."
  rescue => e
    msg = Actory::Errors::Generator.new.json(level: "ERROR", message: e.message, backtrace: $@)
    raise StandardError, msg
  end

end

end
end
`````

If you have created a plugin, put it just under the lib/actory/receiver/plugin directory. Then it will be automatically loaded even in the receiver running.

And then, you can call the method from a sender like following:

`````ruby
require 'actory'
dispacher = Actory::Sender::Dispatcher.new
res = dispatcher.message("hello", "world")
`````

The response in a hash will be like following:

`````ruby
p res
{"127.0.0.1:18800"=>["Hello world."], "192.168.1.1:18800"=>["Hello world."], ..., "192.168.1.3:18807"=>["Hello world"]}
`````

## License

Apache License, Version 2.0
