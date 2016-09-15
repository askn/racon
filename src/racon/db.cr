require "yaml"

class DB
  @@pool = uninitialized ConnectionPool(PG::Connection)

  # TODO
  def self.pool
    @@pool
  end

  class Config
    YAML.mapping(
      database: String,
      host: String,
      user: String,
      password: String,
      capacity: Int32,
      timeout: Float64
    )
  end

  def initialize(file)
    config = DB::Config.from_yaml(file)
    database_url = url(config)
    capacity = config.capacity
    timeout = config.timeout

    @@pool = ConnectionPool.new(capacity: capacity, timeout: timeout) { PG.connect database_url }.as(ConnectionPool(PG::Connection))
  end

  def url(config)
    host = config.host
    database = config.database
    user = config.user
    password = config.password
    return "postgresql://#{user}:#{password}@#{host}/#{database}"
  end

  def connect
    @@pool.connection do |co|
      yield co
    end
  end
end
