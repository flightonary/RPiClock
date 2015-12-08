class ChangeColumnAlarms < ActiveRecord::Migration
  def up
    remove_column :alarms, :repeat
    add_column :alarms, :mon, :boolean
    add_column :alarms, :tue, :boolean
    add_column :alarms, :wed, :boolean
    add_column :alarms, :thu, :boolean
    add_column :alarms, :fri, :boolean
    add_column :alarms, :sat, :boolean
    add_column :alarms, :sun, :boolean
  end

  def down
    add_column :alarms, :repeat, :string
    remove_column :alarms, :mon
    remove_column :alarms, :tue
    remove_column :alarms, :wed
    remove_column :alarms, :thu
    remove_column :alarms, :fri
    remove_column :alarms, :sat
    remove_column :alarms, :sun
  end
end
