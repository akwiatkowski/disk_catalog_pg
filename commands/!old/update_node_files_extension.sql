update node_files set file_extension = lower(substring(node_files.file_path from '[^\.]+$'))  where id = 1396465 ;
update node_files set basename = substring(node_files.file_path from '[^/]+$') where id = 1396465 ;


update node_files set file_extension = lower(substring(node_files.file_path from '[^\.]+$')) where file_extension is null;
update node_files set basename = substring(node_files.file_path from '[^/]+$') where basename is null;
