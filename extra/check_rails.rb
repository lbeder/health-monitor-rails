#!/usr/bin/env ruby
# frozen_string_literal: true

#===============================================================================
#         FILE: check_rails.rb
#        USAGE: ./check_rails.rb -u <uri>
#  DESCRIPTION: check Rails application status
#       AUTHOR: Rodriguez Nicolas <nicoladmin@free.fr>
#      LICENSE: The MIT License
#===============================================================================

require 'json'
require 'optparse'
require 'net/http'
require 'yaml'
require 'English'

VERSION = '1.0.0'
MANDATORY_PARAMS = [:uri].freeze

# Configure options parser
options = {}

parser =
  OptionParser.new do |opts|
    opts.banner = 'Usage: check_rails.rb -u uri'

    opts.on('-u', '--uri URI', 'The URI to check (https://nagios:nagios@example.com/check.json)') do |n|
      options[:uri] = n
    end

    opts.on_tail('-v', '--version', 'Displays Version') do
      puts "Version : #{VERSION}"
      exit
    end

    opts.separator ''
    opts.separator 'Common options:'

    opts.on_tail('-h', '--help', 'Displays Help') do
      puts opts
      exit
    end
  end

# Parse command line options :
# Raise an exception if mandatory params are missing.
# The exception is immediately captured and the script is exited.
begin
  parser.parse!
  missing = MANDATORY_PARAMS.select { |p| options[p].nil? }
  raise OptionParser::MissingArgument.new(missing.join(', ')) unless missing.empty?
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $ERROR_INFO.to_s
  puts ''
  puts parser
  exit 1
end

# Parse URI
uri = URI(options[:uri])

# Prepare request
req = Net::HTTP::Get.new(uri, 'User-Agent' => "check_rails/v#{VERSION}")
req.basic_auth(uri.user, uri.password)

# Send request
res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

# Check response
if res.code == '200'
  data = JSON.parse(res.body)

  ret_val = data['status'] == 'ok' ? 0 : 2

  puts "Rails application : #{data['status'].upcase}"
  puts ''

  # Print results
  data['results'].each do |result|
    if result['status'] == 'ERROR'
      puts "#{result['name']} : #{result['status']} (#{result['message']})"
    else
      puts "#{result['name']} : #{result['status']}"
    end
  end
else
  puts "Rails application : HTTP error #{res.code}"
  ret_val = 2
end

exit ret_val
