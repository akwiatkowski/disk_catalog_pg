class Scanner::FullCache::RealFile::Processors::ExtensionProcessor
  def self.extension_for_path(path)
    return Path.new(path).extension.gsub(/^\./, "").to_s.downcase
  end
end
