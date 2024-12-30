class FullCache::Scanner::PathIterator
  def initialize(
    @scanned_list_cache : ScannedListCache,
    @cache : Cache,
    @stats_storage : StatsStorage,
    @periodic : Periodic,
    @ignored_paths : Array(String),
    @lg : Ui::Lg
  )
  end

  def call
    @scanned_list_cache.file_paths.each do |file_path|
      next if ScannedListCache.is_path_ignored?(file_path, @ignored_paths)
      next if File.symlink?(file_path)

      @lg.debug(
        place: self.class,
        message: "rescan",
        path: file_path
      ) do
        @cache.rescan_file_path(file_path)
      end

      @periodic.call
    end
    @periodic.call_when_finish
  end
end
