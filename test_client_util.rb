
module TestClientUtil

  # join_all was lifted verbatim from "The Ruby Programming Language"
  def self.join_all
    main = Thread.main
    current = Thread.current
    all = Thread.list
    all.each {|t| t.join unless t == current || t == main}
  end

end
