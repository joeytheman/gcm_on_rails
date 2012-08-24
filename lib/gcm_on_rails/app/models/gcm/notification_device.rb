class Gcm::NotificationDevice < Gcm::Base
  self.table_name = "gcm_notification_devices"

  attr_accessible :notification_id, :registration_id
  belongs_to :notification, :class_name => "Gcm::Notification"
  validates :notification_id, :presence => true

  # Scopes
  def not_sent
    where sent: false
  end

  # Instance Methods
  def registration_id
    device.registration_id
  end
end