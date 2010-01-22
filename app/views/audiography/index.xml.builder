xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@title)
    xml.link(@basic_url)
    xml.description(@title)
    xml.language('en-uk')
    i = 0
    for track in @tracks
      render(:partial => 'track/show', :locals => { :parent_xml => xml, :track => track, :permalinks => @permalinks })
      i += 1
      break if i > 20
    end
  }
}