class CreateAlarms < ActiveRecord::Migration
  def change
    create_table :alarms do |t|
      t.string :title
      t.string :time
      t.boolean :enabled
      t.string :repeat
      t.boolean :holiday_off
      t.string :sound
      t.boolean :snooze

      t.timestamps null: false
    end
  end
end
