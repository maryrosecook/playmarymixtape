parent_xml.item do
  title = ""
  title += "<a href='#{Linking.home}#{track.full_permalink()}'>" if permalinks
  title += track.artist + ", " + track.title
  title += "</a>" if permalinks
  parent_xml.title(title)
  parent_xml.description(track.comment.to_s)
  parent_xml.enclosure(:url => track.url, :type => "audio/mpeg") if track.url && track.url != ""
  parent_xml.pubDate(track.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
  parent_xml.link("#{Linking.home}#{track.full_permalink()}")
  parent_xml.guid("#{Linking.home}#{track.full_permalink()}")
end