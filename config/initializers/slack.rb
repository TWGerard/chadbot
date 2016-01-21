require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end


client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
  puts "Users:"
  slack_users = client.web_client.users_list
end

client.on :message do |data|
  #puts "Incoming: " + data.to_s

  if data["user"] == "U08EEQUDR" # matches tgerard right now
    giphy_search = data["text"]
    if giphy_result = Giphy.random(giphy_search)
      giphy_img = giphy_result.image_url.to_s
      message_text = "/giphy " + giphy_search
    else
      giphy_search = data["text"].split(" ").last
      if giphy_result = Giphy.random(giphy_search)
        giphy_img = giphy_result.image_url.to_s
        message_text = "/giphy " + giphy_search
      else
        giphy_img = Giphy.translate("confused").image_url.to_s
        message_text = "well I'm stumped"
      end
    end

    # open a direct message channel to respond
    im = client.web_client.im_open user: data["user"]

    # quick boolean toggle for private responses (true) vs public reponses (false)
    target_channel = true ? im["channel"]["id"] : data["channel"]

    # send the message
    client.web_client.chat_postMessage(channel: target_channel, text: message_text, as_user: true, attachments: [{
      image_url: giphy_img,
      fallback: ""
    }])
  end

end

client.start!
    