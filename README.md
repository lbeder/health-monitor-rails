# health-monitor-rails

[![Gem Version](https://badge.fury.io/rb/health-monitor-rails.svg)](http://badge.fury.io/rb/health-monitor-rails)
[![Build Status](https://github.com/lbeder/health-monitor-rails/actions/workflows/ci.yml/badge.svg)](https://github.com/lbeder/health-monitor-rails/actions/workflows/ci.yml)

This is a health monitoring Rails mountable plug-in, which checks various services (db, cache, sidekiq, redis, etc.).

Mounting this gem will add a '/check' route to your application, which can be used for health monitoring the application and its various services. The method will return an appropriate HTTP status as well as an HTML/JSON/XML response representing the state of each provider.

You can filter which checks to run by passing a parameter called ```providers```.

## Examples

### HTML Status Page

![alt example](/docs/screenshots/page.png "HTML Status Page")

### JSON Response

```bash
>> curl -s http://localhost:3000/check.json | json_pp
```

```json
{
   "timestamp" : "2017-03-10 17:07:52 +0200",
   "status" : "ok",
   "results" : [
      {
         "name" : "Database",
         "message" : "",
         "status" : "OK"
      },
      {
         "status" : "OK",
         "message" : "",
         "name" : "Cache"
      },
      {
         "status" : "OK",
         "message" : "",
         "name" : "Redis"
      },
      {
         "status" : "OK",
         "message" : "",
         "name" : "Sidekiq"
      }
   ]
}
```

### Filtered JSON Response

```bash
>> curl -s http://localhost:3000/check.json?providers[]=database&providers[]=redis | json_pp
```

```json
{
   "timestamp" : "2017-03-10 17:07:52 +0200",
   "status" : "ok",
   "results" : [
      {
         "name" : "Database",
         "message" : "",
         "status" : "OK"
      },
      {
         "status" : "OK",
         "message" : "",
         "name" : "Redis"
      },
   ]
}
```

### XML Response

```bash
>> curl -s http://localhost:3000/check.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <results type="array">
    <result>
      <name>Database</name>
      <message></message>
      <status>OK</status>
    </result>
    <result>
      <name>Cache</name>
      <message></message>
      <status>OK</status>
    </result>
    <result>
      <name>Redis</name>
      <message></message>
      <status>OK</status>
    </result>
    <result>
      <name>Sidekiq</name>
      <message></message>
      <status>OK</status>
    </result>
  </results>
  <status type="symbol">ok</status>
  <timestamp>2017-03-10 17:08:50 +0200</timestamp>
</hash>
```

### Filtered XML Response

```bash
>> curl -s http://localhost:3000/check.xml?providers[]=database&providers[]=redis
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <results type="array">
    <result>
      <name>Database</name>
      <message></message>
      <status>OK</status>
    </result>
    <result>
      <name>Redis</name>
      <message></message>
      <status>OK</status>
    </result>
  </results>
  <status type="symbol">ok</status>
  <timestamp>2017-03-10 17:08:50 +0200</timestamp>
</hash>
```

## Setup

If you are using bundler add health-monitor-rails to your Gemfile:

```ruby
gem 'health-monitor-rails'
```

Then run:

```bash
bundle install
```

Otherwise, install the gem:

```bash
gem install health-monitor-rails
```

## Usage

You can mount this inside your app routes by adding this to config/routes.rb:

```ruby
mount HealthMonitor::Engine, at: '/'
```

## Supported Service Providers

The following services are currently supported:

* DB
* Cache
* Redis
* Sidekiq
* Resque
* Delayed Job
* Solr
* FileAbsence

## Configuration

### Adding Providers

By default, only the database check is enabled. You can add more service providers by explicitly enabling them via an initializer:

```ruby
HealthMonitor.configure do |config|
  config.cache
  config.redis
  config.sidekiq
  config.delayed_job
end
```

We believe that having the database check enabled by default is very important, but if you still want to disable it
(e.g., if you use a database that isn't covered by the check) - you can do that by calling the `no_database` method:

```ruby
HealthMonitor.configure do |config|
  config.no_database
end
```

When you have multiple databases and and want to check each configuration separately you can use following method:
```ruby
HealthMonitor.configure do |config|
  config.no_database # Disable default all databases check
  config.database.configure do |provider_config|
    provider_config.config_name = 'primary'
  end
  config.database.configure do |provider_config|
    provider_config.name = 'Secondary'
    provider_config.config_name = 'secondary'
    provider_config.critical = false
  end
end
```

### Provider Configuration

All providers accept a general set of baseline configuration:

```ruby
HealthMonitor.configure do |config|
  config.[provider].configure do |provider_config|
    provider_config.name = 'Redis'
    provider_config.critical = true
  end
end
```

* __name__: Custom name for the provider (Defaults to __class name__. Ex: 'Redis', 'Sidekiq')
* __critical__: Whether or not the provider is a critical dependency (Defaults to: __true__). If set to __false__, the monitor will report its status as `WARNING` but ignore it when determining overall application health status. This could be used to send to a non critical notifications channel

> The __critical__ option allows you to monitor for additional non-critical dependencies that are not fully required for your application to be operational, like a cache database for instance

Some of the providers can also accept additional configuration:

```ruby
# Sidekiq
HealthMonitor.configure do |config|
  config.sidekiq.configure do |sidekiq_config|
    sidekiq_config.latency = 3.hours
    sidekiq_config.queue_size = 50
  end
end

# Sidekiq with specific queues
HealthMonitor.configure do |config|
  config.sidekiq.configure do |sidekiq_config|
    sidekiq_config.add_queue_configuration('critical', latency: 10.seconds, queue_size: 20)
  end
end

```

```ruby
# Redis with existing connection
HealthMonitor.configure do |config|
  config.redis.configure do |redis_config|
    redis_config.connection = Redis.current # Use your custom redis connection
    redis_config.max_used_memory = 200 # Megabytes
  end
end
```

Additionally, you can configure an explicit URL:

```ruby
# Redis with a URL configuration
HealthMonitor.configure do |config|
  config.redis.configure do |redis_config|
    redis_config.url = 'redis://user:pass@example.redis.com:90210/'
    redis_config.max_used_memory = 200
  end
end
```

Or via a connection pool:

```ruby
# Redis using Connection Pools
HealthMonitor.configure do |config|
  config.redis.configure do |redis_config|
    redis_config.connection = ConnectionPool.new(size: 5) { Redis.new } # Use your custom connection pool
  end
end
```

For providers that can be configured with its endpoints/urls you can also add multiple declarations to ensure you are reporting across all dependencies:

```ruby
HealthMonitor.configure do |config|
  config.redis.configure do |c|
    c.name = 'Redis: Cache'
    c.url = ENV.fetch('REDISCLOUD_URL', 'redis://localhost:6379/0')
  end
  config.redis.configure do |c|
    c.name = 'Redis: Action Cable'
    c.url = ENV.fetch('REDISCLOUD_URL', 'redis://localhost:6379/0')
  end
  config.redis.configure do |c|
    c.name = 'Redis: Sidekiq'
    c.url = ENV.fetch('REDISCLOUD_URL', 'redis://localhost:6379/1')
  end
end
```

The currently supported settings are:

#### Sidekiq

* `latency`: the latency (in seconds) of a queue (now - when the oldest job was enqueued) which is considered unhealthy (the default is 30 seconds, but larger processing queue should have a larger latency value).
* `queue_size`: the size (maximum) of a queue which is considered unhealthy (the default is 100).
* `default_queue`: the default queue to check.
* `add_queue_configuration`: add specific configuration per queue.

#### Redis

* `url`: the URL used to connect to your Redis instance. Note, that this is an optional configuration and will use the default connection if not specified. You can also use `url` to explicitly configure authentication (e.g., `'redis://user:pass@example.redis.com:90210/'`).
* `connection`: Use custom Redis connection (e.g., `Redis.current`).
* `max_used_memory`: Set maximum expected memory usage of Redis in megabytes. Prevent memory leaks and keys over storing.

Please note that `url` or `connection` can't be used at the same time.

#### Delayed Job

* `queue_size`: the size (maximum) of a queue which is considered unhealthy (the default is 100).

### Solr

* `url`: the URL used to connect to your Solr instance - must be a string. You can also use `url` to explicitly configure authentication (e.g., `'https://user:pass@example.solr.com:8983/'`)
* `collection`: An optional parameter used to connect to your specific Solr collection - must be a string. By setting this parameter the code will check the status of this individual collection in your Solr instance instead of just the status of the overall Solr instance

### FileAbsence

This check allows you to create a file on your server when you would like to force the check to fail. For example, if utilizing the `health.json` as the health check page for your load balancer and would like to force a machine offline.

* `filename`: the file relative to the rails root that must remain absent for the health check to remain passing. For example: `public/remove-from-nginx` (Can also be a full path `/opt/app/remove-from-nginx`)

### Adding a Custom Provider

It's also possible to add custom health check providers suited for your needs (of course, it's highly appreciated and encouraged if you'd contribute useful providers to the project).

To add a custom provider, you'd need to:

* Implement the `HealthMonitor::Providers::Base` class and its `check!` method (a check is considered as failed if it raises an exception):

```ruby
class CustomProvider < HealthMonitor::Providers::Base
  def check!
    raise 'Oh oh!'
  end
end
```

* Add its class to the configuration:

```ruby
HealthMonitor.configure do |config|
  config.add_custom_provider(CustomProvider)
end
```

### Adding a Custom Error Callback

If you need to perform any additional error handling (for example, for additional error reporting), you can configure a custom error callback:

```ruby
HealthMonitor.configure do |config|
  config.error_callback = proc do |e|
    logger.error "Health check failed with: #{e.message}"

    Raven.capture_exception(e)
  end
end
```

### Adding Authentication Credentials

By default, the `/check` endpoint is not authenticated and is available to any user. You can authenticate using HTTP Basic Auth by providing authentication credentials:

```ruby
HealthMonitor.configure do |config|
  config.basic_auth_credentials = {
    username: 'SECRET_NAME',
    password: 'Shhhhh!!!'
  }
end
```

### Adding Environment Variables

By default, environment variables are `nil`, so if you'd want to include additional parameters in the results JSON, all you need is to provide a `Hash` with your custom environment variables:

```ruby
HealthMonitor.configure do |config|
  config.environment_variables = {
    build_number: 'BUILD_NUMBER',
    git_sha: 'GIT_SHA'
  }
end
```

### Customizing the path

By default, the endpoint where the status page is served is `/check`, but this can be customized:

```ruby
HealthMonitor.configure do |config|
  config.path = :status
end
```

This will make the page to be served in the `/status` endpoint for instance (from where the engine was mounted).

### Showing Response Times of Checks

```ruby
HealthMonitor.configure do |config|
  config.response_threshold = 0.8
end
```
By default, this setting is disabled. Enable it and enter a floating‑point threshold value. Once enabled, each provider logs its response time; if a provider’s response time exceeds the threshold, the issue will be visible via the `/check` endpoint.

### Monitoring Script

A Nagios/Shinken/Icinga/Icinga2 plugin is available in `extra` directory.

It takes one argument: `-u` or `--uri`

```sh
nicolas@desktop:$ ./check_rails.rb
missing argument: uri

Usage: check_rails.rb -u uri
    -u, --uri URI                    The URI to check (https://nagios:nagios@example.com/check.json)

Common options:
    -v, --version                    Displays Version
    -h, --help                       Displays Help
```

Also, it generates an output with the right status code for your monitoring system:

```sh
nicolas@desktop:$ ./check_rails.rb -u http://admin:admin@localhost:5000/check.json
Rails application : OK

Database : OK
Cache : OK
Redis : OK
Sidekiq : OK

nicolas@desktop:$ echo $?
0
```

```sh
nicolas@desktop:$ ./check_rails.rb -u http://admin:admin@localhost:5000/check.json
Rails application : ERROR

Database : OK
Cache : OK
Redis : ERROR (Error connecting to Redis on 127.0.0.1:6379 (Errno::ECONNREFUSED))
Sidekiq : ERROR (Error connecting to Redis on 127.0.0.1:6379 (Errno::ECONNREFUSED))

nicolas@desktop:$ echo $?
2
```

## Development

In order to work on development on the gem itself

### Installing the gems

Use the [appraisal gem](https://github.com/thoughtbot/appraisal) to install the bundles for different rails versions:

```bash
appraisal clean
appraisal generate
appraisal install
```

### Running the tests

Use appraisal to run the tests using rake

```bash
appraisal rake
```

## License

The MIT License (MIT)

Copyright (c) 2017

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
