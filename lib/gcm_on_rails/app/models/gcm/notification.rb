class Gcm::Notification < Gcm::Base
  self.table_name = "gcm_notifications"

  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :data

  attr_accessible :collapse_key, :data, :delay_while_idle, :time_to_live
  has_many :notifications_devices, :class_name => 'Gcm::NotificationsDevice', :dependent => :destroy
  has_many :devices, through: :notifications_devices


  validates :collapse_key, :presence => true,  :if => :time_to_live?
  validates :data, :presence => true

  # Scopes
  def self.not_sent
    where sent: false
  end

  # Class Methods
  # Opens a connection to the Google GCM server and attempts to batch deliver
  # an Array of notifications.
  #
  # This method expects an Array of Gcm::Notifications. If no parameter is passed
  # in then it will use the following:
  #   Gcm::Notification.all(:conditions => {:sent_at => nil})
  #
  # As each Gcm::Notification is sent the <tt>sent_at</tt> column will be timestamped,
  # so as to not be sent again.
  #
  # This can be run from the following Rake task:
  #   $ rake gcm:notifications:deliver
  def self.send_notifications(notifications = Gcm::Notification.includes(:devices).not_sent)
    api_key, format = Gcm::Connection.open, configatron.gcm_on_rails.delivery_format
    logger.warn("notifications cannot be delivered when api key is not defined") and return if api_key.blank?
    logger.warn("notifications cannot be delivered when data format is neither json or plain_text") and return unless ["json","plain_text"].include?(format)
    return if notifications.blank?

    notifications.find_each do |notification|
      logger.warn("notification #{notification.id} cannot be delivered when no device was specified") and next if notification.devices.blank?

      response = Gcm::Connection.send_notification(notification, api_key, format)

      if format == "json"
        update_notification_from_json_response(response, notification)
      else   #format is plain text
        update_notification_from_plain_text_response(response, notification)
      end
    end
  end

  #Instance Methods
  def not_sent_devices
    devices.merge Gcm::NotificationsDevice.not_sent
  end

  private

  def self.update_notification_from_json_response(response,notification)
    Gcm::Notification.transaction do
      devices_results = JSON.parse response[:message]
      notification.sent_at = Time.now
      notification.sent = true
      notification.save

      notification.notifications_devices.each_index do |notification_index|
        notification_device = notification.notifications_devices[notification_index]
        notification_device.response_code = response[:code]
        if response[:code] == 200
          notification_response = devices_results["results"][notification_index]
          if notification_response.has_key?("error")
            notification_device.response_error = notification_response["error"]
          else
            notification_device.response_error = nil
            notification_device.sent = true
          end
        end
        notification_device.save
      end
    end
  end

end