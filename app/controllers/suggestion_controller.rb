class SuggestionController < ApplicationController
  before_filter :admin_login_required
  
  def new
    if request.post? && params[:suggestion]
      body = params[:suggestion][:body]
      if Suggestion.new_with_body(body).save()
        flash[:notice] = "Added suggestion."
        redirect_to("")
      else
        @suggestion = Suggestion.new(params[:suggestion])
        flash[:notice] = "Couldn't add suggestion."
        redirect_to("")
      end
    end
  end
end