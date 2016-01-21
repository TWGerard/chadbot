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
  slack_users["members"].each do |user|
    puts user["name"].to_s + " (" + user["id"].to_s + ") - " + user["profile"]["email"].to_s
  end
end

client.on :message do |data|
  #puts "Incoming: " + data.to_s

  if data["user"] == "U08EEQUDR" # matches tgerard right now. Chad = "U0JF556PR"
    # open a direct message channel to respond
    im = client.web_client.im_open user: data["user"]

    # quick boolean toggle for private responses (true) vs public reponses (false)
    target_channel = true ? im["channel"]["id"] : data["channel"]

    # show that we are typing a response
    client.typing channel: target_channel

    # try to match the whole text
    giphy_search = data["text"]
    begin
      giphy_img = Giphy.random(giphy_search).image_url.to_s
      message_text = "/giphy " + giphy_search
    rescue
      giphy_img = false
    end

    # no results for whole text. try last word only
    if !giphy_img
      giphy_search = data["text"].split(" ").last
      begin
        giphy_img = Giphy.random(giphy_search).image_url.to_s
        message_text = "/giphy " + giphy_search
      rescue
        giphy_img = false
      end
    end

    if !giphy_img
      giphy_img = Giphy.translate("confused").image_url.to_s
      message_text = "well I'm stumped"
    end

    # send the message
    client.message(channel: target_channel, text: message_text, as_user: true, attachments: [{
      image_url: giphy_img,
      fallback: ""
    }])
  end

end

client.start!
