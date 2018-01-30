require 'uri'

require 'r_l_sock_client'
require 'test_client_util'

host = "192.168.1.81"
url  = "http://#{host}/index.html"

concurrency = 10

uri = URI.parse(url)

while concurrency > 0
  Thread.new do
    loop do
      client = RLSockClient.new(uri, 5, 8192, 100, 2, 1)
      client.execute(nil)
    end
  end
  concurrency -= 1
end

TestClientUtil.join_all
