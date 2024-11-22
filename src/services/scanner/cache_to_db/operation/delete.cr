class Scanner::CacheToDb::Operation::Delete
  def initialize(
    @node_file : NodeFile
  )
  end

  def delete
    puts "DELETE #{@node_file.id}: #{@node_file.file_path}"
    @node_file.destroy
    return @node_file
  end
end
