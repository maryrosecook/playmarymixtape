class Suggestion < ActiveRecord::Base

  BODY_LENGTH_MAX = 20

  def self.new_with_body(body)
    suggestion = nil
    if body && body != "" && body.length <= BODY_LENGTH_MAX
      suggestion = self.new()
      suggestion.body = body
    end
    
    suggestion
  end
  
  def self.get_random()
    candidates = []
    self.find(:all).each { |suggestion| candidates << suggestion if suggestion.body && suggestion.body.length <= BODY_LENGTH_MAX }
    
    Util::rand_el(candidates)
  end
end