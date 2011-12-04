require 'cora'
require 'siri_objects'
require "oauth"
require "json"

#######
# mapme.at plugin, checks people into mapme.at simply by sending them to a mapme.at url
# 
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::MapMe_At < SiriProxy::Plugin
  def initialize(config = {})
    @config = config
    #if you have custom configuration options, process them here!
  end

  def access_token
    consumer = OAuth::Consumer.new @config["consumer_key"], @config["consumer_secret"], { :site => "http://mapme.at"}
    OAuth::AccessToken.new(consumer, @config["oauth_token"], @config["oauth_token_secret"])
  end

  listen_for /(check me in|map me here)/i do
    say "Checking you in" # Tell the user

    request_completed
  end

  listen_for /where is (.*)[?!]*$/i do |user|

    Thread.new {
      begin
        resp = access_token.get("/api/where.json?username=#{user.gsub(/ /,"")}")
        result = JSON.parse(resp.body)["locations"][0]

	prefix = ""
        desc = ""
        if result["place"]
          if result["place"]["favourite"] and result["place"]["favourite"]["label"]
            prefix = "at"
            desc = result["place"]["favourite"]["label"]
          else
            prefix = "at"
            desc = result["place"]["name"]
          end
        else
          prefix = "in"
          desc = result["local_area"]+", "+result["state"]+", "+result["country_code"]
        end
        map_item = SiriMapItem.new
        map_item.label = desc
        map_item.location.label = desc
        map_item.location.street = ""
        map_item.location.city = "#{result["local_area"]}, #{result["state"]}"
        map_item.location.stateCode = ""
        map_item.location.postalCode = ""
        map_item.location.countryCode = result["country_code"]
	map_item.location.latitude = result["lat"].to_f
	map_item.location.longitude = result["lon"].to_f
        pp map_item.location
        pp result
        add_views = SiriAddViews.new
        add_views.make_root(last_ref_id)
        map_snippet = SiriMapItemSnippet.new
        map_snippet.items << map_item
        utterance = SiriAssistantUtteranceView.new("I found #{user.strip} #{prefix} #{desc}")
        add_views.views << utterance
        add_views.views << map_snippet
        
        #you can also do "send_object object, target: :guzzoni" in order to send an object to guzzoni
        send_object add_views #send_object takes a hash or a SiriObject object

        request_completed
      rescue Exception
        pp $!
        say "Sorry, I encountered an error."
        request_completed
      end
    }
  end

end
