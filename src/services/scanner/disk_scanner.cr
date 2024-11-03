class Scanner::DiskScanner
  def initialize(@path : Path)
    @file_paths = Array(String).new
  end

  getter :path, :file_paths

  def make_it_so
    puts_log "scan #{@path}"

    found = Dir[
      scan_pattern,
      follow_symlinks: false,
    ]

    puts_log "found #{found.size}"

    @file_paths = found.select do |found_path|
      File.directory?(found_path) == false
    end

    puts_log "selected #{@file_paths.size} files"
  end

  def scan_pattern
    File.join([@path, "**/*"])
  end
end
