def esc_speech_and_apos(str)
  str = str.gsub(/"/, '\"')
  return_str = str
  return_str = return_str.gsub(/'/, "\\\\'")
  return return_str
end

###

base_url = "http://static.playmary.com/"

i = 1
mp3_filenames = Dir.entries(".").find_all { |x| x.match("\.mp3") }
for filename in mp3_filenames
  url = base_url + esc_speech_and_apos(filename)
  title = esc_speech_and_apos(filename.gsub(/\.mp3/, ""))
  artist = esc_speech_and_apos(filename.gsub(/\.mp3/, ""))
  comment = ''
  audiography_id = 606
  created_at = "2009-10-16 21:28:29"
  updated_at = "2009-10-16 21:28:29"
  permalink = artist.downcase.gsub(/\W/, "").gsub(/\d/, "")
  sort_order = i
  
  sql = "insert into tracks (url, title, artist, comment, audiography_id, created_at, updated_at, permalink, sort_order) VALUES ('#{url}', '#{title}', '#{artist}', '#{comment}', #{audiography_id}, '#{created_at}', '#{updated_at}', '#{permalink}', #{sort_order});"
  puts sql

  i += 1
end