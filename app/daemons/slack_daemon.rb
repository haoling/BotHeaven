class SlackDaemon
  # Initialize Daemon.
  def initialize
    assign_events
  end

  # Start RTM Client.
  def start
    EM.defer do
      begin
        rtm_client.start
      rescue => e
        Rails.logger.error e.backtrace
        sleep 15
        retry
      end
    end
  end

  private
  def assign_events
    rtm_client.on(:message) {|raw_message| on_talk(raw_message) }
  end

  # Callback methods on Talk in slack.
  # @param [Hash] raw_message Message of Slack.
  def on_talk(raw_message)
    message = Slacks::Message.new(raw_message)
    return if message.bot?
    Bot.where(channel: message.channel_name).pluck(:id).each do |bot_id|
      JobDaemon.enqueue(JobDaemons::BotJob.new(bot_id, 'onTalk', [message.user_name, message.text, message]))
    end
  rescue => e
    Rails.logger.error(e)
    e.backtrace.each {|l| Rails.logger.error(l)}
  end

  # Get Slack Realtime API Client.
  # @return [Slack::RealTime::Client] realtime client.
  def rtm_client
    SlackUtils::SingletonClient.instance.rtm_client
  end
end
