require "./create"

class Scanner::CacheToDb::Storage
  def initialize(@disk : Disk)
  end

  def persist(cache_unit : FullCache::Unit?, node_file : NodeFile?, file_path : String)
    if node_file.nil? && !cache_unit.nil?
      create(cache_unit: cache_unit.not_nil!, file_path: file_path)
    elsif !node_file.nil? && !cache_unit.nil?
      update(cache_unit: cache_unit.not_nil!, node_file: node_file.not_nil!)
    elsif !node_file.nil? && cache_unit.nil?
      delete(node_file: node_file.not_nil!)
    else
      # TODO NotImplemented
    end
  end

  def create(cache_unit : FullCache::Unit, file_path : String)
    Create.new(
      cache_unit: cache_unit,
      disk: @disk,
      file_path: file_path,
    ).run
  end

  def update(cache_unit : FullCache::Unit, node_file : NodeFile)
  end

  def delete(node_file : NodeFile)
  end
end
