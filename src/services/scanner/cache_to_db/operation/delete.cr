class Scanner::CacheToDb::Operation::Delete
  def initialize(
    @node_file : NodeFile
  )
  end

  def delete
    puts "DELETE #{@node_file} not implemented yet"
    return @node_file
  end
end
