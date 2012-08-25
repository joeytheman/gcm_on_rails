class Gcm::Device < Gcm::Base
  self.table_name = "gcm_devices"
  before_save :only_one_active
  attr_accessible :registration_id
  belongs_to :user
  has_many :notifications_devices, class_name: 'Gcm::NotificationsDevice', dependent: :destroy
  has_many :notifications, through: :notifications_devices

  validates :registration_id, :presence => true
  validates :user, :presence => true

  # Scopes
  def self.active
    where active: true
  end

  def self.for_registration_id(registration_id)
    where registration_id: registration_id
  end

  def self.for_user(id)
    where user_id: id
  end

  def self.not_for(id)
    where("gcm_devices.id != ?", id)
  end

  # Instance Methods
  def updated_registration_id(new_registration_id)
    device = Gcm::Device.new
    device.user_id = user.id
    device.registration_id = new_registration_id
    device.active = true
    device.save
  end

  private
  def only_one_active
    if active
      Gcm::Device.for_user(user_id).not_for(id).find_each do |d|
        d.active = false
        d.save
      end
    end
  end

end