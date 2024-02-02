require "../../config/application"

tags = [
  ["photos", "JPG photos output"],
  ["videos", "Videos created by myself"],
  ["raw", "Camera RAW, gopro raws, camera and drone raw videos"],
  ["todo", "Stuff that needs to be filtered"],
  ["content", "Archive stuff"],
]

tags.each do |tag_array|
  tag_name = tag_array[0]
  tag_desc = tag_array[1]

  if Tag.where(name: tag_name).exists?
  else
    Tag.create(
      name: tag_name,
      description: tag_desc,
    )
  end
end
