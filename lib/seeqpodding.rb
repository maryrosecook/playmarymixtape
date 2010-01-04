require 'httparty'
require 'uri'
require 'openssl'

module Seeqpodding
  include HTTParty
  
  base_uri "http://www.seeqpod.com"
  
  RESULTS_TO_RETURN = 10
  
  SEARCH_MAX_TIMEOUT = 0.3
  IMPORT_MAX_TIMEOUT = 4
  
  def self.search_for_song(query, max_timeout)
    # set up query
    query = make_query_seeqpodable(query)
    escaped_query = URI.escape(query)

    Logger.new(STDOUT).error "-------------" + query
    
    # get basic data required by API
    api_identity = Util::rand_el(Configuring.get("seeqpod_api_identities"))
    time = Time.now.to_i
    
    path_to_request = "/api/v0.2/music/search/#{escaped_query}/0/10/"
    path_for_digest = "/api/v0.2/music/search/#{query}/0/10/"
    path_for_sig = "#{path_for_digest}#{time.to_s}"
    digest = OpenSSL::Digest::Digest.new('SHA1')
    call_signature = OpenSSL::HMAC.hexdigest(digest, api_identity['key'], path_for_sig)
    headers({'Seeqpod-uid' => api_identity["uid"], 'Seeqpod-timestamp' => time.to_s, 'Seeqpod-call-signature' => call_signature})
    res = get(path_to_request)
    extract_results(res, query, max_timeout)
  end
  
  def self.make_query_seeqpodable(query)
    out_query = query
    if out_query
      out_query = out_query.gsub(/-/, " ")
      out_query = out_query.gsub(Track::ARTIST_PLACEHOLDER_REGEXP, "").gsub(Track::TITLE_PLACEHOLDER_REGEXP, "")
    end
    
    out_query
  end
  
  def self.extract_results(res, artist, max_timeout)
    results = []
    if res
      if xmlDoc = REXML::Document.new(res.body)
        xmlDoc.elements.each("playlist/trackList/track") do |track|
          result = {}
          if url = track.elements["location"].text
            uri = nil
            begin
              uri = URI.parse(APIUtil::make_url_safe(url))
            rescue
            end
            
            if uri
              http = Net::HTTP::new(uri.host, uri.port)
              response = nil
              begin
                Timeout::timeout(max_timeout) do
                  response = http.request_head(uri.path)
                end
              rescue Timeout::Error # failure - got_track is already false  
              rescue # let through any errors
              end
            
              if response && response.is_a?(Net::HTTPSuccess)
                result['url'] = url
                result['creator'] = track.elements["creator"].text
                result['title'] = track.elements["title"].text
                results << result
              end
            end
          end
        end
      end
    end

    results[0..RESULTS_TO_RETURN-1]
  end
  
  def self.get_precise_song(song_and_title_query, i)
    result = nil
    results = search_for_song(song_and_title_query, Seeqpodding::IMPORT_MAX_TIMEOUT)
    result = results[i] if results.length > i

    result
  end
  
  # returns true if actual track doesn't 404 and get timely response from root of server
  def self.track_ok?(url)
    ok = false
    if parsed_url = APIUtil::safely_parse_url(url)
      host = "http://" + parsed_url.host
      ok = true if APIUtil.url_ok?(host, 5, APIUtil::TIMEOUT_NOT_OK) && APIUtil.url_ok?(url, 1, APIUtil::TIMEOUT_OK)
    end
    
    ok
  end
  
  def self.make_precise_track_str(track_artist, track_title)
    precise_str = nil
    if track_title && track_title
      precise_str = track_artist + " • " + track_title
    end
    
    return precise_str
  end
  
  # def self.get_call(url_str)
  #   res = nil
  #   
  #   bad_url = false
  #   begin
  #     url = URI.parse(url_str)
  #   rescue
  #     bad_url = true
  #   end
  #   
  #   if !bad_url
  #     req = Net::HTTP::Get.new(url.path)
  #     begin  
  #       Timeout::timeout(2, Timeout::Error) do
  #         res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
  #       end
  #     rescue Timeout::Error
  #     rescue
  #     end
  #   else
  #     res = -1
  #   end
  #   
  #   res
  # end
end