module AudiographyHelper
  
  @track_ids = nil
  
  LAST_TRACK_ID = 25
  NUM_DUPLICATES = 10
  
  def get_track_colour_id(i)
    get_track_ids()[i]
  end
  
  def get_track_ids()
    if !@track_ids
      @track_ids = []
      for i in (0..NUM_DUPLICATES)
        new_dupe = []
        (0..LAST_TRACK_ID).each {|j| new_dupe << j }
        new_dupe = new_dupe.reverse if i.to_f % 2.to_f != 0
        @track_ids += new_dupe
      end
    end
    
    @track_ids
  end
end