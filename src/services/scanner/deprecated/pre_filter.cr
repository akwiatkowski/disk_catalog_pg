class Scanner::PreFilter
  def initialize(
    @disk_scanner : DiskScanner,
    @existing_state : ExistingState,
    @enabled = true
  )
    @file_paths = Array(String).new
  end

  getter :file_paths

  def make_it_so
    if @enabled
      puts_log "start"

      processed_file_paths = @existing_state.node_files.map do |node_file|
        node_file.file_path
      end.uniq

      puts_log "processed_file_paths #{processed_file_paths.size}"

      scanner_file_paths = @disk_scanner.file_paths
      scanner_file_paths_size = scanner_file_paths.size

      puts_log "scanner_file_paths #{scanner_file_paths_size}"

      i = 1
      @file_paths = scanner_file_paths.select do |file_path|
        processed_file_paths.includes?(file_path.to_s) == false

        if (i % 100) == 0
          puts_log "↑ #{i}/#{scanner_file_paths_size} for #{file_path}"
          i += 1
        end
      end

      puts_log "filtered to have #{@file_paths.size} files"
    else
      @file_paths = @disk_scanner.file_paths
    end
  end
end
