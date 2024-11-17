class Scanner::CacheToDb::Operation::Update
  def initialize(
    @preparator : Preparator,
    @node_file : NodeFile
  )
  end

  def update
    # the only thing possible is MetaFile update
    # path, mime, ... should never change
    # moving file will force create and delete instead of update
    if @node_file.meta_file_id != @preparator.meta_file.id.not_nil!
      @node_file.meta_file_id = @preparator.meta_file.id.not_nil!
      @node_file.save!
    end
  end
end
