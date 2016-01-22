require 'slack-ruby-client'
require 'giphy'

module ChadBot
  class SlackSocket
    def initialize(app)
      @app = app

      Thread.new do
        puts ("*" * 20) + " Initializing SlackSocket " + ("*" * 20)

        client = Slack::RealTime::Client.new

        client.on :hello do
          puts "Successfully connected, welcome '#{client.self['name']}' to the '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com."
          #puts "Users:"
          #slack_users = client.web_client.users_list
          #slack_users["members"].each do |user|
          #  puts user["name"].to_s + " (" + user["id"].to_s + ") - " + user["profile"]["email"].to_s
          #end
        end

        client.on :message do |data|
          if data["user"] == "U08EEQUDR" # matches tgerard right now. Chad = "U0JF556PR"
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

            # open a direct message channel to respond
            im = client.web_client.im_open user: data["user"]
            # quick boolean toggle for private responses (true) vs public reponses (false)
            target_channel = true ? im["channel"]["id"] : data["channel"]

            # send the message
            puts client.web_client.chat_postMessage(channel: target_channel, text: message_text, as_user: true, attachments: [{
              image_url: giphy_img,
              fallback: ""
            }])
          end

        end

        client.start!
      end
    end

    def call(env)
      @app.call(env)
    end
  end
end
