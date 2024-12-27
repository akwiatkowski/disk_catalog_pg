class FullCache::Scanner::StatsPresenter
  LENGTH       = 150
  INNER_LENGTH = LENGTH - (2 * 2)

  def initialize(
    @stats_storage : StatsStorage
  )
  end

  def call
    puts "*"*LENGTH
    @stats_storage.to_h.each do |key, value|
      inner_string = "#{key} = #{value}"
      puts "* " + inner_string.ljust(INNER_LENGTH, ' ') + " *"
    end
    puts "*"*LENGTH
  end
end
