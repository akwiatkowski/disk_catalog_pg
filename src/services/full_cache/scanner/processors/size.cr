class FullCache::Scanner::Processors::Size
  @size : Int64?

  def initialize(
    @file_path : String,
    @lg : Ui::Lg
  )
  end

  def call
    get_data

    return {
      size: size,
    }
  end

  def size : Int64
    get_data
    return @size.not_nil!
  end

  private def get_data
    return if @size

    @lg.thrivial(
      place: self.class,
      message: "size info",
      path: @file_path
    ) do
      size_temp = File.size(@file_path).to_i64
      size_temp = 0.to_i64 if size_temp > 100_000_000_000
      @size = size_temp.to_i64
    end
  end
end
