module Lastfming
  
  WEEKLY_TRACK_CHART_BASE_URL = "http://ws.audioscrobbler.com/2.0/?method=user.getweeklytrackchart&api_key=#{Configuring.get("last_fm_api_key")}"
  
  # def self.try_to_add_track(audiography)
  #   added_track = nil
  #   for track_data in get_recent_top_tracks(audiography.user) # go through
  #     if can_add_track_to_audiography?(audiography, track_data)
  #       added_track = audiography.import_track(track_data)
  #       break if added_track
  #     end
  #   end
  # 
  #   return added_track
  # end
  
  # def self.can_add_track_to_audiography?(audiography, track_data)
  #   track_data[:playcount].to_i > 0 && !audiography.contains_track?(nil, track_data[:title], track_data[:artist])
  # end
  
  def self.get_recent_top_tracks(user)
    recent_top_tracks = {}
    if user && user.last_fm_username
      all_month_tracks = []
      all_month_tracks += get_weekly_tracks(user.last_fm_username, 1.week.ago.tv_sec, Time.new.tv_sec)
      #all_month_tracks += get_weekly_tracks(user.last_fm_username, 2.weeks.ago.tv_sec, 1.week.ago.tv_sec)
      #all_month_tracks += get_weekly_tracks(user.last_fm_username, 3.weeks.ago.tv_sec, 2.weeks.ago.tv_sec)
      #all_month_tracks += get_weekly_tracks(user.last_fm_username, 4.weeks.ago.tv_sec, 3.weeks.ago.tv_sec)
      
      for all_month_track in all_month_tracks
        identifier = all_month_track[:artist] + all_month_track[:title]
        if recent_top_tracks.has_key?(identifier)
          if Util.ne(all_month_track[:playcount])
            recent_top_tracks[identifier][:playcount] = recent_top_tracks[identifier][:playcount].to_i + all_month_track[:playcount].to_i 
          end
        else
          recent_top_tracks[identifier] = all_month_track
        end
      end
    end
    
    return recent_top_tracks
  end
  
  def self.get_weekly_tracks(username, from, to)
    tracks = []
    xml = APIUtil.response_to_xml(get_weekly_track_chart(username, from, to))
    xml.elements.each("lfm/weeklytrackchart/track") do |data|
      track = {}
      artist = data.elements["artist"].text if data.elements["artist"] && Util.ne(data.elements["artist"].text)
      title = data.elements["name"].text if data.elements["name"] && Util.ne(data.elements["name"].text)
      playcount = data.elements["playcount"].text.to_i if data.elements["playcount"] && Util.ne(data.elements["playcount"].text)
      if artist && title && playcount
        track[:artist] = artist
        track[:title] = title
        track[:playcount] = playcount
        tracks << track
      end
    end
    
    return tracks
  end
  
  def self.get_weekly_track_chart(username, from, to)
    APIUtil.get_request(WEEKLY_TRACK_CHART_BASE_URL + "&user=#{username}&from=#{from}&to=#{to}")
  end
end