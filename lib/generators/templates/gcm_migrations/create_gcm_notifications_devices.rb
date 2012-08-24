class CreateGcmNotificationsDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :gcm_notifications_devices do |t|
      t.references :gcm_device, :null => false
      t.references :notification, null: false
      t.boolean :sent, null: false, default: false
      t.integer :response_code
      t.string  :response_error
      t.timestamps
    end

    add_index :gcm_notifications_devices, :gcm_device_id
    add_index :gcm_notifications_devices, :sent, where: 'sent = t'
    add_index :gcm_notifications_devices, [:gcm_device_id,:notification_id], :unique => true, :name => 'index_gcm_notifications_devices_on_nid_and_rid'
    add_index :gcm_notifications_devices, :notification_id
  end

  def self.down
    drop_table :gcm_notifications_devices
  end
end