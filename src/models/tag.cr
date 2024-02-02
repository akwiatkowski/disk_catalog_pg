class Tag < Granite::Base
  connection pg
  table tags

  column id : Int64, primary: true
  column name : String
  column description : String
  # total size how much it use disk space
  column materialized_total_size : Int64?
  # uniq files size, if there was no redundancy
  column materialized_uniq_size : Int64?

  timestamps

  has_many node_paths : NodePath
end
