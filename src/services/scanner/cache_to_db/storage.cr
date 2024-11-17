require "./preparator"
require "./operation/all"

class Scanner::CacheToDb::Storage
  def initialize(@disk : Disk, @db_cache : DbCache::Cache)
  end

  def persist(cache_unit : FullCache::Unit?, node_file : NodeFile?, file_path : String)
    if node_file.nil? && !cache_unit.nil?
      create(cache_unit: cache_unit.not_nil!, file_path: file_path)
    elsif !node_file.nil? && !cache_unit.nil?
      update(cache_unit: cache_unit.not_nil!, node_file: node_file.not_nil!, file_path: file_path)
    elsif !node_file.nil? && cache_unit.nil?
      delete(node_file: node_file.not_nil!)
    else
      # TODO NotImplemented
    end
  end

  def create(cache_unit : FullCache::Unit, file_path : String)
    preparator = Preparator.new(
      cache_unit: cache_unit,
      disk: @disk,
      file_path: file_path,
      db_cache: @db_cache
    )
    Operation::Create.new(preparator: preparator).create
  end

  def update(cache_unit : FullCache::Unit, node_file : NodeFile, file_path : String)
    preparator = Preparator.new(
      cache_unit: cache_unit,
      disk: @disk,
      file_path: file_path,
      db_cache: @db_cache
    )
    Operation::Update.new(preparator: preparator, node_file: node_file).update
  end

  def delete(node_file : NodeFile)
    Operation::Delete.new(node_file: node_file).delete
  end
end
