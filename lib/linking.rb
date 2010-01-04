module Linking
  
  def self.subdomain_navigation?
    true
  end
  
  def self.audiography(audiography)
    if production?
      return Util.ne(audiography.url_title) ? "http://" + audiography.url_title + "." + self.site() : nil
    else
      return Util.ne(audiography.url_title) ? "http://" + self.site + "/" + audiography.url_title : nil
    end
  end
  
  def self.audiography_xml(in_audiography)
    self.audiography(in_audiography) + "?format=xml"
  end
  
  def self.audiography_itunes(in_audiography)
    (self.audiography(in_audiography) + "?format=xml").gsub(/http/, "itpc")
  end
  
  def self.latest_tracks_xml
    "/track/latest?format=xml"
  end
  
  def self.latest_tracks_itunes
    "itpc://" + self.site + "/track/latest?format=xml"
  end
  
  def self.cookie_domain
    if production?
      return ".playmary.com"
    else
      return "localhost"
    end
  end
  
  def self.site
    if production?
      return "playmary.com"
    else
      return "localhost:3000"
    end
  end
  
  def self.home
    if production?()
      return "http://" + self.site()
    else
      return "http://" + self.site()
    end
  end
  
  def self.rootise(url)
    parsed_url = URI.parse(url)
    if production?
      return "http://" + self.site() + parsed_url.path
    else
      return parsed_url.path
    end
  end
  
  def self.production?
    ENV["RAILS_ENV"] == "production"
  end
  
  def self.at_audiography_url?(audiography, identifier, subdomain)
    audiography.url_title == identifier || audiography.url_title == subdomain
  end
  
  def self.at_url?(test_url, url)
    test_url == url
  end
end