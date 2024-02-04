class MaterializeDuplicationFactor
  def initialize
  end

  def all_overwrite
    process_nps(nps_overwrite)
  end

  def all_missing
    process_nps(nps_missing)
  end

  def nps_overwrite
    return NodePath.all
  end

  def nps_missing
    return NodePath.where(materialized_duplication_factor: nil)
  end

  def process_nps(nps)
    i = 0_i64
    duplications = 0_i64
    count = nps.size

    nps.each do |node_path|
      puts "start" if i == 0

      node_path.update_duplication_factor!

      i += 1
      if (i % 1000) == 0
        puts "#{i}/#{count} NodePath updated duplication factor"
      end
    end
  end
end
