module Configuring
  
  def self.get(identifier)
    if ENV[identifier]
      return ENV[identifier]
    elsif File.exists?("config/config.yml")
      config = YAML::load(File.open("config/config.yml"))
      return config[identifier]
    else
      return nil
    end
  end
end