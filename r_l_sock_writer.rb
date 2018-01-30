
class RLSockWriter

  def initialize
    @max_wait_time = 60
    @bytes_per_sec = 8192
    @data = nil
    @noisy = 0
  end

  def set_data(d)
    @data = d
  end

  def set_bytes_per_sec(bps)
    @bytes_per_sec = bps
  end

  def execute(sock)
    bytes_written = 0
    while bytes_written < @data.size do
      startio = Time.new
      select(nil, [sock], nil, @max_wait_time)
      bytes_to_write = @bytes_per_sec
      if bytes_written + @bytes_per_sec > @data.size
        bytes_to_write = @data.size - bytes_written
      else
        bytes_to_write = @bytes_per_sec
      end
      res = sock.write(@data[bytes_written, bytes_to_write])
      if res > 0
        bytes_written += bytes_to_write
        puts "send -> #{res}" if @noisy > 0
        remaining_waittime = 1.0 - (Time.new - startio)
        if remaining_waittime > 0.0
          sleep(remaining_waittime)
        end
      end
    end
  end

end
