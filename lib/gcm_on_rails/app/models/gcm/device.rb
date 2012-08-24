class Gcm::Device < Gcm::Base
  self.table_name = "gcm_devices"

  attr_accessible :user_id, :registration_id
  belongs_to :user
  has_many :notifications_devices, class_name: 'Gcm::NotificationsDevice', dependent: :destroy
  has_many :notifications, through: :notifications_devices

  validates :registration_id, :presence => true
  validates :user, :presence => true

end