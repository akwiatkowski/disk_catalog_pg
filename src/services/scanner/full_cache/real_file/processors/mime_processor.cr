class Scanner::FullCache::RealFile::Processors::MimeProcessor
  def self.mime_for_path(path)
    mime_command = "file --mime-type \"#{path}\""
    mime_result = `#{mime_command}`
    return mime_result.gsub(/[^:]+: /, "").strip
  end
end
