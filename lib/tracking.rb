module Tracking
  
  def self.tracks_to_items(tracks)
    items = []
    prev_track = nil
    for track in tracks
      #items << ["date", track.created_at] if !prev_track || track.created_at.month != prev_track.created_at.month
      items << ["track", track]
      prev_track = track
    end
    
    items
  end

  def self.get_index_of_first_playable_track(tracks)
    i = 0
    tracks.each {|track| if track.playable?() then return i else i += 1 end }

    nil
  end
  
  def self.set_unset_permalinks()
    i = 0
    for track in Track.find(:all, :conditions => "permalink IS NULL || permalink = ''")
      track.generate_permalink()
      track.save()
      i += 1
    end
    
    i
  end
end