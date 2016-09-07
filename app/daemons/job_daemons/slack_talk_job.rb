module JobDaemons
  # Job of SlackTalkDaemon
  class SlackTalkJob < JobBase
    attr_reader :channel_id, :name, :icon_emoji, :message

    # Initialize Job.
    # @param [String] channel_id ID of channel.
    # @param [String] name       Name of bot.
    # @param [String] icon_emoji Icon emoji of bot.
    # @param [String|Object] message    Message.
    def initialize(channel_id, name, icon_emoji, message)
      raise 'channel_id should be kind of String' unless channel_id.kind_of?(String)
      raise 'name should be kind of String' unless name.kind_of?(String)
      raise 'icon_emoji should be kind of String' unless icon_emoji.kind_of?(String)
      # raise 'message should be kind of String' unless message.kind_of?(String)

      @channel_id = channel_id
      @name = name
      @icon_emoji = icon_emoji
      @message = message
    end

    # Execute SlackTalk.
    def execute!
      SlackUtils::SingletonClient.instance.send_message(@channel_id, @name, @icon_emoji, @message)
    end
  end
end
