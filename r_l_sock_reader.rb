# To change this template, choose Tools | Templates
# and open the template in the editor.

class RLSockReader

  def initialize()
    @bytes_per_sec = 8192
    @max_wait_time = 10
    @noisy = 0
  end

  def set_max_wait_time(mwt)
    @max_wait_time = mwt
  end

  def set_bytes_per_sec(bps)
    @bytes_per_sec = bps
  end

  def execute(sock)
    bytes_read = 0
    while bytes_read < 8192 do
      startio = Time.new
      res = select([sock], nil, nil, @max_wait_time)
      if res == nil
        puts "select for readability timed out" if @noisy > 0
        break
      end
      res = sock.recv(@bytes_per_sec)
      puts "recv -> #{res.size}" if @noisy > 0
      if res.eql?("")
        break
      end
      remaining_waittime = 1.0 - (Time.new - startio)
      if remaining_waittime > 0.0
        sleep(remaining_waittime)
      end
    end
  end
end
