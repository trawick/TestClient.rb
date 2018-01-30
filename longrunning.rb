require 'uri'

require 'r_l_sock_client'
require 'test_client_util'

host = "172.16.248.131:8080"
url  = "http://#{host}/webspace/cgi-bin/sak.pl?seconds=100"

concurrency = 5

uri = URI.parse(url)

while concurrency > 0
  Thread.new do
    loop do
      client = RLSockClient.new(uri, 8192, 8192, 100, 0, 20)
      client.execute(nil)
    end
  end
  concurrency -= 1
end

TestClientUtil.join_all
