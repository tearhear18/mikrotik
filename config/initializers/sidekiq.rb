Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/1') }
end
Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/1') }
end

# Sidekiq::Queue['recommend'].limit = 1