class FayeurlController < ApplicationController
  def index
    Rails.configuration.faye_url.to_json
  end

end
