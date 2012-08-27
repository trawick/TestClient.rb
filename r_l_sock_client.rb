require 'socket'

require 'r_l_sock_reader'
require 'r_l_sock_writer'

class Sleeper

  def initialize(s)
    @sleeptime = s
  end

  def execute(sock)
    sleep(@sleeptime) unless @sleeptime == 0
  end

end

class RLSockClient

  def initialize(uri, write_rate, read_rate, read_wait_time, sleep_after_connect, repeats = 1, sleep_in_keepalive = 8)
    @cmds = []
    @uri = uri

    path_and_query = uri.path
    path_and_query = "#{path_and_query}?#{uri.query}" unless uri.query == nil
      
    @cmds << Sleeper.new(sleep_after_connect)

    i = 0
    while i < repeats
      w = RLSockWriter.new
      w.set_bytes_per_sec(write_rate)
      w.set_data("GET #{path_and_query} HTTP/1.1\r\nHost: #{uri.host}\r\n\r\n")

      r = RLSockReader.new
      r.set_bytes_per_sec(read_rate)
      r.set_max_wait_time(read_wait_time)

      @cmds << w
      @cmds << r

      i += 1
      @cmds << Sleeper.new(sleep_in_keepalive) if i <= repeats
    end

    # park in keepalive state until server gives up
    # r = RLSockReader.new
    # r.set_max_wait_time(1000)
    # @cmds << r

  end

  def execute(sock)
    begin
      while sock == nil
        begin
          sock = TCPSocket.open(@uri.host, @uri.port)
        rescue => ex
          if ex.class == Errno::ECONNREFUSED then
            STDERR.puts "sleeping before trying again\n"
            sleep(5)
          else
            raise
          end
        end
      end
      @cmds.each {|x| x.execute(sock)}

    rescue => ex
      STDERR.puts "#{ex.class}: #{ex.message}"
    end
  end

end
