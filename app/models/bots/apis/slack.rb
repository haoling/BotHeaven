module Bots::Apis
  # AlarmAPI class of Bot.
  class Slack
    # Initialize class.
    # @param [Bot] bot instance of bot.
    def initialize(bot)
      @bot = bot
    end

    # Talk
    # @param [String] message message.
    # @return [Boolean] true if success.
    def talk(message)
      talk_with_icon(message, @bot.default_icon)
    end

    # Talk with icon
    # @param [String] message     message.
    # @param [String] icon_emoji emoji icon.
    # @return [Boolean] true if success.
    def talk_with_icon(message, icon_emoji)
      if (message.kind_of?(V8::Object)) then
        message = v8obj_to_hash(message)
      end
      JobDaemon.enqueue(JobDaemons::SlackTalkJob.new(@bot.channel_id.to_s, @bot.name.to_s, icon_emoji.to_s, message))
      true
    rescue => e
      Rails.logger.error(e)
      e.backtrace.each {|l| Rails.logger.error(l)}
      false
    end

    private
    def v8obj_to_hash(obj)
      if (obj.kind_of?(V8::Array)) then
        ret = []
        obj.each{|v|
          if (v.kind_of?(V8::Object)) then
            ret << v8obj_to_hash(v)
          else
            ret << v
          end
        }
      else
        ret = {}
        obj.each{|k,v|
          if (v.kind_of?(V8::Object)) then
           ret[k.to_s.to_sym] = v8obj_to_hash(v)
          else
            ret[k.to_s.to_sym] = v
          end
        }
      end
      ret
    end
  end
end
