class Scanner::ExistingState
  def initialize(@disk : Disk)
    @node_files = Array(NodeFile).new
  end

  getter :node_files

  def make_it_so
    puts_log "before loading #{@disk.name}"

    @node_files = @disk.node_files.to_a

    puts_log "loaded #{@disk.name}: #{@node_files.size} node files from DB"
  end
end
