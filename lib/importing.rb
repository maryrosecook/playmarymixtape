module Importing
  
  IMPORT_FILE_PATH = "public/import.txt"
  
  # def self.import_track_list()
  #   titles_and_artists = []
  #   File.open(IMPORT_FILE_PATH, "r") do |f|
  #     while !f.eof?
  #       title_and_artist = f.readline.split(" | ")
  #       if title_and_artist[0] && title_and_artist[0].strip != "" && title_and_artist[1] && title_and_artist[1].strip != ""
  #         titles_and_artists << { :title => title_and_artist[0], :artist => title_and_artist[1] }
  #       end
  #     end
  #   end
  #   
  #   return titles_and_artists
  # end
  # 
  # def self.import_tracks(audiography_id)
  #   if audiography = Audiography.find(audiography_id)
  #     for title_and_artist in Importing.import_track_list()
  #       ImportTrack.get_or_create(title_and_artist[:title], title_and_artist[:artist], audiography, ImportTrack::NOT_ADDED).save()
  #     end
  #   
  #     for import_track in ImportTrack.find_unimported(audiography)
  #       track = nil
  #       track_data = nil
  #       track_data = { :title => import_track.title, :artist => import_track.artist }
  #       if !audiography.contains_track?(nil, track_data[:title], track_data[:artist])
  #         track = audiography.import_track(track_data)
  #       end
  #     
  #       if track && track.save()
  #         Logger.new(STDOUT).error "6Y: " + track_data[:title] + " " + track_data[:artist]
  #       else
  #         Logger.new(STDOUT).error "6N: " + track_data[:title] + " " + track_data[:artist]
  #       end
  #     
  #       import_track.added = ImportTrack::ADDED
  #       import_track.save()
  #     end
  #   
  #     audiography.resort_tracks()
  #   end
  # end
end