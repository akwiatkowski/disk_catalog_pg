class FullCache::Scanner::DiskScanner
  def initialize(
    @path : Path,
    @lg : Ui::Lg
  )
    @file_paths = Array(String).new
  end

  getter :path, :file_paths

  def call
    @lg.info(
      place: self.class,
      message: "scanning disk",
      path: @path
    ) do
      scan_path
    end

    @lg.info(
      place: self.class,
      message: "scan finished with #{@file_paths.size}",
      path: @path
    )
  end

  private def scan_path
    found = Dir[
      scan_pattern,
      follow_symlinks: false,
    ]

    before_filter_count = found.size

    @file_paths = found.select do |found_path|
      begin
        File.directory?(found_path) == false
      rescue File::AccessDeniedError
        # lets ignore files assigned to somekind of root user
        false
      end
    end

    after_filter_count = @file_paths.size

    @lg.info(
      place: self.class,
      message: "filtered directories from #{before_filter_count} to #{after_filter_count}"
    )

    @file_paths
  end

  def scan_pattern
    File.join([@path, "**/*"])
  end
end
