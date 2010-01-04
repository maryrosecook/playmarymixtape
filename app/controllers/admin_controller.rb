class AdminController < ApplicationController
  before_filter :admin_login_required
    
  def index
  end
  
  def set_unset_permalinks
    i = Tracking.set_unset_permalinks()
    flash[:notice] = "#{i} permalinks set."
    redirect_to :action => 'index'
  end
  
  def write_a_log
    begin
      1/0
    rescue ZeroDivisionError => exception
      Log::log(current_user, nil, Log::ERROR, exception, "Hi Mary.  This is a test error.")
    end
  end
  
  def set_order_of_all_tracks
    for audiography in Audiography.find(:all)
      i = 0
      for track in Track.find(:all, :conditions => "audiography_id = #{audiography.id}", :order => "sort_order")
        track.sort_order = i
        track.save()
        i += 1
      end
    end
    
    redirect_to(:action => "index")
  end
end