select
  tags.*,
  coalesce(sum(node_paths.size), 0)::bigint as total_size
from tags
left join node_paths on node_paths.tag_id = tags.id
group by tags.id
order by tags.name ;
