require "../../config/application"

tags = [
  ["photos", "JPG photos output"],
  ["videos", "Videos created by myself"],
  ["raw", "Camera RAW, gopro raws, camera and drone raw videos"],
  ["todo", "Stuff that needs to be filtered"],
  ["content", "Archive stuff"],
  ["backup", "Backup of home-directory and misc stuff"],
  ["special", "Can be assigned by other tag but this is much more delicate content"],
  ["movies", "Full length movies, not from youtube"],
  ["youtube", "Youtube content, short misc movies"],
  ["series", "TV series"],
  ["delete", "Confirm and remove"],
  ["stuff", "Misc content"],
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
