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
      processed_file_paths = @existing_state.node_files.map do |node_file|
        node_file.file_path
      end.uniq

      @file_paths = @disk_scanner.file_paths.select do |file_path|
        processed_file_paths.includes?(file_path.to_s) == false
      end

      puts "filtered to have #{@file_paths.size} files"
    else
      @file_paths = @disk_scanner.file_paths
    end
  end
end
