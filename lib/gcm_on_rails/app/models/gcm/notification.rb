class Gcm::Notification < Gcm::Base
  self.table_name = "gcm_notifications"

  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :data

  attr_accessible :collapse_key, :data, :delay_while_idle, :time_to_live
  has_many :notifications_devices, :class_name => 'Gcm::NotificationsDevice', :inverse_of => :notification, :dependent => :destroy
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
  def self.send_notifications
    notifications = self.not_sent
    api_key = Gcm::Connection.open
    logger.warn("notifications cannot be delivered when api key is not defined") and return if api_key.blank?
    return if notifications.blank?

    notifications.find_each do |notification|
      logger.warn("notification #{notification.id} cannot be delivered when no device was specified") and next if notification.devices.blank?

      response = Gcm::Connection.send_notification(notification, api_key)

      update_notification_from_json_response(response, notification)
     end
  end

  #Instance Methods
  def not_sent_devices
    devices.merge Gcm::NotificationsDevice.not_sent_ordered
  end

  def send_gcm
    Gcm::Notification.where(id: self.id).send_notifications
  end

  private

  def self.update_notification_from_json_response(response,notification)
    Gcm::Notification.transaction do
      devices_results = JSON.parse response[:message]
      notification.sent_at = Time.now
      notification.sent = true
      notification.save

      notification.notifications_devices.not_sent_ordered.each_index do |notification_index|
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

        if response[:registration_id]
          notification_device.updated_registration_id(response[:registration_id])
        end
      end
    end
  end

end