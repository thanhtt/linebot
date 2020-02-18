class WebhookController < ApplicationController
  require "line/bot"
  require "net/http"

  skip_before_action :verify_authenticity_token

  def client
    @client ||= Line::Bot::Client.new {|config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read
    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    unless client.validate_signature(body, signature)
      render json: {message: "Unauthorized"}, status: 401
    else
      events = client.parse_events_from body
      events.each do |event|
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: "image",
            originalContentUrl: "https://infinite-badlands-94986.herokuapp.com/bot.png",
            previewImageUrl: "https://infinite-badlands-94986.herokuapp.com/bot.png"
          }
          client.reply_message(event["replyToken"], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message["id"])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end

      render body: nil, status: 200
    end
  end

  private

  def content result
    content = <<-MESSAGE
診断お疲れさまでした！
結果をお送りしますね#{0x100003.chr("UTF-8")}

#{0x10006C.chr("UTF-8")}診断結果を閲覧する:
#{result}

GEEK JOBではプログラミングの無料体験会もやっています#{0x10006C.chr("UTF-8")}

下のメニューから、無料体験会の予約ができるのでお時間あるときに参加してもらえると嬉しいです！

無料体験会について詳しく知りたい方はこちらも見てくださいね！
https://www.geekjob.jp/column/aboutus/1day-trial/
    MESSAGE
  end
end
