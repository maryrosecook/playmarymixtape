class ImportTrack < ActiveRecord::Base
  belongs_to :audiography

  ADDED = 1
  NOT_ADDED = 0

  def self.get_or_create(in_title, in_artist, in_audiography, in_added)
    import_track = self.find_specific(in_title, in_artist, in_audiography, in_added)
    if !import_track
      import_track = self.new()
      import_track.title = in_title
      import_track.artist = in_artist
      import_track.audiography = in_audiography
      import_track.added = in_added
    end
    
    return import_track
  end
  
  def self.find_specific(title, artist, audiography, added)
    self.find(:first, 
              :conditions => 'title = "' + Util.esc_speech(title) + '" && artist = "' + Util.esc_speech(artist) + '" && audiography_id = ' + audiography.id.to_s + ' && added = ' + added.to_s)
  end
  
  def self.find_unimported(audiography)
    self.find(:all, :conditions => "audiography_id = #{audiography.id} && added = #{NOT_ADDED}")
  end
end
