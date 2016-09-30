uri = ENV['REDISTOGO_URL'] || 'redis://localhost:6379/'
uri = URI.parse(uri)
REDIS = Redis.new(:url => uri)
