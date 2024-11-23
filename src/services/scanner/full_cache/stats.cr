require "./unit/entity"

class Scanner::FullCache::Stats
  alias StatsUnit = Time::Span

  def initialize
    @stats = Hash(String, StatsUnit).new
    @longest_time_span = Time::Span.new(nanoseconds: 1)
  end

  def append(path : String | Path, time_span : Time::Span)
    if @longest_time_span < time_span
      @longest_time_span = time_span
      @stats[path.to_s] = time_span
      return true
    end
    return false
  end

  def print
    longest_files = @stats.to_a.sort do |a, b|
      # sort by time span desc
      b[1] <=> a[1]
    end[0..10]

    longest_files.each do |stat|
      puts "#{stat[0]}: #{stat[1]}"
    end
  end
end
