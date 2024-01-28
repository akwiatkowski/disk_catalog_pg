class SizeTools
  def self.to_human(size)
    return "N/A" if size.nil?

    size = size.not_nil!.to_i64

    if size < 1024_i64
      return "<1 kB"
    elsif size < (1024_i64 ** 2)
      return "#{round_size(size.to_f / (1024_i64 ** 1))} kB"
    elsif size < (1024_i64 ** 3)
      return "#{round_size(size.to_f / (1024_i64 ** 2))} MB"
    elsif size < (1024_i64 ** 4)
      return "#{round_size(size.to_f / (1024.0 ** 3))} GB"
    else
      return "#{round_size(size.to_f / (1024.0 ** 4))} TB"
    end
  end

  def self.round_size(size)
    return ((size * 100.0).round / 100.0)
  end
end
