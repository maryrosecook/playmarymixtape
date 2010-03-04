class AudiographyController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter [:set_up_subdomain]
  
  def index    
    store_location
    @logged_in = logged_in?()
    audiography = Audiography::get_current(params[:identifier], @subdomain)
    @at_logged_in_user_audiography_url = logged_in? && Linking.at_audiography_url?(current_user.audiography, params[:identifier], @subdomain)
    
    if audiography && !Linking.at_audiography_url?(audiography, params[:identifier], @subdomain)
      redirect_to(Linking.audiography(audiography))
    else
      if audiography
        @no_nav = no_nav? # not come from adwords and not added a song
        @show_back_link = show_back_link?(audiography) # at someone else's audiography
        @show_see_example = show_see_example_link?(audiography)
        @title = get_audiography_title(audiography)
        @tracks = audiography.tracks
        @items = Tracking::tracks_to_items(@tracks)
        audiography.user.fake? ? @show_rss = false : @show_rss = true
        @basic_url = "http://" + Linking.site() + audiography.get_url
        @follow_link = audiography.get_xml_url()
        @itunes_link = audiography.get_itunes_url()
        @user_can_edit = false
        @url_title = params[:identifier]

        if logged_in?() && audiography == current_user.audiography
          @track = Track.new_with_default_comment()
          @user_can_edit = true
        end
      else
        @no_playmary = true
        @title = "No Playmary here"
      end
      
      respond_to do |format|
        format.html
        format.xml { @permalinks = params[:permalinks] }
      end
    end
  end

  def auto_complete_for_search_text()
    search = params[:search][:text]
    output = ""
    if !search.match(/•/) # user has not picked song - show results
      @results = Seeqpodding::search_for_song(search, Seeqpodding::SEARCH_MAX_TIMEOUT)
      if @results.length > 0
        i = 0
        output = ""
        output += "<ul>"
        for result in @results
          artist = result['creator'] ||= Track::ARTIST_PLACEHOLDER
          title = result['title'] ||= Track::TITLE_PLACEHOLDER
          output += "<li>"
            output += "<strong>#{artist}</strong>"
            output += "<span class='autocomplete_exclusion'> • </span>"
            output += "<br/>#{title}"
          output += "</li>"
          i += 1
        end
      
        output += "</ul>"
      else
        output = "<%= content_tag(:ul, content_tag(:li, '#{Track::NO_RESULTS}') ) %>"
      end
    end
    
    render :inline => output
  end
  
  def sort_tracks
    i = 0
    for track_id in params[:track_list]
      if track = Track.find(track_id)
        if track.sort_order != i
          track.sort_order = i
          track.save()
        end
      end
      
      i += 1
    end
    
    render :nothing => true
  end
  
  # def import_list
  #   if logged_in? && current_user.admin?
  #     audiography = current_user.audiography
  #     Importing.import_tracks(audiography.id)
  #   else
  #     flash[:notice] = "Not logged in or not an admin."
  #     redirect_to("/")
  #   end
  # end
  
  protected
  
    def no_nav?()
      logged_in? && current_user.audiography.no_songs_added? && current_user.fake? && session[:s]
    end

    def show_back_link?(current_audiography)
      no_nav? && logged_in? && current_user.audiography != current_audiography
    end

    # returns true if at own audiography and its empty and there is a default audiography
    def show_see_example_link?(current_audiography)
      at_own_empty_audiography?(current_audiography) && Audiography.default
    end

    def at_own_empty_audiography?(current_audiography)
      logged_in? && current_user.audiography == current_audiography && current_audiography.tracks.length == 0
    end

    def get_audiography_title(current_audiography)
      return at_own_empty_audiography?(current_audiography) ? "Add my first song" : current_audiography.url_title
    end
end