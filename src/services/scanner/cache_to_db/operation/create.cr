class Scanner::CacheToDb::Operation::Create
  def initialize(
    @preparator : Preparator
  )
  end

  def create
    return NodeFile.create(
      meta_file_id: @preparator.meta_file.id.not_nil!,
      disk_id: @preparator.disk.id.not_nil!,
      node_path_id: @preparator.node_path.id.not_nil!,
      file_path: @preparator.file_path.to_s,
      basename: @preparator.basename,
      file_extension: @preparator.file_extension
    )
  end
end
