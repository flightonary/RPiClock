class Alarm < ActiveRecord::Base
  def is_weekday
    self.mon && self.tue && self.wed && self.thu && self.fri && !self.sat && !self.sun
  end

  def is_weekend
    !self.mon && !self.tue && !self.wed && !self.thu && !self.fri && self.sat && self.sun
  end

  def repeat
    if self.is_weekend
      'Weekend'
    elsif self.is_weekday
      'Weekday'
    else
      [:mon, :tue, :wed, :thu, :fri, :sat, :sun].inject('') { |s,d|
        s += ',' + d.to_s if self.send(d)
        s
      }.gsub(/^,/, '')
    end
  end
end
