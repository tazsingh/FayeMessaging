class FayeurlController < ApplicationController
  respond_to :json

  def index
    respond_with Rails.configuration.faye_url.to_json
  end

end
