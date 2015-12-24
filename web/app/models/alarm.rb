class Alarm < ActiveRecord::Base
  def is_weekday
    self.mon && self.tue && self.wed && self.thu && self.fri && !self.sat && !self.sun
  end

  def is_weekend
    !self.mon && !self.tue && !self.wed && !self.thu && !self.fri && self.sat && self.sun
  end

  def repeat
    [:mon, :tue, :wed, :thu, :fri, :sat, :sun].inject('') { |s,d|
      s += ',' + d.to_s if self.send(d)
      s
    }.gsub(/^,/, '')
  end

  def repeat_pretty
    if self.is_weekend
      'Weekend'
    elsif self.is_weekday
      'Weekday'
    else
      self.repeat
    end
  end
end
