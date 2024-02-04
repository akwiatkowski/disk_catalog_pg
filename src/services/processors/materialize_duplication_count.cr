class MaterializeDuplicationCount
  def initialize
  end

  def all_overwrite
    process_nfs(nfs_overwrite)
  end

  def all_missing
    process_nfs(nfs_missing)
  end

  def nfs_overwrite
    return NodeFile.all
  end

  def nfs_missing
    return NodeFile.where(materialized_duplication_count: nil)
  end

  def process_nfs(nfs)
    i = 0_i64
    duplications = 0_i64
    count = nfs.size

    nfs.each do |node_file|
      puts "start" if i == 0

      duplication_for_nf = NodeFile.where(meta_file_id: node_file.meta_file_id).count.to_s.to_i
      duplications += duplication_for_nf

      node_file.materialized_duplication_count = duplication_for_nf
      node_file.save!

      i += 1
      if (i % 10_000) == 0
        puts "#{i}/#{count} NodeFiule materialized_duplication_count updated, average factor #{duplications.to_f / i.to_f}"
      end
    end
  end
end
