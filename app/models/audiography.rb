class Audiography < ActiveRecord::Base
  belongs_to :user
  has_many :tracks
  has_many :import_tracks
  
  validates_format_of       :url_title, :with => /^\w+$/

  def self.new_fake_and_save(fake_user)
    audiography = self.new()
    audiography.url_title = fake_user.email
    audiography.save()
    
    audiography
  end

  def import_track(track_data)
    track = nil
    if precise_track_str = Seeqpodding.make_precise_track_str(track_data[:artist], track_data[:title])
      track = Track.new_from_seeqpod(precise_track_str, "", self) # returns track if added - serves as an all is well
    end
    
    return track
  end

  def get_url()
    Linking::audiography(self)
  end
  
  def get_xml_url()
    Linking::audiography_xml(self)
  end
  
  def get_itunes_url()
    Linking::audiography_itunes(self)
  end
  
  def tracks()
    Track.find(:all, :conditions => "audiography_id = #{self.id}", :order => "sort_order ASC, created_at DESC")
  end
  
  def self.get_current(identifier, subdomain)
    audiography = nil
    if Linking.production? && Linking.subdomain_navigation? && Util.ne(subdomain)
      audiography = Audiography.find_by_url_title(subdomain)
    elsif identifier
      audiography = Audiography.find_by_url_title(identifier)
    else
      audiography = Audiography.find_by_url_title(Util::get_default_url_title())
    end

    return audiography
  end
  
  def self.url_title_available?(url_title)
    !self.find(:first, :conditions=>['url_title = ?', url_title])
  end
  
  def claimable?
    self.tracks.length > 0
  end
  
  def no_songs_added?
    self.tracks.length == 0
  end
  
  def contains_track?(track, title, artist)
    contains_track = false
    potential_track_artist = Audiography.genericise(artist) if artist
    potential_track_title = Audiography.genericise(title) if title

    if potential_track_artist && potential_track_title
      for existing_track in self.tracks
        existing_track_artist = Audiography.genericise(existing_track.artist) if existing_track.artist
        existing_track_title = Audiography.genericise(existing_track.title) if existing_track.title

        if track == nil || track.id != existing_track.id # existing track not same as passed (being tested) track
          if potential_track_artist == existing_track_artist && potential_track_title == existing_track_title # details match
            contains_track = true
            break
          end
        end
      end
    end

    return contains_track
  end
  
  
  def self.genericise(str)
    str ? str.strip.downcase.gsub(/\W/, "") : nil
  end
  
  def resort_tracks
    i = 0
    self.tracks().each do |track|
      if track.sort_order != i
        track.sort_order = i
        track.save()
      end
      i += 1
    end
  end
end