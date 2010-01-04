require 'mp3info'

class Track < ActiveRecord::Base
  belongs_to :audiography
  has_one :file_upload
  
  DEFAULT_COMMENT = "Optional: memories, places, people, times."
  SEARCH_EXPLANATION = "Search for a song"
  
  MP3_EXTENSION = ".mp3"
  PERMALINK_PATH = "/track/"
  
  ARTIST_PLACEHOLDER = "Artist?"
  ARTIST_PLACEHOLDER_REGEXP = "Artist\?"
  TITLE_PLACEHOLDER = "Title?"
  TITLE_PLACEHOLDER_REGEXP = "Title\?"
  
  NO_RESULTS = "No results"
  
  def valid?
    !self.audiography.contains_track?(self, self.title, self.artist)
  end
  
  def self.find_for_permalink(permalink)
    self.find(:first, :conditions => "permalink = '#{permalink}'")
  end
  
  def self.new_with_default_comment()
    track = self.new()
    track.comment = DEFAULT_COMMENT
    
    track
  end
  
  def self.new_from_search(params, audiography)
    new_from_seeqpod(params[:search][:text], params[:track][:comment], audiography)
  end
  
  def self.new_from_seeqpod(song_and_title_query, comment, audiography)
    track = nil
    song_and_title_query = song_and_title_query
    
    if song_and_title_query && song_and_title_query != ""
      if song_and_title_query.match(/•/)
        i = 0
        found_viable_song = false
        result = Seeqpodding::get_precise_song(song_and_title_query, i)
        while result && !found_viable_song
          url = result['url']
          
          if file_upload = FileUpload.new_and_save_from_remote_url(url)
            track = self.new()
            track.new_save_data(audiography, file_upload, comment)
            found_viable_song = true
          else
            i += 1
            result = Seeqpodding::get_precise_song(song_and_title_query, i) # try and get another matching song
          end
        end
      end
    end

    track
  end
  
  def self.new_from_file_upload(params, audiography)
    track = self.new()
    if params[:file_upload][:file] != ""
      file_upload = FileUpload.new(params[:file_upload])
      file_upload.save()
      track.new_save_data(audiography, file_upload, params[:track][:comment])
    end
    
    track
  end

  # put in placeholders if no data
  def fill_in_blanks()
    self.artist = ARTIST_PLACEHOLDER if !self.artist || self.artist == ""
    self.title = TITLE_PLACEHOLDER if !self.title || self.title == ""
  end

  def can_edit?(in_user)
    self.audiography.user == in_user
  end
  
  def playable?()
    self.url && self.url != ""
  end
  
  def self.find_most_recently_added()
    self.find(:all, :conditions => "audiography_id IS NOT NULL", :order => "created_at DESC", :limit => 20)
  end
  
  def full_permalink
    PERMALINK_PATH + self.permalink
  end
  
  def new_save_data(audiography, file_upload, comment)
    self.file_upload = file_upload
    self.audiography = audiography
    self.url = file_upload.url
    self.comment = comment if comment != DEFAULT_COMMENT
    
    # stick mp3 data onto audio
    if file_upload && file_upload.local_path
      begin
        Mp3Info.open(file_upload.local_path) do |mp3|
          self.title = mp3.tag.title
          self.artist = mp3.tag.artist_name
          self.artist = mp3.tag.artist if !self.artist

          # try again w/ tag2
          self.artist = mp3.tag2['TP1'] if !self.artist
        end
      rescue
      end
    end
    
    self.fill_in_blanks()
    self.generate_permalink()
  end

  def generate_permalink()
    base_permalink = (self.artist.downcase + "_" + self.title.downcase).gsub(/\W/, "")
    permalink_try = base_permalink

    i = 1
    while(Track.find_for_permalink(permalink_try))
      permalink_try = base_permalink + i.to_s
      i += 1
    end

    self.permalink = permalink_try
  end
end