module TimedRequire
  def require(*args)
    time = Time.now
    super
    puts "require '#{args.join(",")}': %.08f %s" % [(Time.now - time), ("* slowdown" if (Time.now - time) >= 0.1)]
  end
end

#include TimedRequire