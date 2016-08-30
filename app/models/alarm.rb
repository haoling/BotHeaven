# class of Alarm
# @attr [Integer]   id                Alarm ID.
# @attr [String]    name              Name of alarm.
# @attr [String]    callback_function Callback function of alarm.
# @attr [Integer]   minutes           Alarm time.
# @attr [DateTime]  wake_at           Alarm wake at.
# @attr [Boolean]   repeat            if Repeat schedule.
# @attr [Bot]       bot               Owner Bot of alarm.
class Alarm < ActiveRecord::Base
  belongs_to :bot, inverse_of: :alarms

  before_save :update_wake_at

  validates :name, uniqueness: {scope: :bot_id}, length: {in: 1..32}
  validates :callback_function, length: {in: 1..128}
  validates :minutes, presence: true
  validates :bot, presence: true

  # Wake alarm.
  def wake
    JobDaemon.enqueue(JobDaemons::BotJob.new(bot_id, callback_function, [self.name, self.wake_at.to_i]))
    if repeat?
      save
    else
      destroy
    end
  end

  # Check alarm.
  def self.check!
    where(arel_table[:wake_at].lteq(Time.zone.now)).each(&:wake)
  end

  # Set alarm.
  # @note Override if exists alarm_name.
  # @param [String]  alarm_name        Name of alarm.
  # @param [Bot]     bot               Owner of alarm.
  # @param [String]  callback_function Callback function of alarm.
  # @param [Integer] minutes           Minutes.
  # @param [Boolean] repeat            if Repeat Schedule
  def self.set!(alarm_name, bot, callback_function, minutes, repeat)
    if alarm = find_by(name: alarm_name, bot: bot)
      alarm.update!(callback_function: callback_function, minutes: minutes, repeat: repeat)
    else
      create!(name: alarm_name, bot: bot, callback_function: callback_function, minutes: minutes, repeat: repeat)
    end
  end

  private
  def update_wake_at
    self.wake_at = Time.zone.now + self.minutes * 60
  end
end
