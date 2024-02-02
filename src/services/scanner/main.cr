require "../tools/time"

require "./disk_scanner"
require "./existing_state"
require "./pre_filter"
require "./prepare_file_entities"
require "./batch_insert"
require "./calculate_entities_hash"

# TODO:
# divide into milestones:
# + test using additional DB !!!
# + scan
# + get existing files from DB
# + filter to ignore existing (toglad)
# + add uniq constraints to existing tables to ensure
# + hash dictionary in yaml
# - batch size about 100
# - get size and hash
# - insert in batch
# - every step has stored time cost and puts every batch

class Scanner::Main
  def initialize(
    @disk : Disk,
    @filter_already_added_to_db : Bool = true,
    @batch_size : Int32 = 500
  )
    @path = Path.new(@disk.path.not_nil!)
    @name = @disk.name.not_nil!.as(String)

    @disk_scanner = DiskScanner.new(path: @path)
    @existing_state = ExistingState.new(disk: @disk)
    @pre_filter = PreFilter.new(
      disk_scanner: @disk_scanner,
      existing_state: @existing_state,
      enabled: @filter_already_added_to_db
    )
    @prapare_file_entities = PrepareFileEntities.new(
      pre_filter: @pre_filter
    )
    @calculate_entities_hash = CalculateEntitiesHash.new(
      prepare_file_entities: @prapare_file_entities
    )
    @batch_insert = BatchInsert.new(
      disk: @disk,
      calculate_entities_hash: @calculate_entities_hash,
      batch_size: @batch_size
    )

    HashCache.cache_path = File.join([@disk.path, "hash_cache.yml"])

    @time_costs = Hash(Symbol, Int64).new
  end

  getter :path, :name, :time_costs

  def make_it_so
    scan_disk
    load_existing_state_from_db
    filter_already_in_db
    prepare_entities
    calculate_entities_hash
    save_batch
  end

  def scan_disk
    record_time :scan_disk do
      @disk_scanner.make_it_so
    end
  end

  def load_existing_state_from_db
    record_time :load_existing_state_from_db do
      @existing_state.make_it_so
    end
  end

  def filter_already_in_db
    record_time :filter_already_in_db do
      @pre_filter.make_it_so
    end
  end

  def prepare_entities
    record_time :prepare_entities do
      @prapare_file_entities.make_it_so
    end
  end

  def calculate_entities_hash
    record_time :calculate_entities_hash do
      @calculate_entities_hash.make_it_so
    end

    Scanner::HashCache.save
  end

  def save_batch
    record_time :save_batch do
      @batch_insert.make_it_so
    end
  end

  private def reset_time_cost
    @time_costs.clear
  end

  private def record_time(key : Symbol, &block : Proc(Nil))
    t = Time.local

    block.call

    @time_costs[key] ||= 0_i64
    @time_costs[key] += (Time.local - t).total_microseconds.to_i64
  end
end
