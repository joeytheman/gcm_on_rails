class CreateGcmDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :gcm_devices do |t|
      t.string :registration_id, :size => 120, :null => false
      t.references :user
      t.timestamps
    end

    add_index :gcm_notification_devices, :user_id
    add_index :gcm_notification_devices, :registration_id
    add_index :gcm_notification_devices, [:user_id, :registration_id], :unique => true

  end

  def self.down
    drop_table :gcm_notification_devices
  end
end