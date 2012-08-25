class Gcm::Device < Gcm::Base
  self.table_name = "gcm_devices"
  before_save :only_one_active
  attr_accessible :user_id, :registration_id
  belongs_to :user
  has_many :notifications_devices, class_name: 'Gcm::NotificationsDevice', dependent: :destroy
  has_many :notifications, through: :notifications_devices

  validates :registration_id, :presence => true
  validates :user, :presence => true

  # Scopes
  def self.for_user(id)
    where(user_id: id)
  end

  def self.not_for(id)
    where("gcm_devices.id != ?", id)
  end

  private
  def only_one_active(device)
    if device.active
      Gcm::Device.for_user(device.user_id).not_for(device.id).find_each do |d|
        d.active = false
        d.save
      end
    end
  end

end