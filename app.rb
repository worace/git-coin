require "redis"
require "sinatra"
require "digest/sha1"
require "json"
require "date"
require 'sequel'

class GitCoin < Sinatra::Base
  set :lock, true
  TARGET_KEY = "gitcoin:current_target"
  GITCOINS_SET_KEY = "gitcoins:by_owner"

  def self.redis
    @@redis
  end

  def self.db_url
    ENV["DATABASE_URL"] || 'postgres://@localhost/gitcoins'
  end

  def self.database
    @@database ||= Sequel.connect(db_url)
  end

  def database
    self.class.database
  end

  def redis
    self.class.redis
  end

  def self.initialize_redis
    unless defined?(@@redis)
      if ENV["REDISTOGO_URL"] #heroku
        uri = URI.parse(ENV["REDISTOGO_URL"])
        @@redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        @@redis = Redis.new
      end

      redis.set(TARGET_KEY, largest_sha) unless redis.get(TARGET_KEY)
    end
  end

  configure do
    initialize_redis
  end

  get "/target" do
    current_target
  end

  get "/gitcoins" do
    erb :gitcoins, locals: {gitcoins: gitcoins}
  end

  post "/hash" do
    content_type :json
    if coin = new_target?(params[:message], params[:owner])
      {:success => true, :gitcoin_assigned => coin, :new_target => current_target}.to_json
    else
      {:success => false, :gitcoin_assigned => false, :new_target => current_target}.to_json
    end
  end

  def new_target?(message, owner)
    digest = Digest::SHA1.hexdigest(message)
    if digest.hex < current_target.hex
      assign_gitcoin(owner: owner, digest: digest, message: message, parent: current_target)
      set_target(digest)
    else
      false
    end
  end

  def set_target(digest)
    redis.set(TARGET_KEY, digest)
  end

  def assign_gitcoin(options)
    GitCoin.database[:coins].insert(options.merge(created_at: Time.now, value: value(options[:parent])))
  end

  def value(digest)
    #number of leading 0's squared
    (digest[/\A0+/].to_s.length + 1) ** 2
  end

  def current_target
    redis.get(TARGET_KEY)
  end

  def gitcoins
    database[:coins].reverse_order(:created_at).all
  end

  def self.reset!
    initialize_redis
    redis.set(TARGET_KEY, largest_sha)
  end

  def self.largest_sha
    "F" * 40
  end
end
