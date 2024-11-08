require "../src/services/scanner/file_entity"

path = "/home/olek/Dokumenty/zdjecia/main/2024/2024-A/2024-01-09 - ziebice zima/2024_01_09__15_25_DJI_0833.jpg"

t = Time.local
200.times do
  hash1 = FileEntity.hash_for_path_crystal(path)
end
puts (Time.local - t).total_microseconds

t = Time.local
200.times do
  hash2 = FileEntity.hash_for_path_command(path)
end
puts (Time.local - t).total_microseconds

hash1 = FileEntity.hash_for_path_crystal(path)
hash2 = FileEntity.hash_for_path_command(path)
puts hash1.inspect, hash2.inspect
