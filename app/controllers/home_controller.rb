class HomeController < ApplicationController
  layout false

  def index
    client = Line::Bot::Client.new {|config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    body = request.body.read

    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    if client.validate_signature(body, signature)
      @image = "bot.png"
    end
  end
end
