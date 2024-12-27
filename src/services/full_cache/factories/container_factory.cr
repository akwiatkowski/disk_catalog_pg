require "../models/container"

class FullCache::Factories::ContainerFactory
  def self.from_disk(
    disk : Disk,
    ignored_paths : Array(String)? = nil
  ) : Models::Container
    name = disk.name.not_nil!
    path = disk.path.not_nil!
    total_disk_size = 0
    avail_disk_size = 0

    size_result = disk_sizes(path)
    if size_result
      total_disk_size = size_result[:total_disk_size].not_nil!
      avail_disk_size = size_result[:avail_disk_size].not_nil!
    end

    return Models::Container.new(
      name: name,
      path: path,
      total_disk_size: total_disk_size.to_i64,
      avail_disk_size: avail_disk_size.to_i64,
      ignored_paths: ignored_paths
    )
  end

  def self.from_cache_path(
    path,
    ignored_paths : Array(String)? = nil
  ) : Models::Container
    container = Models::Container.from_yaml(File.open(path))

    size_result = disk_sizes(container.path)
    container.update_disk_sizes!(size_result.not_nil!) if size_result
    container.update_ignored_paths!(ignored_paths.not_nil!) if ignored_paths

    container
  end

  def self.disk_sizes(disk_path)
    if File.exists?(disk_path)
      begin
        total_disk_size = disk_size_for_disk(disk_path)
        avail_disk_size = disk_free_size_for_disk(disk_path)
      rescue IndexError
        Lg.error(
          place: self,
          message: "problem with getting disk size",
          path: disk_path
        )
      end
      Lg.info(
        place: self,
        message: "disk #{disk_path}, total_size=#{SizeTools.to_human(total_disk_size)}, avail_size=#{SizeTools.to_human(avail_disk_size)}"
      )
      return {total_disk_size: total_disk_size, avail_disk_size: avail_disk_size}
    end
  end

  def self.disk_size_for_disk(disk_path)
    command = "df --output=size -BM \"#{disk_path}\""
    result = `#{command}`
    result_mb_string = result.scan(/(\d+)M/)
    result_mb = result_mb_string[1][1].to_s.to_i64 * 1024 * 1024
    return result_mb
  end

  def self.disk_free_size_for_disk(disk_path)
    command = "df --output=avail -BM \"#{disk_path}\""
    result = `#{command}`
    result_mb_string = result.scan(/(\d+)M/)
    result_mb = result_mb_string[0][1].to_s.to_i64 * 1024 * 1024
    return result_mb
  end
end
