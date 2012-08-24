class Gcm::Device < Gcm::Base
  self.table_name = "gcm_devices"

  attr_accessible :user_id, :registration_id
  belongs_to :user

  validates :registration_id, :presence => true
  validates :user, :presence => true

end