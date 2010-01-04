class TrackController < ApplicationController
  before_filter [:set_up_subdomain]
  
  def show
    @logged_in = logged_in?()
    track = Track.find_for_permalink(params[:permalink])
    @tracks = []
    @title = "No track found"
    if track
      @title = track.artist + ", " + track.title
      @tracks << track
      @items = Tracking::tracks_to_items(@tracks)
      @user_can_edit = false
      @user_can_edit = true if logged_in?() && @tracks[0].audiography == current_user.audiography
    end
    
    respond_to do |format| 
      format.html
      format.xml { render(:layout => false, :action => 'latest.rxml') }
    end
  end
  
  def latest
    @tracks = Track.find_most_recently_added()
    @items = Tracking::tracks_to_items(@tracks)
    @show_rss = true
    @follow_link = Linking::latest_tracks_xml()
    @itunes_link = Linking::latest_tracks_itunes()
    @title = "Latest"
    
    respond_to do |format| 
      format.html
      format.xml
    end
  end
  
  def add_from_upload
    track = Track.new_from_file_upload(params, current_user.audiography)
    add_finale(track, "Sorry, that song could not be added.")
  end
  
  def add_from_search
    track = Track.new_from_search(params, current_user.audiography)
    add_finale(track, "Sorry, that song could not be added.")
  end
  
  # def add_from_last_fm
  #   track = Lastfming.try_to_add_track(current_user.audiography)
  #   add_finale(track, "Sorry, no suitable last.fm tracks to add.")
  # end
  
  def add_finale(track, failure_message)
    if track && track.save() && track.audiography.get_url()
      track.audiography.resort_tracks()
      flash[:notice] = "Song added."
      if !current_user.real? && current_user.id == track.audiography.user.id # fake user added track to own audiography - try get them to claim
        redirect_to("/claim")
      else
        redirect_to(track.audiography.get_url())
      end
    else
      flash[:notice] = failure_message
      redirect_to(current_user.audiography.get_url())
    end
  end
  
  def edit
    if logged_in?()
      if request.post?()
        begin
          track = Track.find(params[:track][:id])
          if track && track.audiography.user == current_user
            track.artist = params[:track][:artist]
            track.title = params[:track][:title]
            track.comment = params[:track][:comment]
            track.fill_in_blanks()
      
            if track.save()
              flash[:notice] = "Song saved."
            else
              flash[:notice] = "Sorry, those song details could not be saved."
            end
          end
        rescue
          flash[:notice] = "Sorry, those song details could not be saved."
        end

        if logged_in? && current_user.audiography.get_url()
          redirect_to(current_user.audiography.get_url())
        else
          redirect_to("/")
        end
      else
        begin
          if temp_track = Track.find(params[:id])
            @title = "Edit song"
            if temp_track.can_edit?(current_user)
              @track = temp_track
            else
              @cannot_edit_that_track = true
            end
          end
        rescue # couldn't find track
          flash[:notice] = "Sorry, that sound could not be found."
          if logged_in? && current_user.audiography.get_url()
            redirect_to(current_user.audiography.get_url())
          else
            redirect_to("/")
          end
        end 
      end
    else
      @not_logged_in = true
    end
  end
  
  def delete
    deleted = false
    if logged_in?()
      begin
        if track = Track.find(params[:id])
          deleted = true if track.destroy()
        end
      rescue
      end
    end
    
    flash[:notice] = "Sorry, the song could not be deleted."
    flash[:notice] = "Song deleted." if deleted
    redirect_back_or_default("/")
  end
  
  def list_xml
    @tracks = []
    if params[:show] == "audiography"
      audiography = Audiography.get_current(params[:identifier], @subdomain)
      if audiography
        @tracks = audiography.tracks
      elsif logged_in?()
        @tracks = current_user.audiography.tracks
      end
    elsif params[:show] == "latest"
      @tracks = Track.find_most_recently_added()
    elsif params[:show] == "track"
      @tracks = [Track.find_by_permalink(params[:identifier])]
    end

    render :layout => false
  end
  
  def lfm_list
    @title = "Your recent favourite tracks"
    if logged_in?
      @tracks = Lastfming.get_recent_top_tracks(current_user)
    end
  end
end