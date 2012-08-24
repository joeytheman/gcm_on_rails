class CreateGcmNotifications < ActiveRecord::Migration # :nodoc:

  def self.up

    create_table :gcm_notifications do |t|
      t.string :collapse_key
      t.text :data
      t.boolean :delay_while_idle
      t.boolean :sent, null: false, default: false
      t.datetime :sent_at
      t.integer :time_to_live
      t.timestamps
    end

    add_index :gcm_notifications, :sent, where: 'sent = f'

  end

  def self.down
    drop_table :gcm_notifications
  end
end