class Object
  @@puts_log = Time.local

  def puts_log(string)
    time_span = (Time.local - @@puts_log).total_microseconds
    time_span = 0.0 if time_span < 0.0
    time_span_ms = (time_span.to_f / 1_000).to_i
    puts "#{self.class} @ #{time_span_ms}ms: #{string}"
  end
end
