require 'uri'
require 'getoptlong'

require 'r_l_sock_client'
require 'test_client_util'

parser = GetoptLong.new
parser.set_options(
  ["-c", "--concurrency", GetoptLong::REQUIRED_ARGUMENT],
  ["-w", "--write-rate",  GetoptLong::REQUIRED_ARGUMENT],
  ["-r", "--read-rate",   GetoptLong::REQUIRED_ARGUMENT],
  ["-s", "--sleep",       GetoptLong::REQUIRED_ARGUMENT]
  )

# set up defaults
concurrency = 1
url = "http://127.0.0.1:8080/"
sleep_after_connect = 0 # secs
write_rate = 8192 # per sec
read_rate  = 8192 # per sec
read_wait_time = 3 # max secs to wait

loop do
  begin
    opt, arg = parser.get
    break if not opt
    
    case opt
    when "-c"
      concurrency = arg.to_i
    when "-w"
      write_rate = arg.to_i
    when "-r"
      read_rate = arg.to_i
    when "-s"
      sleep_after_connect = arg.to_i
    end
  rescue => err
    STDERR.puts err
    exit(1)
  end
end

if ARGV.size == 1
  url = ARGV[0]
elsif ARGV.size > 1
  STDERR.puts "too many args"
  exit(1)
end

uri = URI.parse(url)

while concurrency > 1
  Thread.new do
    client = RLSockClient.new(uri, write_rate, read_rate, read_wait_time, sleep_after_connect)
    client.execute(nil)
  end
  concurrency -= 1
end
client = RLSockClient.new(uri, write_rate, read_rate, read_wait_time, sleep_after_connect)
client.execute(nil)

TestClientUtil.join_all()
