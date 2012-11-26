class Gcm::NotificationsDevice < Gcm::Base
  self.table_name = "gcm_notifications_devices"

  attr_accessible :notification_id, :device_id
  belongs_to :notification, :class_name => "Gcm::Notification", :inverse_of => :notifications_devices
  belongs_to :device, :class_name => 'Gcm::Device'
  validates :notification_id, :presence => true

  # Scopes
  def self.not_sent
    where sent: false
  end

  def self.not_sent_ordered
    not_sent.ordered
  end

  def self.ordered
    order :id
  end

  # Instance Methods
  def registration_id
    device.registration_id
  end
end