require 'rubygems'
require 'keymap'
require 'yaml'
require 'logger'

Keymap::Base.configurations['redis'] = {
    :adapter => 'redis',
    :host => 'localhost'
}

class User < Keymap::Base

  establish_connection 'redis'

  def test
    c = self.connection
    puts 'hi'
  end
end

user = User.new
user.test

#
#config = {adapter: 'redis',
#          host: 'localhost'
#          #database: database,
#          #username: user,
#          #password: password,
#}
#Keymap::Base.establish_connection(config)
#Keymap::Base.logger = Logger.new(STDERR)
#
#class User < Keymap::Base
#end

#puts User.count
# SQL (0.000277)   SELECT count(*) AS count_all FROM users
# 6


#require 'redis'
#require 'keymap/connection_adapters/redis_adapter'
#require 'keymap/connection_adapters/abstract/connection_specification'
#
#Base.configurations["redis"] = {
#    :adapter => 'redis',
#    :host => 'localhost'
#}
#
#Base.establish_connection(
#    :adapter => "redis",
#    :host => "localhost"
#)
#
#
##
##class Table1 < ActiveRecord::Base
##  establish_connection "db1"
##end
##
##class Table2 < ActiveRecord::Base
##  establish_connection "db2"
##end
#
#
#redis = ConnectionAdapters::RedisAdapter.new nil, nil, {host: "localhost"}
#puts redis.active?
#
#redis.reconnect!
#puts redis.active?
#
#redis.transaction do
#  tokens = redis.hash 'tokens'
#  tokens[:auth] = 'no way'
#  puts tokens[:auth]
#end
#
#redis.transaction do
#  tokens = redis.hash 'tokens'
#  tokens.each do |key, value|
#    puts "#{key},#{value}"
#  end
#end
#
#redis.disconnect!
#puts redis.active?
#
#
