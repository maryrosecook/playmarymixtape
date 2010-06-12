# Params: 
#   Directory with the .mp3s.  Omit this and the script directory will be used.
#   Audiography id.  The id of database record for the audiography to add these tracks to.
# e.g.
#   ruby mp3_dir_to_sql.rb "../../../Desktop/mp3s/" 606

require 'rubygems'
require 'mp3info'

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

Dir.chdir ARGV[0] if ARGV[0] # switch to directory passed in command line, if it was provided

if !ARGV[1]
  puts "You need to specify an audiography id."
else
  audiography_id = ARGV[1]
  base_url = "http://static.playmary.com/"
  comment = ''
    
  i = 1
  mp3_filenames = Dir.entries(".").find_all { |x| x.match("\.mp3") }
  for filename in mp3_filenames
    url = base_url + esc_speech_and_apos(filename)
    title = esc_speech_and_apos(filename.gsub(/\.mp3/, ""))
    artist = esc_speech_and_apos(filename.gsub(/\.mp3/, ""))
    
    # try and extract real artist/name info
    begin
      Mp3Info.open(filename) do |mp3|
        title = mp3.tag.title
        artist = mp3.tag.artist_name
        artist = mp3.tag.artist if !artist # try again with .artist
        artist = mp3.tag2['TP1'] if !artist # try again w/ tag2
      end
    rescue
      print "woo"
    end

    created_at = time_to_sql_time(Time.now)
    updated_at = time_to_sql_time(Time.now)
    permalink = (artist.downcase + "_" + title.downcase).gsub(/\W/, "")
    sort_order = i
  
    sql = "insert into tracks (url, title, artist, comment, audiography_id, created_at, updated_at, permalink, sort_order) VALUES ('#{url}', '#{title}', '#{artist}', '#{comment}', #{audiography_id}, '#{created_at}', '#{updated_at}', '#{permalink}', #{sort_order});"
    puts "\n" + sql + "\n"

    i += 1
  end
  puts "\n"
end