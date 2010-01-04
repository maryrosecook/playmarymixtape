xml.instruct! :xml, :version => "1.0" 
xml.rss(:version => "2.0") {
  xml.channel {
    title = "Latest Playmary songs"
    xml.title(title)
    xml.link("http://" + Linking.site() + "/track/list")
    xml.description(title)
    xml.language('en-uk')
    for track in @tracks
      render(:partial => 'track/show', :locals => { :parent_xml => xml, :track => track, :permalinks => false })
    end
  }
}