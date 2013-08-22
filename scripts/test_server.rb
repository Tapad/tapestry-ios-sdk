#
# This is a test server intended to provide mock responses to Tapestry iOS SDK
# unit tests, which expect to reason this server on localhost:4567.
#
# Usage:
#   ruby scripts/test_server.rb -p 4567
#

require "rubygems"
require "sinatra"
require "json"

get "*" do
  puts "Params: #{params.inspect}"
  puts "User Agent: #{request.user_agent}"
  puts "Cookies: #{request.cookies}"

  # Sleep for dynamic number of seconds, for network connection timeout tests.
  if ta_set_data = params["ta_set_data"]
    # "foo:bar,baz:qux" becomes {"foo"=>"bar", "baz"=>"qux"}
    kvs = Hash[*ta_set_data.split(",").map{|kv| kv.split(":")}.flatten]
    if sleep_seconds = kvs["sleep"]
      begin
        puts "Going to delay response for #{sleep_seconds} seconds"
        sleep(sleep_seconds.to_i)
      rescue
        # Don't want to return 500 if the client mistakenly sends non-numeric
        # value for "sleep" key.
        puts "Ignoring non-numeric value for 'sleep' key: #{sleep_seconds}"
      end
    end
  end

  response = {
    :ids => {},
    :data => { :query => [request.query_string] },
    :audiences => [],
    :platforms => ["iPhone"]
  }
  content_type :json
  response.to_json
end
