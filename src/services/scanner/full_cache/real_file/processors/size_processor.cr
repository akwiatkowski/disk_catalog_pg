class Scanner::FullCache::RealFile::Processors::SizeProcessor
  def self.size_for(path)
    size = File.size(path).to_i64
    size = 0.to_i64 if size > 100_000_000_000
    return size.to_i64
  end
end
