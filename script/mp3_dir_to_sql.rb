# Pass the directory with the .mp3s in as an argument.  If you don't,
# the script directory will be used.

def esc_speech_and_apos(str)
  str = str.gsub(/"/, '\"')
  return_str = str
  return_str = return_str.gsub(/'/, "\\\\'")
  return return_str
end

def time_to_sql_time(t)
  t.strftime("%Y-%m-%d %H:%M:%S")
end

###

# switch to directory passed in command line, if it was provided
if ARGV[0]
  Dir.chdir ARGV[0]
end

base_url = "http://static.playmary.com/"

i = 1
mp3_filenames = Dir.entries(".").find_all { |x| x.match("\.mp3") }
for filename in mp3_filenames
  url = base_url + esc_speech_and_apos(filename)
  title = esc_speech_and_apos(filename.gsub(/\.mp3/, ""))
  artist = esc_speech_and_apos(filename.gsub(/\.mp3/, ""))
  comment = ''
  audiography_id = 606
  created_at = time_to_sql_time(Time.now)
  updated_at = time_to_sql_time(Time.now)
  permalink = artist.downcase.gsub(/\W/, "").gsub(/\d/, "")
  sort_order = i
  
  sql = "insert into tracks (url, title, artist, comment, audiography_id, created_at, updated_at, permalink, sort_order) VALUES ('#{url}', '#{title}', '#{artist}', '#{comment}', #{audiography_id}, '#{created_at}', '#{updated_at}', '#{permalink}', #{sort_order});"
  puts sql

  i += 1
end