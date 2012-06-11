class TestClock
  def initialize(time)
    @time = time
  end
  
  def now
    self
  end
  
  def strftime(*args)
    @time.strftime(*args)
  end
end
