json.array!(@alarms) do |alarm|
  json.extract! alarm, :id, :title, :time, :enabled, :repeat, :holiday_off, :sound, :snooze
  json.url alarm_url(alarm, format: :json)
end
